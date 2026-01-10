import 'package:flutter/material.dart';
import 'package:flutter_to_do_app/consts.dart';
import 'package:flutter_to_do_app/controller/chat_controller.dart';
import 'package:get/get.dart';

class ModeSelectorBottomSheet extends StatelessWidget {
  final ChatPageController controller;

  const ModeSelectorBottomSheet({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            "Select Mode",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Obx(() => _ModeButton(
                label: "Normal Chat",
                mode: "normal",
                isSelected: controller.selectedMode.value == "normal",
                onTap: () {
                  controller.changeMode("normal");
                  Navigator.pop(context);
                },
              )),
          const SizedBox(height: 12),
          Obx(() => _ModeButton(
                label: "Generate Plan",
                mode: "generate_plan",
                isSelected: controller.selectedMode.value == "generate_plan",
                onTap: () {
                  controller.changeMode("generate_plan");
                  Navigator.pop(context);
                },
              )),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final String label;
  final String mode;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeButton({
    required this.label,
    required this.mode,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? AppColors.primary : AppColors.white,
          foregroundColor: isSelected ? Colors.white : AppColors.primary,
          elevation: 0,
          side: BorderSide(
            color: isSelected ? AppColors.primary : AppColors.secondary,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
