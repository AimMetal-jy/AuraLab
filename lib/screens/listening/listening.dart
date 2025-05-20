import 'package:flutter/material.dart';
import 'package:auralab/util/buttons/expandable_action_buttons.dart'; // 可展开的操作按钮组件
import 'package:auralab/screens/listening/subpage/file.dart'; // 文件子页面
import 'package:auralab/screens/listening/subpage/author.dart'; // 作者子页面
import 'package:auralab/screens/listening/subpage/playlist.dart'; // 歌单子页面
import 'package:auralab/util/widgets/tab/tabpage_scaffold.dart'; // 带标签页的脚手架组件// 抽屉菜单组件

class ListeningPage extends StatefulWidget {
  const ListeningPage({super.key});

  @override
  State<ListeningPage> createState() => _ListeningPageState();
}

class _ListeningPageState extends State<ListeningPage>{
  @override
  Widget build(BuildContext context) {
    return TabPageScaffold(
      title: '听力',
      titleIcon: Icons.headphones,
      tabTitles: const ['文件', '作者', '歌单'],
      tabPages: const [
        FilePage(),
        AuthorPage(),
        PlaylistPage(),
      ],
      floatingActionButton: const ExpandableActionButtons(),
      userName: 'AimMetal',
      showDrawer: true,
    );
  }
}
