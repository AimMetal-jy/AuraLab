import 'package:flutter/material.dart';
import 'package:auralab/util/buttons/expandable_action_buttons.dart'; // 可展开的操作按钮组件
import 'package:auralab/screens/listening/subpage/file.dart'; // 文件子页面
import 'package:auralab/screens/listening/subpage/author.dart'; // 作者子页面
import 'package:auralab/screens/listening/subpage/playlist.dart'; // 歌单子页面
import 'package:auralab/util/widgets/tab/tabbed_page_scaffold.dart'; // 带标签页的脚手架组件


/// 听力页面主组件
/// 
/// 使用统一的TabbedPageScaffold实现带标签页的页面布局
/// 包含文件、作者和歌单三个子页面，用于展示不同类型的听力内容
class ListeningPage extends StatelessWidget {
  /// 创建一个ListeningPage实例
  /// 
  /// super.key为必有格式
  const ListeningPage({super.key});

  @override
  Widget build(BuildContext context) {
    return TabbedPageScaffold(
      // 页面标题
      title: '听力',
      // 标题图标
      titleIcon: Icons.headphones,
      // 标签页标题列表
      tabTitles: const ['文件', '作者', '歌单'],
      // 对应的标签页内容组件
      tabPages: const [FilePage(), AuthorPage(), PlaylistPage()],
      // 可展开的浮动操作按钮
      floatingActionButton: const ExpandableActionButtons(),
      // 用户名称，显示在抽屉菜单中
      userName: 'AimMetal',
      // 是否显示抽屉菜单
      showDrawer: true,
    );
  }
}

/// 卡片内容组件
/// 
/// 展示听力内容卡片列表，用于在听力页面中显示各种听力内容项
/// 使用StatefulWidget以支持后续可能的交互状态变化
class CardDemo extends StatefulWidget {
  /// 创建一个CardDemo实例
  /// 
  /// super.key为必有格式
  const CardDemo({super.key});

  @override
  State<CardDemo> createState() => _CardDemoState();
}

/// 卡片内容组件状态类
/// 
/// 管理CardDemo组件的状态和UI构建
class _CardDemoState extends State<CardDemo> {
  @override
  Widget build(BuildContext context) {
    // 使用ListView显示卡片列表，支持滚动
    return ListView(children: const [
      // 创建一个带圆角和阴影的卡片
      Card(
          // 设置卡片形状为圆角矩形
          shape: RoundedRectangleBorder(
            // 所有边角都使用20像素的圆角
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          // 设置卡片阴影高度
          elevation: 10,
          // 注意：这里缺少卡片内容，可能需要后续添加
          )
    ]);
  }
}
