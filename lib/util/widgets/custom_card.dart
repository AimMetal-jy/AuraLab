import 'package:flutter/material.dart';

/// 通用卡片组件
/// 在应用中多处复用的卡片UI组件
/// 统一了卡片的样式，包括圆角、阴影等
class CustomCard extends StatelessWidget {
  final Widget child;
  final double elevation;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final VoidCallback? onTap;

  const CustomCard({
    super.key,
    required this.child,
    this.elevation = 10,
    this.borderRadius = 20,
    this.padding,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
      ),
      elevation: elevation,
      color: color,
      child: Padding(
        padding: padding ?? EdgeInsets.zero,
        child: child,
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: card,
      );
    }

    return card;
  }
}