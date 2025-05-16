import 'package:flutter/material.dart';

/// 自定义菜单按钮组件
/// 可在应用中多处复用的菜单按钮
class MenuButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  
  const MenuButton({
    super.key,
    required this.text,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 32),
        Expanded(
          child: GestureDetector(
            onTap: onPressed,
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.grey[350],
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(
                text,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        const SizedBox(width: 16),
      ],
    );
  }
}