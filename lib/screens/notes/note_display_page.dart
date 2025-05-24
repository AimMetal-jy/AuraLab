import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class NoteDisplayPage extends StatefulWidget {
  final String title; // 标题参数
  
  const NoteDisplayPage({Key? key, required this.title}) : super(key: key);

  @override
  _NoteDisplayPageState createState() => _NoteDisplayPageState();
}

class _NoteDisplayPageState extends State<NoteDisplayPage> {
  bool _isCodeMode = false;
  String _searchQuery = '';
  final List<Map<String, String>> _notes = [
    {
      'content': '# 标题1\n这是第一条批注的正文内容',
      'rawContent': '# 标题1\n这是第一条批注的正文内容',
    },
    {
      'content': '## 标题2\n- 列表项1\n- 列表项2\n- 列表项3',
      'rawContent': '## 标题2\n- 列表项1\n- 列表项2\n- 列表项3',
    },
    {
      'content': '### 代码示例\n```dart\nvoid main() {\n  print("Hello");\n}\n```',
      'rawContent': '### 代码示例\n```dart\nvoid main() {\n  print("Hello");\n}\n```',
    },
    {
      'content': '**加粗文本**和*斜体文本*的组合使用示例',
      'rawContent': '**加粗文本**和*斜体文本*的组合使用示例',
    },
    {
      'content': '> 引用文本\n> 多行引用\n> 第三行引用',
      'rawContent': '> 引用文本\n> 多行引用\n> 第三行引用',
    },
    {
      'content': '[链接示例](https://flutter.dev)和![图片](image.png)',
      'rawContent': '[链接示例](https://flutter.dev)和![图片](image.png)',
    },
    {
      'content': '表格示例\n| 列1 | 列2 |\n|----|----|\n| 数据1 | 数据2 |',
      'rawContent': '表格示例\n| 列1 | 列2 |\n|----|----|\n| 数据1 | 数据2 |',
    },
    {
      'content': '`行内代码`和~~删除线~~的混合使用',
      'rawContent': '`行内代码`和~~删除线~~的混合使用',
    },
    {
      'content': '1. 有序列表\n2. 第二项\n3. 第三项',
      'rawContent': '1. 有序列表\n2. 第二项\n3. 第三项',
    },
    {
      'content': '混合格式:\n# 标题\n- 列表\n  - 嵌套列表\n> 引用\n`代码`',
      'rawContent': '混合格式:\n# 标题\n- 列表\n  - 嵌套列表\n> 引用\n`代码`',
    },
  ];

  List<Map<String, String>> get _filteredNotes {
    if (_searchQuery.isEmpty) {
      return _notes;
    }
    return _notes.where((note) =>
        note['content']!.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: TextField(
            decoration: InputDecoration(
              hintText: '搜索批注...',
              prefixIcon: const Icon(Icons.search, size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 0.0),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(_isCodeMode ? Icons.visibility : Icons.code),
            onPressed: () {
              setState(() {
                _isCodeMode = !_isCodeMode;
              });
            },
            tooltip: _isCodeMode ? '预览模式' : '代码模式',
          ),
        ],
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _filteredNotes.length + 1, // +1 for title
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Text(
                widget.title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }
          final note = _filteredNotes[index - 1];
          return _buildNoteCard(note, index - 1);
        },
      ),
    );
  }

  Widget _buildNoteCard(Map<String, String> note, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: 2.0,
      child: InkWell(
        onLongPress: () => _showCardOptions(index),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _isCodeMode
              ? SelectableText(
                  note['rawContent']!,
                  style: const TextStyle(fontFamily: 'monospace'),
                )
              : MarkdownBody(
                  data: note['content']!,
                  selectable: true,
                ),
        ),
      ),
    );
  }

  void _showCardOptions(int index) {
    final ScaffoldMessengerState scaffoldMessenger = ScaffoldMessenger.of(context);
    
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.category),
                title: const Text('添加到自定义分类'),
                onTap: () {
                  Navigator.pop(context);
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(content: Text('添加到自定义分类（功能暂未实现）')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.volume_up),
                title: const Text('朗读/不朗读该卡片'),
                onTap: () {
                  Navigator.pop(context);
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(content: Text('朗读/不朗读该卡片（功能暂未实现）')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('删除该卡片'),
                onTap: () {
                  Navigator.pop(context);
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(content: Text('删除该卡片（功能暂未实现）')),
                  );
                },
              ),
              ListTile(
                leading: Icon(_isCodeMode ? Icons.visibility : Icons.code),
                title: Text(_isCodeMode ? '切换到预览模式' : '切换到代码模式'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _isCodeMode = !_isCodeMode;
                  });
                },
              ),
              ListTile(
                leading: const Icon(Icons.add),
                title: const Text('添加自定义功能'),
                onTap: () {
                  Navigator.pop(context);
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(content: Text('添加自定义功能（功能暂未实现）')),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}