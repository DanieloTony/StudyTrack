import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class GlassSurface extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final BorderRadiusGeometry borderRadius;
  final double blurSigma;
  final Color? color;
  final Color? borderColor;
  final bool showShadow;

  const GlassSurface({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = const BorderRadius.all(Radius.circular(AppRadii.card)),
    this.blurSigma = 8,
    this.color,
    this.borderColor,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fill =
        color ??
        (isDark
            ? AppColors.darkSurface.withValues(alpha: 0.96)
            : AppColors.surface.withValues(alpha: 0.98));
    final outline =
        borderColor ??
        (isDark ? AppColors.darkBorder : AppColors.border);

    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: showShadow ? AppShadows.glass : null,
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        clipBehavior: Clip.antiAlias,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: fill,
              borderRadius: borderRadius,
              border: Border.all(color: outline),
            ),
            child: Padding(padding: padding ?? EdgeInsets.zero, child: child),
          ),
        ),
      ),
    );
  }
}
