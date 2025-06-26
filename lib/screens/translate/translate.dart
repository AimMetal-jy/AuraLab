import 'package:flutter/material.dart';
import 'package:auralab/util/widgets/tab/tabpage_scaffold.dart'; // 带标签页的脚手架组件
import 'package:auralab/util/buttons/expandable_action_buttons.dart'; // 可展开的操作按钮组件
import 'package:auralab/screens/translate/translate_display_page.dart';

// 文件数据模型
class TranslateFile {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;

  TranslateFile({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
  });
}

// 全局文件列表管理
class FileManager extends ChangeNotifier {
  static final FileManager _instance = FileManager._internal();
  factory FileManager() => _instance;
  FileManager._internal();
  
  final List<TranslateFile> _files = [];
  
  List<TranslateFile> get files => List.unmodifiable(_files);
  
  void addFile(TranslateFile file) {
    _files.add(file);
    notifyListeners();
  }
  
  void removeFile(String id) {
    _files.removeWhere((file) => file.id == id);
    notifyListeners();
  }
  
  // 静态方法保持向后兼容
  static FileManager get instance => _instance;
}
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
      tabTitles: const ['文件','英译中', ' 中译英 ',],
      // 对应的标签页内容组件
      tabPages: const [
        FavoritesPage(), 
        EnglishToChinesePage(),
        ChineseToEnglishPage(),
      
      ],
    
      // 用户名称，显示在抽屉菜单中
      userName: '大富翁',
      // 可展开的浮动操作按钮，传入添加文件的回调
      floatingActionButton: ExpandableActionButtons(
        onAddText: (title, content) {
          // 创建新文件
          final newFile = TranslateFile(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: title,
            content: content,
            createdAt: DateTime.now(),
          );
          FileManager.instance.addFile(newFile);
        },
      ),
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
              builder: (context) => const TranslateDisplayPage(),
            ),
          );
        },
        child: const Text('进入翻译展示页'),
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
              builder: (context) => const TranslateDisplayPage(),
            ),
          );
        },
        child: const Text('进入翻译展示页'),
      ),
    );
  }
}

/// 文件页面
/// 
/// 显示用户创建的翻译文件列表
class FavoritesPage extends StatefulWidget {
  /// 创建一个FavoritesPage实例
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: FileManager.instance,
        builder: (context, child) {
          return FileManager.instance.files.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.folder_open,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    '暂无文件',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '长按右下角按钮添加新文件',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
               padding: const EdgeInsets.all(16),
               itemCount: FileManager.instance.files.length,
               itemBuilder: (context, index) {
                 final file = FileManager.instance.files[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const Icon(
                      Icons.description,
                      color: Colors.blue,
                    ),
                    title: Text(
                      file.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          file.content.length > 50
                              ? '${file.content.substring(0, 50)}...'
                              : file.content,
                          style: const TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '创建时间: ${file.createdAt.year}-${file.createdAt.month.toString().padLeft(2, '0')}-${file.createdAt.day.toString().padLeft(2, '0')} ${file.createdAt.hour.toString().padLeft(2, '0')}:${file.createdAt.minute.toString().padLeft(2, '0')}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                       icon: const Icon(Icons.delete, color: Colors.red),
                       onPressed: () {
                         FileManager.instance.removeFile(file.id);
                       },
                     ),
                    onTap: () {
                      // 跳转到翻译展示页面
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const TranslateDisplayPage(),
                        ),
                      );
                    },
                  ),
                );
              },
             );
        },
      ),
    );
  }
}



