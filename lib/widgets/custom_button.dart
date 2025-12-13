import 'package:flutter/material.dart';

/// Custom button widget for consistent styling
/// This is optional but makes code cleaner and reusable
class CustomButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onPressed;
  final bool isPrimary;
  final bool isOutlined;

  const CustomButton({
    super.key,
    required this.label,
    this.icon,
    required this.onPressed,
    this.isPrimary = true,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isOutlined) {
      return OutlinedButton.icon(
        onPressed: onPressed,
        icon: icon != null ? Icon(icon) : const SizedBox.shrink(),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF0B5FA5),
          side: const BorderSide(
            color: Color(0xFF0B5FA5),
            width: 2,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 32,
            vertical: 16,
          ),
        ),
      );
    }

    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: icon != null ? Icon(icon) : const SizedBox.shrink(),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary
            ? const Color(0xFF0B5FA5)
            : const Color(0xFF2A85D8),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: 32,
          vertical: 16,
        ),
      ),
    );
  }
}

/*
🎓 Why create custom widgets?

1. Consistency:
   - All buttons look the same
   - One place to change styling

2. Reusability:
   - Write once, use everywhere
   - Less code duplication

3. Maintainability:
   - Easy to update design
   - Change colors globally

USAGE EXAMPLE:
  CustomButton(
    label: 'Scan Now',
    icon: Icons.camera_alt,
    onPressed: () => print('Scan!'),
  )
*/