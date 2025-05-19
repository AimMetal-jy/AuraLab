import 'package:flutter/material.dart';
import 'package:auralab/util/widgets/tab/tab_state.dart';
import 'package:auralab/util/widgets/tab/tab_button.dart';
import 'package:auralab/util/buttons/drawer_gesture_detector.dart';
import 'package:auralab/screens/menu/menu.dart';

/// 通用标签页脚手架
/// 在应用中多处复用的页面结构组件
/// 包含AppBar、标签栏和内容区域的标准化页面布局
/// 提供统一的UI风格和交互体验，简化页面开发
class TabbedPageScaffold extends StatelessWidget {
  /// 页面标题文本
  final String title;
  /// 页面标题图标
  final IconData titleIcon;
  /// 标签页标题列表
  final List<String> tabTitles;
  /// 对应的标签页内容组件列表
  final List<Widget> tabPages;
  /// 浮动操作按钮
  final Widget? floatingActionButton;
  /// 用户名称，显示在抽屉菜单中
  final String userName;
  /// 是否显示抽屉菜单
  final bool showDrawer;
  
  const TabbedPageScaffold({
    super.key,
    required this.title,
    required this.titleIcon,
    required this.tabTitles,
    required this.tabPages,
    this.floatingActionButton,
    this.userName = '', // 默认为空字符串
    this.showDrawer = true, // 默认显示抽屉菜单
  }) : assert(tabTitles.length == tabPages.length, '标签数量必须与页面数量相同');

  @override
  Widget build(BuildContext context) {
    return DrawerGestureDetector(
      child: TabState(
        notifier: ValueNotifier<int>(0), // 初始选中第一个标签页
        child: Builder(builder: (context) {
          // 获取当前选中的索引
          final selectedIndex = TabState.of(context);

          // 页面主体使用Scaffold组件
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.grey.shade400, // 设置AppBar背景色
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(titleIcon, color: Colors.black), // 标题图标
                  const SizedBox(width: 5), // 图标和文字间距
                  Text(title, style: const TextStyle(color: Colors.black)), // 标题文字
                  const SizedBox(width: 15), // 右侧间距
                ],
              ),
              centerTitle: true, // 标题居中
              actions: [
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.black), // 搜索图标
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
                    const Divider(height: 1, thickness: 1, color: Colors.grey), // 分隔线
                    // 标签行
                    Container(
                      color: Colors.grey.shade400, // 标签栏背景色
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0), // 内边距
                      child: Row(
                        children: List.generate(
                          tabTitles.length,
                          (index) => Padding(
                            padding: const EdgeInsets.only(right: 20.0), // 标签间距
                            child: TabButton(
                              text: tabTitles[index], // 标签文本
                              isSelected: selectedIndex == index, // 是否选中
                              onTap: () => TabState.switchPage(context, index), // 点击切换页面
                              unselectedColor: Colors.grey.shade400, // 未选中颜色
                            ),
                          ),
                        ),
                      ),
                    ),
                    // 根据选中的索引显示不同的页面内容
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(10), // 内容区域内边距
                        child: tabPages[selectedIndex], // 显示当前选中的页面
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