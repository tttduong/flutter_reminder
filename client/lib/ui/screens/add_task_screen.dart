import 'package:flutter/material.dart';
import 'package:flutter_to_do_app/ui/screens/update_profile.dart';
import 'package:flutter_to_do_app/ui/widgets/user_banners.dart';

import '../../data/models/network_response.dart';
import '../../data/services/network_caller.dart';
import '../../data/utils/api_links.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_form_field.dart';
import '../widgets/screen_background.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final TextEditingController _taskNameController = TextEditingController();

  final TextEditingController _taskDescriptionController =
      TextEditingController();
  bool _addNewTaskLoading = false;

  Future<void> addNewTask() async {
    final title = _taskNameController.text.trim();
    final description = _taskDescriptionController.text.trim();

    if (title.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Title and Description cannot be empty")),
      );
      return;
    }

    _addNewTaskLoading = true;
    if (mounted) setState(() {});

    Map<String, dynamic> requestBody = {
      "title": title,
      "description": description,
      "status": "New",
    };

    final NetworkResponse response =
        await NetworkCaller().postRequest(ApiLinks.createTask, requestBody);

    _addNewTaskLoading = false;
    if (mounted) setState(() {});

    if (response.isSuccess) {
      _taskNameController.clear();
      _taskDescriptionController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Task Added Successfully")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Task Added Failed")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: userBanner(context, onTapped: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const UpdateProfileScreen()));
      }),
      body: ScreenBackground(
          child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 30,
                    ),
                    const Text(
                      "Add Task",
                      style:
                          TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    CustomTextFormField(
                      hintText: "Task Title",
                      controller: _taskNameController,
                      textInputType: TextInputType.text,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return "Please enter task title";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    CustomTextFormField(
                      maxLines: 4,
                      hintText: "Description",
                      controller: _taskDescriptionController,
                      textInputType: TextInputType.text,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return "Please enter task description";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Visibility(
                        visible: _addNewTaskLoading == false,
                        replacement: const Center(
                          child: CircularProgressIndicator(),
                        ),
                        child: CustomButton(
                          onPresse: () {
                            addNewTask();
                          },
                        )),
                  ],
                )),
          ],
        ),
      )),
    );
  }
}
