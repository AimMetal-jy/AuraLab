import 'package:flutter/material.dart';
import 'package:auralab/util/widgets/tab/tab_state.dart';
import 'package:auralab/util/widgets/tab/tab_button.dart';
import 'package:auralab/util/buttons/drawer_gesture_detector.dart';
import 'package:auralab/screens/menu/menu.dart';

/// 通用标签页脚手架
/// 在应用中多处复用的页面结构组件
/// 包含AppBar、标签栏和内容区域的标准化页面布局
class TabbedPageScaffold extends StatelessWidget {
  final String title;
  final IconData titleIcon;
  final List<String> tabTitles;
  final List<Widget> tabPages;
  final Widget? floatingActionButton;
  final String userName;
  final bool showDrawer;
  
  const TabbedPageScaffold({
    super.key,
    required this.title,
    required this.titleIcon,
    required this.tabTitles,
    required this.tabPages,
    this.floatingActionButton,
    this.userName = '',
    this.showDrawer = true,
  }) : assert(tabTitles.length == tabPages.length, '标签数量必须与页面数量相同');

  @override
  Widget build(BuildContext context) {
    return DrawerGestureDetector(
      child: TabState(
        notifier: ValueNotifier<int>(0),
        child: Builder(builder: (context) {
          // 获取当前选中的索引
          final selectedIndex = TabState.of(context);

          // 页面主体使用Scaffold组件
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.grey.shade400,
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(titleIcon, color: Colors.black),
                  const SizedBox(width: 5),
                  Text(title, style: const TextStyle(color: Colors.black)),
                  const SizedBox(width: 15),
                ],
              ),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.black),
                  onPressed: () {
                    // TODO: 实现搜索功能
                  },
                ),
              ],
            ),
            body: Stack(
              children: [
                // 主要内容区域
                Column(
                  children: [
                    const Divider(height: 1, thickness: 1, color: Colors.grey),
                    // 标签行
                    Container(
                      color: Colors.grey.shade400,
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      child: Row(
                        children: List.generate(
                          tabTitles.length,
                          (index) => Padding(
                            padding: const EdgeInsets.only(right: 20.0),
                            child: TabButton(
                              text: tabTitles[index],
                              isSelected: selectedIndex == index,
                              onTap: () => TabState.switchPage(context, index),
                              unselectedColor: Colors.grey.shade400,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // 根据选中的索引显示不同的页面内容
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: tabPages[selectedIndex],
                      ),
                    )
                  ],
                ),

                // 浮动按钮
                if (floatingActionButton != null) floatingActionButton!,
              ],
            ),
            drawer: showDrawer ? DrawerMenu(userName: userName) : null,
          );
        }),
      ),
    );
  }
}