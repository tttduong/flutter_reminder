import 'package:flutter/material.dart';
import 'package:flutter_to_do_app/consts.dart';

class ListCard extends StatefulWidget {
  final String title;
  final Color color;
  final IconData icon;
  final int? taskCount;
  final double? progress;
  final VoidCallback? onTap;
  // final VoidCallback onDelete; // Hàm xóa khi vuốt

  const ListCard({
    Key? key,
    required this.title,
    required this.color,
    required this.icon,
    this.taskCount,
    this.progress,
    this.onTap,
    // required this.onDelete, // Nhận hàm xóa từ parent
  }) : super(key: key);

  @override
  State<ListCard> createState() => _ListCardState();
}

class _ListCardState extends State<ListCard> {
  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: UniqueKey(), // Key để Dismissible hoạt động
      direction: DismissDirection.endToStart, // Vuốt từ phải sang trái
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.8), // Màu nền khi vuốt
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 28,
        ),
      ),
      onDismissed: (direction) {
        // onDelete(); // Gọi hàm xóa
      },

      child: Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: InkWell(
          onTap: widget.onTap,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: widget.color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      widget.icon,
                      color: widget.color,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: widget.color,
                          ),
                        ),
                        // Chỉ hiển thị nếu progress không null
                        if (widget.taskCount != null)
                          Text(
                            '${widget.taskCount} tasks',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        // Chỉ hiển thị nếu progress không null
                        if (widget.progress != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: LinearProgressIndicator(
                              value: widget.progress!.clamp(0.0, 1.0),
                              backgroundColor: Colors.grey.shade300,
                              color: widget.color,
                              minHeight: 6,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
