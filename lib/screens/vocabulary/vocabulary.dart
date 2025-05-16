import 'package:flutter/material.dart';
import 'package:auralab/util/widgets/tab/tabbed_page_scaffold.dart';
import 'package:auralab/util/buttons/expandable_action_buttons.dart';

/// 生词本页面主组件
/// 包含AppBar、标签栏和内容区域
class VocabularyPage extends StatelessWidget {
  const VocabularyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return TabbedPageScaffold(
      title: '生词本',
      titleIcon: Icons.book,
      tabTitles: const ['全部', '标记', '分类'],
      tabPages: const [
        AllWordsPage(),
        MarkedWordsPage(),
        CategoriesPage(),
      ],
      userName: 'AimMetal',
      floatingActionButton: const ExpandableActionButtons(),
    );
  }
}

/// 全部单词页面
class AllWordsPage extends StatelessWidget {
  const AllWordsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('全部单词内容区域'),
    );
  }
}

/// 标记单词页面
class MarkedWordsPage extends StatelessWidget {
  const MarkedWordsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('标记单词内容区域'),
    );
  }
}

/// 分类页面
class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('分类内容区域'),
    );
  }
}
