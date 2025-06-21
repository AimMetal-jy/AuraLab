import 'package:flutter/material.dart';
import 'package:auralab/util/widgets/tab/tabpage_scaffold.dart'; // 带标签页的脚手架组件 // 可展开的操作按钮组件

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
      tabTitles: const ['文件', '作者', '歌单','自定义分类'],
      // 对应的标签页内容组件
      tabPages: const [
        AllWordsPage(),
        MarkedWordsPage(),
        CategoriesPage(),
        CategoriesPage()
      ],
      // 用户名称，显示在抽屉菜单中
      userName: 'Whitersmile',
      // 可展开的浮动操作按钮
      //floatingActionButton: const ExpandableActionButtons(),
      // 注意：这里没有设置showDrawer属性，默认不显示抽屉菜单
    );
  }
}



class AllWordsPage extends StatefulWidget {
  /// 创建一个AllWordsPage实例
  /// 
  /// super.key为必有格式
  const AllWordsPage({super.key});

  @override
  State<AllWordsPage> createState() => _AllWordsPageState();
}

class _AllWordsPageState extends State<AllWordsPage> {
  bool _isCardMode = true; // 控制显示模式：true为卡片模式，false为原文模式
  List<Map<String, String>> _vocabularyList = []; // 存储词汇列表
  String _originalText = ''; // 存储原文

  @override
  void initState() {
    super.initState();
    // 这里将来会添加从文件读取数据的逻辑
    // 暂时使用模拟数据
    _mockData();
  }

  // 模拟数据方法
  void _mockData() {
    _originalText = '这是一段示例文本，包含了一些英文单词如 apple, banana, orange 等。';
    
    _vocabularyList = [
      {'word': 'apple', 'meaning': '苹果', 'category': '水果'},
      {'word': 'banana', 'meaning': '香蕉', 'category': '水果'},
      {'word': 'orange', 'meaning': '橙子', 'category': '水果'},
      {'word': 'grape', 'meaning': '葡萄', 'category': '水果'},
      {'word': 'strawberry', 'meaning': '草莓', 'category': '水果'},
      {'word': 'peach', 'meaning': '桃子', 'category': '水果'},
      {'word': 'watermelon', 'meaning': '西瓜', 'category': '水果'},
      {'word': 'pineapple', 'meaning': '菠萝', 'category': '水果'},
      {'word': 'pear', 'meaning': '梨子', 'category': '水果'},
      {'word': 'cherry', 'meaning': '樱桃', 'category': '水果'},
      {'word': 'mango', 'meaning': '芒果', 'category': '水果'},
    ];
  }

  // 显示长按菜单的方法
  void _showOptionsMenu(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('修改释义'),
                onTap: () {
                  Navigator.pop(context);
                  // 这里将来会添加修改释义的逻辑
                },
              ),
              ListTile(
                leading: const Icon(Icons.category),
                title: const Text('添加到分类'),
                onTap: () {
                  Navigator.pop(context);
                  // 这里将来会添加分类的逻辑
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('删除生词'),
                onTap: () {
                  Navigator.pop(context);
                  // 这里将来会添加删除的逻辑
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // 构建卡片视图
  Widget _buildCardView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _vocabularyList.length,
      itemBuilder: (context, index) {
        return _buildVocabularyCard(index);
      },
    );
  }

  // 构建单个词汇卡片
  Widget _buildVocabularyCard(int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 2.0,
      child: InkWell(
        onTap: () {
          // 点击展开/收起释义的逻辑
          setState(() {
            // 这里可以添加展开/收起释义的状态变量
            // 暂时只是一个占位，实际实现时需要添加状态变量
          });
        },
        onLongPress: () {
          _showOptionsMenu(context, index);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _vocabularyList[index]['word'] ?? '',
                style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              // 这里可以添加一个条件来控制释义的显示/隐藏
              // 暂时默认显示释义
              Text(
                _vocabularyList[index]['meaning'] ?? '',
                style: const TextStyle(fontSize: 16.0),
              ),
              const SizedBox(height: 4.0),
              Text(
                '分类: ${_vocabularyList[index]['category'] ?? '未分类'}',
                style: const TextStyle(fontSize: 14.0, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 构建原文视图
  Widget _buildOriginalTextView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        _originalText,
        style: const TextStyle(fontSize: 16.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 添加视图切换按钮
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isCardMode = true;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isCardMode ? Colors.white : Colors.grey,
                  splashFactory: NoSplash.splashFactory,
                ),
                child: const Text('卡片视图'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isCardMode = false;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: !_isCardMode ? Colors.white : Colors.grey,
                  splashFactory: NoSplash.splashFactory,
                ),
                child: const Text('原文视图'),
              ),
            ],
          ),
        ),
        // 主要内容区域
        Expanded(
          child: _isCardMode ? _buildCardView() : _buildOriginalTextView(),
        ),
      ],
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
  const CustomCategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: null,
    );
  }
}