import 'package:flutter/material.dart';
import 'package:auralab/util/buttons/expandable_action_buttons.dart'; // 可展开的操作按钮组件
import 'package:auralab/util/widgets/tab/tabbed_page_scaffold.dart'; // 带标签页的脚手架组件
import 'package:auralab/screens/notes/subpage/note_list.dart'; // 笔记列表子页面
import 'package:auralab/screens/notes/subpage/note_tags.dart'; // 笔记标签子页面
import 'package:auralab/screens/notes/subpage/note_archive.dart'; // 笔记归档子页面

/// 笔记页面主组件
/// 
/// 使用统一的TabbedPageScaffold实现带标签页的页面布局
/// 包含全部笔记、标签和归档三个子页面，用于管理和查看用户的笔记内容
class Notes extends StatelessWidget {
  /// 创建一个Notes实例
  /// 
  /// super.key为必有格式
  const Notes({super.key});

  @override
  Widget build(BuildContext context) {
    return TabbedPageScaffold(
      // 页面标题
      title: '笔记',
      // 标题图标
      titleIcon: Icons.note_alt,
      // 标签页标题列表
      tabTitles: const ['全部', '标签', '归档'],
      // 对应的标签页内容组件
      tabPages: const [NoteListPage(), NoteTagsPage(), NoteArchivePage()],
      // 可展开的浮动操作按钮
      floatingActionButton: const ExpandableActionButtons(),
      // 用户名称，显示在抽屉菜单中
      userName: 'AimMetal',
      // 是否显示抽屉菜单
      showDrawer: true,
    );
  }
}