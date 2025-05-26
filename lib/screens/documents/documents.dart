import 'package:flutter/material.dart';
import 'package:auralab/util/buttons/expandable_action_buttons.dart'; // 可展开的操作按钮组件
import 'package:auralab/screens/menu/file.dart'; // 文件子页面
import 'package:auralab/screens/menu/author.dart'; // 作者子页面
import 'package:auralab/screens/menu/playlist.dart'; // 歌单子页面
import 'package:auralab/util/widgets/tab/tabpage_scaffold.dart'; // 带标签页的脚手架组件// 抽屉菜单组件

class DocumentsPage extends StatefulWidget {
  const DocumentsPage({super.key});

  @override
  State<DocumentsPage> createState() => _DocumentsPageState();
}

class _DocumentsPageState extends State<DocumentsPage>{
  @override
  Widget build(BuildContext context) {
    return TabPageScaffold(
      title: '文档',
      titleIcon: Icons.book,
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
