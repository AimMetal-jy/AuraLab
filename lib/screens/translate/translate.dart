import 'package:flutter/material.dart';
import 'package:auralab/util/widgets/tab/tabpage_scaffold.dart'; // 带标签页的脚手架组件
import 'package:auralab/util/buttons/expandable_action_buttons.dart'; // 可展开的操作按钮组件
import 'package:auralab/screens/translate/translate_display_page.dart';
import 'package:auralab/services/database_service.dart';

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
  final DatabaseService _databaseService = DatabaseService();
  bool _isInitialized = false;
  
  List<TranslateFile> get files => List.unmodifiable(_files);
  
  /// 初始化文件管理器，从数据库加载数据
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      final filesFromDb = await _databaseService.getTranslateFiles();
      _files.clear();
      _files.addAll(filesFromDb);
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      print('初始化文件管理器失败: $e');
    }
  }
  
  /// 添加文件并保存到数据库
  Future<void> addFile(TranslateFile file) async {
    try {
      await _databaseService.saveTranslateFile(file);
      _files.add(file);
      notifyListeners();
    } catch (e) {
      print('保存文件失败: $e');
      rethrow;
    }
  }
  
  /// 删除文件并从数据库移除
  Future<void> removeFile(String id) async {
    try {
      // 先删除文件相关的所有卡片
      await _databaseService.deleteCardInstancesByFileId(id);
      // 再删除文件本身
      await _databaseService.deleteTranslateFile(id);
      _files.removeWhere((file) => file.id == id);
      notifyListeners();
    } catch (e) {
      print('删除文件失败: $e');
      rethrow;
    }
  }
  
  /// 更新文件并保存到数据库
  Future<void> updateFile(TranslateFile file) async {
    try {
      await _databaseService.updateTranslateFile(file);
      final index = _files.indexWhere((f) => f.id == file.id);
      if (index != -1) {
        _files[index] = file;
        notifyListeners();
      }
    } catch (e) {
      print('更新文件失败: $e');
      rethrow;
    }
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
        onAddText: (title) async {
          // 创建新文件
          final newFile = TranslateFile(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: title,
            content: '', // 内容设为空字符串
            createdAt: DateTime.now(),
          );
          try {
            await FileManager.instance.addFile(newFile);
          } catch (e) {
            // 可以在这里添加错误处理，比如显示SnackBar
            print('添加文件失败: $e');
          }
        },
        onAddFile: (title) async {
          // 先初始化FileManager以确保从数据库加载了现有文件
          await FileManager.instance.initialize();
          
          // 检查是否已有同名文件存在
          TranslateFile? existingFile;
          try {
            existingFile = FileManager.instance.files
                .firstWhere((file) => file.title == title);
          } catch (e) {
            // 没有找到同名文件，existingFile保持为null
          }
          
          TranslateFile targetFile;
          if (existingFile != null) {
            // 如果已有同名文件，重用它
            targetFile = existingFile;
            print('重用现有文件: ${targetFile.id}');
          } else {
            // 创建新翻译文件
            targetFile = TranslateFile(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              title: title,
              content: '', // 内容设为空字符串
              createdAt: DateTime.now(),
            );
            try {
              await FileManager.instance.addFile(targetFile);
              print('创建新文件: ${targetFile.id}');
            } catch (e) {
              print('添加文件失败: $e');
              return;
            }
          }
          
          // 跳转到翻译展示页面
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => TranslateDisplayPage(
                title: title,
                fileId: targetFile.id,
              ),
            ),
          );
        },
      ),
      // 注意：这里没有设置showDrawer属性，默认不显示抽屉菜单
    );
  }
}

/// 英译中页面
/// 
/// 显示所有以"英译中"结尾的翻译文件
/// 用户可以点击文件进入对应的翻译练习界面
class EnglishToChinesePage extends StatelessWidget {
  /// 创建一个EnglishToChinesePage实例
  /// 
  /// super.key为必有格式
  const EnglishToChinesePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: FileManager.instance,
      builder: (context, child) {
        // 筛选英译中文件
        final englishToChineseFiles = FileManager.instance.files
            .where((file) => file.title.endsWith('英译中'))
            .toList();
            
        if (englishToChineseFiles.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.translate,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  '暂无英译中文件',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '长按右下角按钮创建新的英译中文件',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: englishToChineseFiles.length,
          itemBuilder: (context, index) {
            final file = englishToChineseFiles[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: const Icon(
                  Icons.translate,
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
                      file.content.isEmpty
                          ? '暂无内容'
                          : (file.content.length > 50
                              ? '${file.content.substring(0, 50)}...'
                              : file.content),
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
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey,
                  size: 16,
                ),
                onTap: () {
                  // 跳转到翻译展示页面
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => TranslateDisplayPage(
                        title: file.title,
                        fileId: file.id,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

/// 中译英页面
/// 
/// 显示所有以"中译英"结尾的翻译文件
/// 用户可以点击文件进入对应的翻译练习界面
class ChineseToEnglishPage extends StatelessWidget {
  /// 创建一个ChineseToEnglishPage实例
  /// 
  /// super.key为必有格式
  const ChineseToEnglishPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: FileManager.instance,
      builder: (context, child) {
        // 筛选中译英文件
        final chineseToEnglishFiles = FileManager.instance.files
            .where((file) => file.title.endsWith('中译英'))
            .toList();
            
        if (chineseToEnglishFiles.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.translate,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  '暂无中译英文件',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '长按右下角按钮创建新的中译英文件',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: chineseToEnglishFiles.length,
          itemBuilder: (context, index) {
            final file = chineseToEnglishFiles[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: const Icon(
                  Icons.translate,
                  color: Colors.green,
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
                      file.content.isEmpty
                          ? '暂无内容'
                          : (file.content.length > 50
                              ? '${file.content.substring(0, 50)}...'
                              : file.content),
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
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey,
                  size: 16,
                ),
                onTap: () {
                  // 跳转到翻译展示页面
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => TranslateDisplayPage(
                        title: file.title,
                        fileId: file.id,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
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
  void initState() {
    super.initState();
    // 初始化文件管理器，从数据库加载数据
    _initializeFileManager();
  }
  
  Future<void> _initializeFileManager() async {
    await FileManager.instance.initialize();
  }
  
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
                          file.content.isEmpty
                              ? '暂无内容'
                              : (file.content.length > 50
                                  ? '${file.content.substring(0, 50)}...'
                                  : file.content),
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
                       onPressed: () async {
                         try {
                           await FileManager.instance.removeFile(file.id);
                         } catch (e) {
                           // 显示错误信息
                           if (mounted) {
                             ScaffoldMessenger.of(context).showSnackBar(
                               SnackBar(content: Text('删除文件失败: $e')),
                             );
                           }
                         }
                       },
                     ),
                    onTap: () {
                      // 跳转到翻译展示页面，传递文件ID
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => TranslateDisplayPage(
                            title: file.title,
                            fileId: file.id,
                          ),
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



