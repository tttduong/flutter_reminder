import 'package:flutter/material.dart';
import 'package:flutter_to_do_app/controller/category_controller.dart';
import 'package:flutter_to_do_app/model/category.dart' as model;
import 'package:flutter_to_do_app/service/category_service.dart';
import 'package:flutter_to_do_app/ui/theme.dart';
import 'package:flutter_to_do_app/ui/widgets/input_field.dart';
import 'package:get/get.dart';

class NewListBottomSheet extends StatefulWidget {
  const NewListBottomSheet({Key? key}) : super(key: key);

  @override
  State<NewListBottomSheet> createState() => _NewListBottomSheetState();
}

class _NewListBottomSheetState extends State<NewListBottomSheet> {
  final CategoryController _categoryController = Get.put(CategoryController());
  final TextEditingController _titleController = TextEditingController();
  // Danh sách màu sắc (12 màu)
  final List<Color> colors = [
    Colors.red,
    Colors.orange,
    Colors.amber,
    Colors.blue.shade600,
    Colors.green,
    Colors.blue,
    Color(0xFF8D6E63), // Brown
    Colors.pink,
    Colors.blueGrey,
    Colors.purple,
    Colors.lightGreen,
    Colors.black,
  ];

  // Danh sách icon (18 icon)
  final List<IconData> icons = [
    Icons.sentiment_satisfied_alt_outlined, // Smile
    Icons.shield_outlined, // Shield
    Icons.work_outline, // Briefcase
    Icons.person_outline, // Person
    Icons.local_shipping_outlined, // Truck
    Icons.note_outlined, // Note
    Icons.format_list_bulleted, // List
    Icons.directions_run, // Running person
    Icons.card_giftcard, // Gift
    Icons.cake, // Cake
    Icons.favorite_border, // Heart
    Icons.laptop, // Laptop
    Icons.house, // House
    Icons.shopping_cart, // Cart
    Icons.airplanemode_active, // Airplane
    Icons.shopping_bag, // Bag
    Icons.home, // Home
    Icons.pets, // Paw
  ];

  Color selectedColor = Colors.blue;
  IconData selectedIcon = Icons.format_list_bulleted;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  children: [
                    // Thanh tiêu đề
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel',
                              style:
                                  TextStyle(color: Colors.blue, fontSize: 16)),
                        ),
                        const Text('New List',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18)),
                        TextButton(
                          onPressed: () => _validateList(),
                          child: const Text('Create',
                              style:
                                  TextStyle(color: Colors.blue, fontSize: 16)),
                        ),
                      ],
                    ),
                    // Icon preview
                    Container(
                      width: 60,
                      height: 60,
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      decoration: BoxDecoration(
                        color: selectedColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(selectedIcon, color: selectedColor, size: 28),
                    ),

                    MyInputField(
                      title: "",
                      hint: "Enter title here",
                      controller: _titleController,
                    ),
                  ],
                ),
              ),
              // Nội dung có thể cuộn
              Expanded(
                child: SingleChildScrollView(
                  controller:
                      scrollController, // Để DraggableScrollableSheet có thể cuộn
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        // GridView màu sắc
                        GridView.builder(
                          shrinkWrap: true, // Để nó chỉ chiếm không gian vừa đủ
                          physics:
                              const NeverScrollableScrollPhysics(), // Ngăn GridView tự cuộn
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 6,
                            mainAxisSpacing: 20,
                            crossAxisSpacing: 20,
                            childAspectRatio: 1,
                          ),
                          itemCount: colors.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedColor = colors[index];
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: colors[index],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: selectedColor == colors[index]
                                        ? Colors.black
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        // GridView icon
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 6,
                            mainAxisSpacing: 20,
                            crossAxisSpacing: 20,
                            childAspectRatio: 1,
                          ),
                          itemCount: icons.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedIcon = icons[index];
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: selectedIcon == icons[index]
                                        ? Colors.black
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                                child: Icon(icons[index], color: Colors.blue),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  _validateList() {
    if (_titleController.text.isNotEmpty) {
      _addListToDb();
      // Get.back();
    } else if (_titleController.text.isEmpty) {
      Get.snackbar("Required", "All fields are required!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.white,
          colorText: pinkClr,
          icon: Icon(Icons.warning_amber_rounded, color: Colors.red));
    }
  }

  _addListToDb() async {
    if (_titleController.text.isEmpty) return;

    final category = model.Category(
      id: UniqueKey().toString(), // Tạo ID ngẫu nhiên nếu cần
      title: _titleController.text,
      color: Color(selectedColor.value), // Lưu mã màu dưới dạng int
      icon: IconData(selectedIcon.codePoint,
          fontFamily: 'MaterialIcons'), // Lưu mã Unicode của icon
    );

    bool success = await CategoryService.createCategory(category: category);
    if (success) {
      Get.back(); // Đóng bottom sheet sau khi thêm thành công
      Get.snackbar("Success", "Category added successfully!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          icon: const Icon(Icons.check_circle, color: Colors.white));

      // Cập nhật danh sách category trong UI
      _categoryController.getCategories();
    } else {
      Get.snackbar("Error", "Failed to add category!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          icon: const Icon(Icons.error, color: Colors.white));
    }
  }
}
