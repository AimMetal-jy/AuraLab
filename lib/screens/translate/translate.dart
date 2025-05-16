import 'package:flutter/material.dart';
import 'package:auralab/util/widgets/tab/tabbed_page_scaffold.dart';
import 'package:auralab/util/buttons/expandable_action_buttons.dart';

/// 翻译练习页面主组件
/// 包含AppBar、标签栏和内容区域
class TranslatePage extends StatelessWidget {
  const TranslatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return TabbedPageScaffold(
      title: '翻译练习',
      titleIcon: Icons.translate,
      tabTitles: const ['英译中', '中译英', '收藏'],
      tabPages: const [
        EnglishToChinesePage(),
        ChineseToEnglishPage(),
        FavoritesPage(),
      ],
      userName: 'AimMetal',
      floatingActionButton: const ExpandableActionButtons(),
    );
  }
}

/// 英译中页面
class EnglishToChinesePage extends StatelessWidget {
  const EnglishToChinesePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('英译中内容区域'),
    );
  }
}

/// 中译英页面
class ChineseToEnglishPage extends StatelessWidget {
  const ChineseToEnglishPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('中译英内容区域'),
    );
  }
}

/// 收藏页面
class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('收藏内容区域'),
    );
  }
}
