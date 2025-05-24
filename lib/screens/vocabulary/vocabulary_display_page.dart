import 'package:flutter/material.dart';

class VocabularyDisplayPage extends StatefulWidget {
  final String fileName; // 文件名参数
  
  const VocabularyDisplayPage({Key? key, required this.fileName}) : super(key: key);

  @override
  State<VocabularyDisplayPage> createState() => _VocabularyDisplayPageState();
}

class _VocabularyDisplayPageState extends State<VocabularyDisplayPage> {
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
                leading: Icon(Icons.edit),
                title: Text('修改释义'),
                onTap: () {
                  Navigator.pop(context);
                  // 这里将来会添加修改释义的逻辑
                },
              ),
              ListTile(
                leading: Icon(Icons.category),
                title: Text('添加到分类'),
                onTap: () {
                  Navigator.pop(context);
                  // 这里将来会添加分类的逻辑
                },
              ),
              ListTile(
                leading: Icon(Icons.delete),
                title: Text('删除生词'),
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
      padding: EdgeInsets.all(16.0),
      itemCount: _vocabularyList.length,
      itemBuilder: (context, index) {
        return _buildVocabularyCard(index);
      },
    );
  }

  // 构建单个词汇卡片
  Widget _buildVocabularyCard(int index) {
    return Card(
      margin: EdgeInsets.only(bottom: 16.0),
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
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _vocabularyList[index]['word'] ?? '',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.0),
              // 这里可以添加一个条件来控制释义的显示/隐藏
              // 暂时默认显示释义
              Text(
                _vocabularyList[index]['meaning'] ?? '',
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 4.0),
              Text(
                '分类: ${_vocabularyList[index]['category'] ?? '未分类'}',
                style: TextStyle(fontSize: 14.0, color: Colors.grey),
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
      padding: EdgeInsets.all(16.0),
      child: Text(
        _originalText,
        style: TextStyle(fontSize: 16.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(widget.fileName),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'toggle_view') {
                setState(() {
                  _isCardMode = !_isCardMode;
                });
              } else if (value == 'export') {
                // 这里将来会添加导出生词表的逻辑
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'toggle_view',
                child: Text(_isCardMode ? '切换到原文视图' : '切换到卡片视图'),
              ),
              PopupMenuItem<String>(
                value: 'export',
                child: Text('导出生词表'),
              ),
            ],
          ),
        ],
      ),
      body: _isCardMode ? _buildCardView() : _buildOriginalTextView(),
    );
  }
}