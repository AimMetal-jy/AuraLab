import 'package:flutter/material.dart';
import 'package:auralab/routes/app_routes.dart';
import '../../util/buttons/menu_button.dart';
import '../../services/user_service.dart';

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
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.user,
              );
            },
            child: const CircleAvatar(
              radius: 32,
              backgroundColor: Colors.grey,
              child: Icon(
                Icons.person,
                size: 32,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 8),
          ListenableBuilder(
            listenable: UserService(),
            builder: (context, child) {
              final userService = UserService();
              return Text(
                userService.isLoggedIn 
                    ? userService.username ?? '未知用户'
                    : '点击登录',
                style: TextStyle(
                  fontSize: 14, 
                  color: userService.isLoggedIn ? Colors.black87 : Colors.grey[600],
                ),
              );
            },
          ),
          const SizedBox(height: 32),
          // 四个按钮
          MenuButton(
            text: '文档',
            onPressed: () {
              Navigator.pushReplacementNamed(
                context,
                AppRoutes.documents,
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
          
          // 登出按钮（仅在已登录时显示）
          ListenableBuilder(
            listenable: UserService(),
            builder: (context, child) {
              final userService = UserService();
              if (!userService.isLoggedIn) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(left: 32, bottom: 8),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: TextButton.icon(
                    onPressed: () {
                      // 显示确认对话框
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('确认登出'),
                            content: const Text('您确定要退出登录吗？'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('取消'),
                              ),
                              TextButton(
                                onPressed: () {
                                  UserService().clearUser();
                                  Navigator.of(context).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('已退出登录'),
                                      backgroundColor: Colors.orange,
                                    ),
                                  );
                                },
                                child: const Text('确认'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    icon: const Icon(Icons.logout, color: Colors.red),
                    label: const Text(
                      '退出登录',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ),
              );
            },
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
