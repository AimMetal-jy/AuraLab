import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:auralab/routes/app_routes.dart';
import '../../util/buttons/menu_button.dart';

class DrawerMenu extends StatefulWidget {
  final String userName;
  const DrawerMenu({super.key, required this.userName});

  @override
  State<DrawerMenu> createState() => _DrawerMenuState();
}

class _DrawerMenuState extends State<DrawerMenu> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _blurAnimation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _blurAnimation = Tween<double>(
      begin: 0.0,
      end: 10.0, // 最大模糊值
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    // 初始状态为完全打开
    _animationController.value = 1.0;
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return NotificationListener<DragUpdateNotification>(
          onNotification: (notification) {
            // 计算拖动比例并更新动画控制器
            final drawerWidth = MediaQuery.of(context).size.width / 2; // 更新为1/2屏幕宽度
            final dragDistance = notification.delta.dx;
            
            if (dragDistance < 0) { // 向左拖动（关闭抽屉）
              final newValue = _animationController.value - (dragDistance.abs() / drawerWidth);
              _animationController.value = newValue.clamp(0.0, 1.0);
            }
            return false;
          },
          child: Stack(
            children: [
              // 背景模糊层
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: _blurAnimation.value,
                    sigmaY: _blurAnimation.value,
                  ),
                  child: Container(
                    color: Colors.black.withOpacity(0.1 * _animationController.value),
                  ),
                ),
              ),
              // 抽屉内容
              Drawer(
                width: MediaQuery.of(context).size.width / 2, // 修改为屏幕宽度的1/2
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
                        widget.userName,
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
                ),
              ),
              // 关闭抽屉的手势区域
              Positioned(
                top: 0,
                bottom: 0,
                right: 0,
                width: 20, // 右侧边缘的手势区域宽度
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    if (details.delta.dx < 0) { // 向左拖动（关闭抽屉）
                      final drawerWidth = MediaQuery.of(context).size.width * 0.8;
                      final newValue = _animationController.value - (details.delta.dx.abs() / drawerWidth);
                      _animationController.value = newValue.clamp(0.0, 1.0);
                    }
                  },
                  onHorizontalDragEnd: (details) {
                    // 根据当前动画值和拖动速度决定是完全打开还是关闭抽屉
                    if (_animationController.value < 0.5 || 
                        details.velocity.pixelsPerSecond.dx < -300) {
                      _animationController.animateTo(0.0); // 关闭抽屉
                      Navigator.of(context).pop(); // 关闭抽屉
                    } else {
                      _animationController.animateTo(1.0); // 完全打开抽屉
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// 自定义通知类，用于传递拖动信息
class DragUpdateNotification extends Notification {
  final Offset delta;
  
  DragUpdateNotification(this.delta);
}
