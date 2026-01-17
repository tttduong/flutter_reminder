import 'package:flutter/material.dart';

class AuthButton extends StatelessWidget {
  final String? icon;
  final String text;
  final Widget? iconWidget;
  final VoidCallback? onPressed;
  final bool isFuture;

  const AuthButton({
    super.key,
    this.icon,
    required this.text,
    this.iconWidget,
    this.onPressed,
    this.isFuture = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget button = Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black26),
        borderRadius: BorderRadius.circular(28),
      ),
      child: TextButton(
        onPressed: isFuture ? null : onPressed,
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null)
              Image.asset(icon!, height: 20, width: 20)
            else if (iconWidget != null)
              iconWidget!,
            const SizedBox(width: 12),
            Text(
              text,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );

    if (!isFuture) return button;

    return Banner(
      message: 'SOON',
      location: BannerLocation.topEnd,
      color: Colors.orange,
      textStyle: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.bold,
        letterSpacing: 1,
      ),
      child: button,
    );
  }
}
