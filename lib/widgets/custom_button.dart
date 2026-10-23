import 'package:flutter/material.dart';
import 'package:prepmock/utils/theme.dart';
import 'package:prepmock/widgets/bounce.dart';

class CustomButton extends StatelessWidget {
  final String buttonText;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool? isDisable;
  final bool? isBackButton;
  final double? buttonRadius;
  final double? width;
  final double? height;
  final IconData? icon;

  const CustomButton({
    super.key,
    required this.buttonText,
    required this.onPressed,
    required this.isLoading,
    this.isBackButton,
    this.isDisable,
    this.buttonRadius,
    this.width,
    this.height,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    const cs = GalleryThemeData.colorScheme;
    final tt = GalleryThemeData.textTheme;

    return Bouncing(
      onPressed: isDisable == true || isLoading ? () {} : onPressed,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isDisable == true
              ? GalleryThemeData.fontGreyColor
              : isBackButton == true
                  ? GalleryThemeData.inActiveColor
                  : cs.primary,
          foregroundColor: Colors.white,
          fixedSize: Size(width ?? double.infinity, height ?? 52),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: tt.titleMedium!.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        onPressed: isDisable == true || isLoading ? null : onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null && !isLoading) ...[
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
            ],
            Text(
              buttonText,
              style: tt.titleMedium!.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (isLoading) ...[
              const SizedBox(width: 10),
              const SizedBox(
                height: 16,
                width: 16,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
