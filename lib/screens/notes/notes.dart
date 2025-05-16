import 'package:flutter/material.dart';
import 'package:auralab/util/buttons/expandable_action_buttons.dart';
import 'package:auralab/util/widgets/tab/tabbed_page_scaffold.dart';
import 'package:auralab/screens/notes/subpage/note_list.dart';
import 'package:auralab/screens/notes/subpage/note_tags.dart';
import 'package:auralab/screens/notes/subpage/note_archive.dart';

/// 笔记页面主组件，使用统一的TabbedPageScaffold
class Notes extends StatelessWidget {
  const Notes({super.key});

  @override
  Widget build(BuildContext context) {
    return TabbedPageScaffold(
      title: '笔记',
      titleIcon: Icons.note_alt,
      tabTitles: const ['全部', '标签', '归档'],
      tabPages: const [NoteListPage(), NoteTagsPage(), NoteArchivePage()],
      floatingActionButton: const ExpandableActionButtons(),
      userName: 'AimMetal',
      showDrawer: true,
    );
  }
}