import 'package:flutter/material.dart';
import 'package:auralab/util/buttons/expandable_action_buttons.dart';
import 'package:auralab/screens/listening/subpage/file.dart';
import 'package:auralab/screens/listening/subpage/author.dart';
import 'package:auralab/screens/listening/subpage/playlist.dart';
import 'package:auralab/util/widgets/tab/tabbed_page_scaffold.dart';


/// 听力页面主组件，使用统一的TabbedPageScaffold
class ListeningPage extends StatelessWidget {
  const ListeningPage({super.key});

  @override
  Widget build(BuildContext context) {
    return TabbedPageScaffold(
      title: '听力',
      titleIcon: Icons.headphones,
      tabTitles: const ['文件', '作者', '歌单'],
      tabPages: const [FilePage(), AuthorPage(), PlaylistPage()],
      floatingActionButton: const ExpandableActionButtons(),
      userName: 'AimMetal',
      showDrawer: true,
    );
  }
}

/// 卡片内容组件
/// 展示听力内容卡片列表
class CardDemo extends StatefulWidget {
  const CardDemo({super.key});

  @override
  State<CardDemo> createState() => _CardDemoState();
}

/// 卡片内容组件状态类
class _CardDemoState extends State<CardDemo> {
  @override
  Widget build(BuildContext context) {
    return ListView(children: const [
      Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          elevation: 10,
          )
    ]);
  }
}
