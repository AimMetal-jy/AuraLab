import 'package:auralab/screens/listening/listening.dart';
import 'package:flutter/material.dart';
import '../settings/settings.dart';
import '../notes/notes.dart';
import '../translate/translate.dart';
import '../vocabulary/vocabulary.dart';
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
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ListeningPage()),
              );
            },
          ),
          const SizedBox(height: 16),
          MenuButton(
            text: '生词本',
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const VocabularyPage()),
              );
            },
          ),
          const SizedBox(height: 16),
          MenuButton(
            text: '翻译练习',
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const TranslatePage()),
              );
            },
          ),
          const SizedBox(height: 16),
          MenuButton(
            text: '批注',
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const Notes()),
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Settings()),
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
