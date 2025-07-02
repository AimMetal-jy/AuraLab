import 'package:flutter/material.dart';
import '../../../widgets/music_player_bar.dart';
import '../../../screens/drawer/drawer.dart';

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

  /// 是否显示底部音乐播放器
  final bool showMusicPlayer;

  const TabPageScaffold({
    super.key,
    required this.title,
    required this.titleIcon,
    required this.tabTitles,
    required this.tabPages,
    this.floatingActionButton,
    this.userName = '', // 默认为空字符串
    this.showDrawer = true, // 默认显示抽屉菜单
    this.showMusicPlayer = true, // 默认显示音乐播放器
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
    return DefaultTabController(
      length: widget.tabPages.length,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 0,
          title: Text(
            widget.title,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          iconTheme: IconThemeData(
            color: Theme.of(context).colorScheme.onSurface,
          ),
          bottom: TabBar(
            controller: _tabController,
            tabs: widget.tabTitles.map((title) => Tab(text: title)).toList(),
            labelColor: Theme.of(context).colorScheme.onSurface,
            unselectedLabelColor:
                Theme.of(context).colorScheme.onSurface.withAlpha(153),
            indicator: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withAlpha(51),
              borderRadius: BorderRadius.circular(15), // 圆角边框
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            labelPadding: const EdgeInsets.symmetric(horizontal: 10),
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            splashFactory: NoSplash.splashFactory, // 禁用点击水波纹效果
            overlayColor:
                WidgetStateProperty.all(Colors.transparent), // 禁用点击覆盖层
          ),
        ),
        body: Stack(
          children: [
            // 主要内容区域
            Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(10), // 内容区域内边距
                    child: TabBarView(
                      controller: _tabController,
                      children: widget.tabPages,
                    ),
                  ),
                ),
                // 底部播放器区域
                if (widget.showMusicPlayer)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0, left: 16.0, right: 16.0),
                    child: SizedBox(
                      height: 80, // 与MusicPlayerBar高度一致
                      child: const MusicPlayerBar(
                        hasAudio: false, // 默认无音频状态
                      ),
                    ),
                  ),
              ],
            ),
            // 悬浮按钮 - 使用Positioned定位到右下角
            if (widget.floatingActionButton != null)
              Positioned(
                right: 16,
                bottom: widget.showMusicPlayer ? 92 : 16, // 如果有播放器则在播放器上方
                child: widget.floatingActionButton!,
              ),
          ],
        ),
        drawer:
            widget.showDrawer ? DrawerMenu(userName: widget.userName) : null,
        drawerEdgeDragWidth: MediaQuery.of(context).size.width / 3,
      ),
    );
    
  }
}
