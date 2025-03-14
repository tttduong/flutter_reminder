import 'package:flutter/material.dart';
import 'package:flutter_to_do_app/ui/add_task_bar.dart';
import 'package:flutter_to_do_app/ui/scheme.dart';
import 'package:flutter_to_do_app/ui/widgets/list_card.dart';
import 'package:flutter_to_do_app/ui/widgets/menu_card.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black),
          onPressed: () {},
        ),
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search',
              border: InputBorder.none,
              prefixIcon: const Icon(Icons.search),
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: MenuCard(
                    icon: Icons.today,
                    title: 'Today',
                    color: Colors.red,
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: MenuCard(
                    icon: Icons.calendar_month,
                    title: 'Schedule',
                    color: Colors.orange,
                    onTap: () {
                      Get.to(() => Scheme());
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: MenuCard(
                    icon: Icons.list_alt,
                    title: 'All Tasks',
                    color: Colors.green,
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: MenuCard(
                    icon: Icons.chat_bubble_outline,
                    title: 'Chatbot',
                    color: Colors.blue,
                    onTap: () {},
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              'My Lists',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListCard(
              title: 'Personal Project',
              taskCount: 23,
              progress: 0.7,
              onTap: () {},
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Get.to(() => AddTaskPage());
        },
        shape: const CircleBorder(),
        backgroundColor: Colors.black,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
