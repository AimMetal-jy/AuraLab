import 'package:flutter/material.dart';
import 'package:auralab/util/widgets/tab/tabpage_scaffold.dart'; // 带标签页的脚手架组件
import 'package:auralab/util/buttons/expandable_action_buttons.dart'; // 可展开的操作按钮组件
import 'package:auralab/screens/vocabulary/vocabulary_display_page.dart'; 

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
      tabTitles: const ['文件', '作者', '歌单'],
      // 对应的标签页内容组件
      tabPages: const [
        AllWordsPage(),
        MarkedWordsPage(),
        CategoriesPage(),
      ],
      // 用户名称，显示在抽屉菜单中
      userName: 'Whitersmile',
      // 可展开的浮动操作按钮
      floatingActionButton: const ExpandableActionButtons(),
      // 注意：这里没有设置showDrawer属性，默认不显示抽屉菜单
    );
  }
}



class AllWordsPage extends StatelessWidget {
  /// 创建一个AllWordsPage实例
  /// 
  /// super.key为必有格式
  const AllWordsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 居中显示按钮，点击后跳转到单词详情页面
    return Center(
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const VocabularyDisplayPage(
                fileName: '示例单词文件',
              ),
            ),
          );
        },
        child: const Text('查看单词详情'),
      ),
    );
  }
}













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

class CustomCategoriesPage extends StatelessWidget {
  const CustomCategoriesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: null,
    );
  }
}