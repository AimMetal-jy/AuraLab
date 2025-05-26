import 'package:flutter/material.dart';
import 'package:auralab/util/widgets/custom_card.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class TranslateDisplayPage extends StatefulWidget {
  const TranslateDisplayPage({super.key});

  @override
  State<TranslateDisplayPage> createState() => _TranslateDisplayPageState();
}

// 卡片实例模型
class CardInstance {
  final String id; // 卡片唯一标识
  String summary;
  String original;
  String translation;
  String userTranslation;
  bool showSummary;
  bool showOriginal;
  bool showTranslation;
  bool showUserTranslation;
  bool codeMode;

  CardInstance({
    required this.id,
    required this.summary,
    required this.original,
    required this.translation,
    required this.userTranslation,
    this.showSummary = true,
    this.showOriginal = false,
    this.showTranslation = false,
    this.showUserTranslation = false,
    this.codeMode = false,
  });
}

class _TranslateDisplayPageState extends State<TranslateDisplayPage> {
  // 模拟从md文件读取的多个卡片实例
  List<CardInstance> cardInstances = [];

  @override
  void initState() {
    super.initState();
    // 模拟数据
    cardInstances.add(
      CardInstance(
        id: '1',
        summary: '这里是总结内容，支持Markdown格式。\n- 第一点\n- 第二点\n**加粗文本**',
        original: 'It took him a while to find his calling - he worked in his father\'s pencil factory, as a door-to-door magazine salesman, took on other teaching and tutoring gigs, and even spent a brief time shoveling manure before finding some success with his true passion: writing.',
        translation: '他花了一段时间才找到自己的使命——他曾在父亲的铅笔厂工作，做过挨家挨户推销杂志的推销员，还从事过其他教学和辅导工作，甚至在短暂地铲过粪，之后才在自己真正热爱的事情——写作上取得了一些成就。',
        userTranslation: 'he spend sometime and finally find his life - he used to work in his father\'s pencil factory,be a sailer that sells magazines one by one,and other teaching or help work,he even once collect poops,and after that he finally find what he loved - he have some achievement on writing.',
      ),
    );
    
    // 添加第二个卡片实例作为示例
    cardInstances.add(
      CardInstance(
        id: '2',
        summary: '另一个示例总结，同样支持Markdown。\n1. 有序列表\n2. 第二项',
        original: 'This is another example text. It demonstrates how multiple card instances can be displayed on the same page.',
        translation: '这是另一个示例文本。它展示了如何在同一页面上显示多个卡片实例。',
        userTranslation: '这是我翻译的另一个例子。展示了多卡片实例。',
        showOriginal: true,
      ),
    );
  }

  // 文本编辑控制器映射，用于代码模式下编辑内容
  final Map<String, TextEditingController> _controllers = {};

  // 获取或创建文本编辑控制器
  TextEditingController _getController(String cardId, String fieldName, String initialText) {
    final key = '$cardId-$fieldName';
    if (!_controllers.containsKey(key)) {
      _controllers[key] = TextEditingController(text: initialText);
    }
    return _controllers[key]!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const TextField(
          decoration: InputDecoration(
            hintText: '在本文中搜索',
            border: InputBorder.none,
            prefixIcon: Icon(Icons.search),
          ),
        ),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        // 增加 itemCount 以包含标题
        itemCount: cardInstances.length + 1,
        itemBuilder: (context, index) {
          // 如果是第一个项目，返回标题
          if (index == 0) {
            return const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Text(
                '模拟标题 - 翻译内容列表',  // 这里可以替换为从参数传入的标题
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }
          // 否则返回卡片实例，注意索引需要减1
          return _buildCardInstance(cardInstances[index - 1]);
        },
      ),
    );
  }

  // 构建单个卡片实例（包含多个堆叠的部分）
  Widget _buildCardInstance(CardInstance card) {
    // 计算要显示的部分
    final parts = <Widget>[];
    
    // 按照堆叠顺序添加各部分（与图片中顺序一致）
    if (card.showSummary) {
      parts.add(_buildCardPart(
        card: card,
        title: 'AI总结',
        content: card.summary,
        fieldName: 'summary',
        showActions: true, // 只在总结部分显示完整的操作按钮
        isFirst: true, // 标记为第一个部分
      ));
    }
    
    if (card.showOriginal) {
      parts.add(_buildCardPart(
        card: card,
        title: '原文',
        content: card.original,
        fieldName: 'original',
        isFirst: parts.isEmpty, // 如果是第一个显示的部分，则标记为第一个
      ));
    }
    
    if (card.showTranslation) {
      parts.add(_buildCardPart(
        card: card,
        title: '译文',
        content: card.translation,
        fieldName: 'translation',
        isFirst: parts.isEmpty, // 如果是第一个显示的部分，则标记为第一个
      ));
    }
    
    if (card.showUserTranslation) {
      parts.add(_buildCardPart(
        card: card,
        title: '我的翻译',
        content: card.userTranslation,
        fieldName: 'userTranslation',
        isFirst: parts.isEmpty, // 如果是第一个显示的部分，则标记为第一个
      ));
    }
    
    // 如果没有要显示的部分，显示一个最小化的卡片
    if (parts.isEmpty) {
      parts.add(
        ListTile(
          title: Text('卡片 ${card.id}'),
          subtitle: const Text('长按查看选项'),
        ),
      );
    }
    
    // 返回一个可长按的卡片容器
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: GestureDetector(
        onLongPress: () => _showCardOptionsMenu(context, card),
        child: Column(
          children: parts,
        ),
      ),
    );
  }

  // 构建卡片的单个部分（总结/原文/译文/我的翻译）
  Widget _buildCardPart({
    required CardInstance card,
    required String title,
    required String content,
    required String fieldName,
    bool showActions = false,
    bool isFirst = false, // 新增参数，标记是否为第一个部分
  }) {
    // 获取对应的文本编辑控制器
    final controller = _getController(card.id, fieldName, content);
    
    // 根据部分类型设置不同的外观
    Color cardColor;
    double translateY; // 使用 translateY 代替 topMargin
    
    switch (fieldName) {
      case 'summary':
        cardColor = Colors.white;
        translateY = 0;
        break;
      case 'original':
        cardColor = Colors.grey.shade50;
        translateY = isFirst ? 0 : -12; // 如果是第一个显示的部分，则不进行位移
        break;
      case 'translation':
        cardColor = Colors.grey.shade100;
        translateY = isFirst ? 0 : -12;
        break;
      case 'userTranslation':
        cardColor = Colors.grey.shade200;
        translateY = isFirst ? 0 : -12;
        break;
      default:
        cardColor = Colors.white;
        translateY = 0;
    }
    
    // 使用 Transform.translate 代替负 margin
    return Transform.translate(
      offset: Offset(0, translateY),
      child: CustomCard(
        padding: const EdgeInsets.all(16),
        color: cardColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 顶部功能区
            Row(
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                // 代码模式切换按钮
                IconButton(
                  icon: Icon(card.codeMode ? Icons.visibility : Icons.code),
                  tooltip: card.codeMode ? '预览模式' : '代码模式',
                  onPressed: () {
                    setState(() {
                      card.codeMode = !card.codeMode;
                    });
                  },
                ),
                // 只在总结部分显示额外的操作按钮
                if (showActions) ...[  
                  IconButton(
                    icon: const Icon(Icons.sync),
                    tooltip: '同步至批注',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('同步至批注功能暂未实现')),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    tooltip: '添加自定义功能',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('添加自定义功能暂未实现')),
                      );
                    },
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            // 内容区域
            card.codeMode
                ? TextFormField(
                    controller: controller,
                    maxLines: null,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: '编辑$title',
                    ),
                    onChanged: (val) {
                      setState(() {
                        // 更新对应的内容
                        switch (fieldName) {
                          case 'summary':
                            card.summary = val;
                            break;
                          case 'original':
                            card.original = val;
                            break;
                          case 'translation':
                            card.translation = val;
                            break;
                          case 'userTranslation':
                            card.userTranslation = val;
                            break;
                        }
                      });
                    },
                  )
                : MarkdownBody(data: content),
          ],
        ),
      ),
    );
  }

  // 显示卡片选项菜单
  void _showCardOptionsMenu(BuildContext context, CardInstance card) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const ListTile(
                    title: Text('显示选项', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  CheckboxListTile(
                    title: const Text('显示总结'),
                    value: card.showSummary,
                    onChanged: (value) {
                      setState(() {
                        card.showSummary = value ?? true;
                      });
                      this.setState(() {});
                    },
                  ),
                  CheckboxListTile(
                    title: const Text('显示原文'),
                    value: card.showOriginal,
                    onChanged: (value) {
                      setState(() {
                        card.showOriginal = value ?? false;
                      });
                      this.setState(() {});
                    },
                  ),
                  CheckboxListTile(
                    title: const Text('显示译文'),
                    value: card.showTranslation,
                    onChanged: (value) {
                      setState(() {
                        card.showTranslation = value ?? false;
                      });
                      this.setState(() {});
                    },
                  ),
                  CheckboxListTile(
                    title: const Text('显示我的翻译'),
                    value: card.showUserTranslation,
                    onChanged: (value) {
                      setState(() {
                        card.showUserTranslation = value ?? false;
                      });
                      this.setState(() {});
                    },
                  ),
                  const Divider(),
                  const ListTile(
                    title: Text('其他选项', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  ListTile(
                    leading: const Icon(Icons.category),
                    title: const Text('添加到自定义分类'),
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('添加到自定义分类功能暂未实现')),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.volume_off),
                    title: const Text('不朗读该卡片'),
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('不朗读该卡片功能暂未实现')),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.volume_up),
                    title: const Text('朗读该卡片'),
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('朗读该卡片功能暂未实现')),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    // 释放所有控制器
    _controllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }
}