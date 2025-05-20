import 'package:flutter/material.dart';
import 'package:auralab/util/widgets/tab/tabpage_scaffold.dart'; // 带标签页的脚手架组件
import 'package:auralab/util/buttons/expandable_action_buttons.dart'; // 可展开的操作按钮组件

/// 生词本页面主组件
/// 
/// 使用统一的TabPageScaffold实现带标签页的页面布局
/// 包含全部单词、标记单词和分类三个子页面，用于管理和学习用户的生词
class VocabularyPage extends StatelessWidget {
  /// 创建一个VocabularyPage实例
  /// 
  /// super.key为必有格式
  const VocabularyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return TabPageScaffold(
      // 页面标题
      title: '生词本',
      // 标题图标
      titleIcon: Icons.book,
      // 标签页标题列表
      tabTitles: const ['全部', '标记', '分类'],
      // 对应的标签页内容组件
      tabPages: const [
        AllWordsPage(),
        MarkedWordsPage(),
        CategoriesPage(),
      ],
      // 用户名称，显示在抽屉菜单中
      userName: '大饼象男',
      // 可展开的浮动操作按钮
      floatingActionButton: const ExpandableActionButtons(),
      // 注意：这里没有设置showDrawer属性，默认不显示抽屉菜单
    );
  }
}

/// 全部单词页面
/// 
/// 显示用户添加的所有生词
/// 目前显示占位内容，等待实际功能实现
class AllWordsPage extends StatelessWidget {
  /// 创建一个AllWordsPage实例
  /// 
  /// super.key为必有格式
  const AllWordsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 居中显示占位文本
    return const Center(
      child: Text('全部单词内容区域'),
    );
  }
}

/// 标记单词页面
/// 
/// 显示用户特别标记的生词，如重点词汇、难记词汇等
/// 目前显示占位内容，等待实际功能实现
class MarkedWordsPage extends StatelessWidget {
  /// 创建一个MarkedWordsPage实例
  /// 
  /// super.key为必有格式
  const MarkedWordsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 居中显示占位文本
    return const Center(
      child: Text('标记单词内容区域'),
    );
  }
}

/// 分类页面
/// 
/// 按照不同类别显示生词，如学科分类、难度分类等
/// 目前显示占位内容，等待实际功能实现
class CategoriesPage extends StatelessWidget {
  /// 创建一个CategoriesPage实例
  /// 
  /// super.key为必有格式
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 居中显示占位文本
    return const Center(
      child: Text('分类内容区域'),
    );
  }
}
