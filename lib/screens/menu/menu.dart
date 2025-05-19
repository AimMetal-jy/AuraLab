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
          
          // 播放器区域
          Container(
            margin: const EdgeInsets.only(left: 50,right: 50,bottom: 70),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[350],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 播放列表区域
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListView.builder(
                    itemCount: 4,
                    padding: const EdgeInsets.all(8),
                    itemBuilder: (context, index) {
                      return Container(
                        height: 40,
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey[350],
                          borderRadius: BorderRadius.circular(8),
                        ),
                      );
                    },
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // 播放控制按钮
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.skip_previous),
                      onPressed: () {},
                      color: Colors.black87,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.play_arrow),
                        onPressed: () {},
                        color: Colors.black87,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_next),
                      onPressed: () {},
                      color: Colors.black87,
                    ),
                  ],
                ),
              ],
            ),
          ),
          
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
