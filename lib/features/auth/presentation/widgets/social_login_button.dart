import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class SocialLoginButton extends StatelessWidget {
  const SocialLoginButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.iconUrl,
  });

  final String text;
  final VoidCallback onPressed;
  final String iconUrl;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        side: const BorderSide(color: AppColors.divider),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // If you have a local asset: Image.asset(iconUrl, height: 24)
          // For now we'll just use a generic icon since we don't have the asset
          const Icon(Icons.g_mobiledata, size: 32, color: Colors.blue),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}
