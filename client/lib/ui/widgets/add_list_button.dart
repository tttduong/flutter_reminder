import 'package:flutter/material.dart';
import 'package:flutter_to_do_app/consts.dart';

class AddListButton extends StatelessWidget {
  final VoidCallback onAddCategoryTap;

  const AddListButton({
    Key? key,
    required this.onAddCategoryTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: onAddCategoryTap,
        icon: const Icon(
          Icons.add,
          color: AppColors.black,
          size: 24,
        ),
        label: const Text(
          "New List",
          style: TextStyle(color: AppColors.black, fontSize: 18),
          textAlign: TextAlign.start,
        ),
      ),
    );
  }
}
