import 'package:flutter/material.dart';
import 'package:auralab/util/widgets/tab/tabpage_scaffold.dart'; // 带标签页的脚手架组件
import 'package:auralab/util/buttons/expandable_action_buttons.dart'; // 可展开的操作按钮组件
import 'package:auralab/screens/translate/translate_display_page.dart';
/// 翻译练习页面主组件
/// 
/// 使用统一的TabPageScaffold实现带标签页的页面布局
/// 包含英译中、中译英和收藏三个子页面，用于提供不同方向的翻译练习功能
class TranslatePage extends StatelessWidget {
  /// 创建一个TranslatePage实例
  /// 
  /// super.key为必有格式
  const TranslatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return TabPageScaffold(
      // 页面标题
      title: '翻译练习',
      // 标题图标
      titleIcon: Icons.translate,
      // 标签页标题列表
      tabTitles: const ['文件', '作者', '歌单','自定义分类'],
      // 对应的标签页内容组件
      tabPages: const [
        EnglishToChinesePage(),
        ChineseToEnglishPage(),
        FavoritesPage(),
        FavoritesPage()
      ],
    
      // 用户名称，显示在抽屉菜单中
      userName: '大富翁',
      // 可展开的浮动操作按钮
      floatingActionButton: const ExpandableActionButtons(),
      // 注意：这里没有设置showDrawer属性，默认不显示抽屉菜单
    );
  }
}

/// 英译中页面
/// 
/// 提供英语翻译为中文的练习功能
/// 目前显示占位内容，等待实际功能实现
class EnglishToChinesePage extends StatelessWidget {
  /// 创建一个EnglishToChinesePage实例
  /// 
  /// super.key为必有格式
  const EnglishToChinesePage({super.key});

  @override
  Widget build(BuildContext context) {
    // 居中显示占位文本
    return Center(
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => TranslateDisplayPage(),
            ),
          );
        },
        child: Text('进入翻译展示页'),
      ),
    );
  }
}

/// 中译英页面
/// 
/// 提供中文翻译为英语的练习功能
/// 目前显示占位内容，等待实际功能实现
class ChineseToEnglishPage extends StatelessWidget {
  /// 创建一个ChineseToEnglishPage实例
  /// 
  /// super.key为必有格式
  const ChineseToEnglishPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => TranslateDisplayPage(),
            ),
          );
        },
        child: Text('进入翻译展示页'),
      ),
    );
  }
}

/// 收藏页面
/// 
/// 显示用户收藏的翻译内容
/// 目前显示占位内容，等待实际功能实现
class FavoritesPage extends StatelessWidget {
  /// 创建一个FavoritesPage实例
  /// 
  /// super.key为必有格式
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 居中显示占位文本
    return const Center(
      child: Text('收藏内容区域'),
    );
  }
}



