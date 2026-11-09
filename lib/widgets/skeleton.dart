import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:prepmock/utils/theme.dart';

/// Shared shimmer helpers. Wrap a group of [box]/[circle] placeholders in
/// [shimmer] so one sweep runs across all of them.
class Skel {
  static Widget shimmer({
    required Widget child,
    Color? baseColor,
    Color? highlightColor,
  }) {
    return Shimmer.fromColors(
      baseColor: baseColor ?? GalleryThemeData.lightGreyColor,
      highlightColor: highlightColor ?? Colors.white,
      period: const Duration(seconds: 2),
      child: child,
    );
  }

  /// Variant for placeholders sitting on a coloured (blue) header.
  static Widget shimmerOnDark({required Widget child}) {
    return Shimmer.fromColors(
      baseColor: Colors.white.withValues(alpha: .25),
      highlightColor: Colors.white.withValues(alpha: .55),
      period: const Duration(seconds: 2),
      child: child,
    );
  }

  /// A solid placeholder. It must be opaque (white) so the shimmer can paint it.
  static Widget box({double? width, double height = 14, double radius = 8}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  static Widget circle(double size) {
    return Container(
      width: size,
      height: size,
      decoration:
          const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
    );
  }
}
