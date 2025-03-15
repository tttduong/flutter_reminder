import 'package:flutter/material.dart';

class NewListBottomSheet extends StatefulWidget {
  const NewListBottomSheet({Key? key}) : super(key: key);

  @override
  State<NewListBottomSheet> createState() => _NewListBottomSheetState();
}

class _NewListBottomSheetState extends State<NewListBottomSheet> {
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
                          onPressed: () {},
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
                      margin: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: selectedColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(selectedIcon, color: selectedColor, size: 28),
                    ),
                    // TextField cho tên danh sách
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const TextField(
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'List Name',
                        ),
                      ),
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
}
