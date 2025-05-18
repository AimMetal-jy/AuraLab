import 'package:flutter/material.dart';
import 'package:auralab/routes/app_routes.dart';
import '../../util/buttons/menu_button.dart';

class DrawerMenu extends StatelessWidget {
  final String userName;
  const DrawerMenu({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: Container(
      color: const Color(0xFFF3F3F3),
      child: Column(
        children: [
          const SizedBox(height: 24),
          // 头像
          const CircleAvatar(
            radius: 32,
            backgroundColor: Colors.grey,
          ),
          const SizedBox(height: 8),
          Text(
            userName,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 32),
          // 四个按钮
          MenuButton(
            text: '听力',
            onPressed: () {
              Navigator.pushReplacementNamed(
                context,
                AppRoutes.listening,
              );
            },
          ),
          const SizedBox(height: 16),
          MenuButton(
            text: '生词本',
            onPressed: () {
              Navigator.pushReplacementNamed(
                context,
                AppRoutes.vocabulary,
              );
            },
          ),
          const SizedBox(height: 16),
          MenuButton(
            text: '笔记',
            onPressed: () {
              Navigator.pushReplacementNamed(
                context,
                AppRoutes.notes,
              );
            },
          ),
          const SizedBox(height: 16),
          MenuButton(
            text: '翻译练习',
            onPressed: () {
              Navigator.pushReplacementNamed(
                context,
                AppRoutes.translate,
              );
            },
          ),
          const Expanded(child: SizedBox()),
          // 设置按钮
          Padding(
            padding: const EdgeInsets.only(left: 32, bottom: 24),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.settings,
                  );
                },
                backgroundColor: Colors.grey[400],
                mini: true,
                child: const Icon(Icons.settings, color: Colors.black87),
              ),
            ),
          ),
        ],
      ),
    ));
  }
}
