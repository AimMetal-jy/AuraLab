import 'package:flutter/material.dart';
import 'package:auralab/util/buttons/drawer_gesture_detector.dart';
import 'package:auralab/screens/menu/menu.dart';

/// 通用标签页脚手架
/// 在应用中多处复用的页面结构组件
/// 包含AppBar、标签栏和内容区域的标准化页面布局
/// 提供统一的UI风格和交互体验，简化页面开发
class TabPageScaffold extends StatefulWidget {
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

  const TabPageScaffold({
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
  State<TabPageScaffold> createState() => _TabPageScaffoldState();
}

class _TabPageScaffoldState extends State<TabPageScaffold>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: widget.tabTitles.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DrawerGestureDetector(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey.shade400, // 设置AppBar背景色
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.titleIcon, color: Colors.black), // 标题图标
              const SizedBox(width: 5), // 图标和文字间距
              Text(widget.title,
                  style: const TextStyle(color: Colors.black)), // 标题文字
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
          bottom: TabBar(
            controller: _tabController,
            tabs: widget.tabTitles.map((title) => Tab(text: title)).toList(),
            labelColor: Colors.black, // 选中标签文字颜色
            unselectedLabelColor: Colors.white, // 未选中标签文字颜色
            indicator: BoxDecoration(
              color: Colors.white, // 选中标签背景色
              borderRadius: BorderRadius.circular(15), // 圆角边框
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            labelPadding: const EdgeInsets.symmetric(horizontal: 10),
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            splashFactory: NoSplash.splashFactory, // 禁用点击水波纹效果
            overlayColor: WidgetStateProperty.all(Colors.transparent), // 禁用点击覆盖层
          ),
        ),
        body: Stack(
          children: [
            // 主要内容区域
            Padding(
              padding: const EdgeInsets.all(10), // 内容区域内边距
              child: TabBarView(
                controller: _tabController,
                children: widget.tabPages,
              ),
            ),
            // 浮动按钮
            if (widget.floatingActionButton != null)
              widget.floatingActionButton!,
          ],
        ),
        drawer:
            widget.showDrawer ? DrawerMenu(userName: widget.userName) : null,
        drawerEdgeDragWidth: MediaQuery.of(context).size.width / 3,
      ),
    );
  }
}
