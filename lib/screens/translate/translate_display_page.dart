import 'package:flutter/material.dart';
import 'dart:async';
import 'package:auralab/util/widgets/custom_card.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:auralab/services/database_service.dart';

class TranslateDisplayPage extends StatefulWidget {
  final String title;
  final String? fileId;
  final List<CardInstance>? cardInstances;
  
  const TranslateDisplayPage({
    super.key, 
    required this.title,
    this.fileId,
    this.cardInstances,
  });

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
    this.showOriginal = true,
    this.showTranslation = true,
    this.showUserTranslation = false,
    this.codeMode = false,
  });

  // 工厂构造函数，方便从Map创建实例
  factory CardInstance.fromMap(Map<String, dynamic> map) {
    return CardInstance(
      id: map['id'] ?? '',
      summary: map['summary'] ?? '',
      original: map['original'] ?? '',
      translation: map['translation'] ?? '',
      userTranslation: map['userTranslation'] ?? '',
      showSummary: map['showSummary'] ?? true,
      showOriginal: map['showOriginal'] ?? true,
      showTranslation: map['showTranslation'] ?? true,
      showUserTranslation: map['showUserTranslation'] ?? false,
      codeMode: map['codeMode'] ?? false,
    );
  }

  // 复制方法，方便修改现有实例
  CardInstance copyWith({
    String? id,
    String? summary,
    String? original,
    String? translation,
    String? userTranslation,
    bool? showSummary,
    bool? showOriginal,
    bool? showTranslation,
    bool? showUserTranslation,
    bool? codeMode,
  }) {
    return CardInstance(
      id: id ?? this.id,
      summary: summary ?? this.summary,
      original: original ?? this.original,
      translation: translation ?? this.translation,
      userTranslation: userTranslation ?? this.userTranslation,
      showSummary: showSummary ?? this.showSummary,
      showOriginal: showOriginal ?? this.showOriginal,
      showTranslation: showTranslation ?? this.showTranslation,
      showUserTranslation: showUserTranslation ?? this.showUserTranslation,
      codeMode: codeMode ?? this.codeMode,
    );
  }

  // 转换为Map，方便序列化
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'summary': summary,
      'original': original,
      'translation': translation,
      'userTranslation': userTranslation,
      'showSummary': showSummary,
      'showOriginal': showOriginal,
      'showTranslation': showTranslation,
      'showUserTranslation': showUserTranslation,
      'codeMode': codeMode,
    };
  }
}

class _TranslateDisplayPageState extends State<TranslateDisplayPage> with WidgetsBindingObserver {
  // 模拟从md文件读取的多个卡片实例
  List<CardInstance> cardInstances = [];
  final DatabaseService _databaseService = DatabaseService();
  bool _isLoading = true;
  
  // 防抖保存的Timer
  Timer? _saveTimer;
  
  // 批量保存标志
  bool _isBatchSaving = false;

  @override
  void initState() {
    super.initState();
    // 添加应用生命周期监听
    WidgetsBinding.instance.addObserver(this);
    
    // 只有在没有现有数据时才从数据库加载
    // 这样可以避免页面重建时覆盖用户的修改
    final fileId = widget.fileId ?? 'default';
    print('DEBUG: initState for fileId: $fileId');
    print('DEBUG: Total controllers in global map: ${_controllers.length}');
    print('DEBUG: Controller keys: ${_controllers.keys.toList()}');
    
    bool hasExistingControllers = _controllers.keys.any((key) => key.startsWith('${fileId}_'));
    print('DEBUG: hasExistingControllers: $hasExistingControllers');
    
    if (!hasExistingControllers) {
      print('DEBUG: Loading from database');
      _loadCardInstances();
    } else {
      print('DEBUG: Loading from existing controllers');
      // 如果已有控制器，说明用户之前编辑过，直接使用现有数据
      _loadFromExistingControllers();
    }
    
    // 启动定期自动保存（每30秒保存一次）
    _startPeriodicSave();
  }
  
  /// 启动定期自动保存
  void _startPeriodicSave() {
    Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted && !_isBatchSaving) {
        print('DEBUG: Periodic auto-save triggered');
        _forceSaveAllData();
      } else if (!mounted) {
        timer.cancel();
      }
    });
  }
  
  /// 从现有控制器重建卡片数据（用于页面重建时保持用户修改）
  Future<void> _loadFromExistingControllers() async {
    try {
      final fileId = widget.fileId ?? 'default';
      
      // 从控制器键名中提取卡片ID
      Set<String> cardIds = {};
      for (String key in _controllers.keys) {
        if (key.startsWith('${fileId}_')) {
          // 键名格式: fileId_cardId_fieldName
          List<String> parts = key.split('_');
          if (parts.length >= 3) {
            String cardId = parts[1]; // 获取cardId部分
            cardIds.add(cardId);
          }
        }
      }
      
      // 重建卡片实例
      cardInstances.clear();
      for (String cardId in cardIds) {
        final summaryController = _controllers['${fileId}_${cardId}_summary'];
        final originalController = _controllers['${fileId}_${cardId}_original'];
        final translationController = _controllers['${fileId}_${cardId}_translation'];
        final userTranslationController = _controllers['${fileId}_${cardId}_userTranslation'];
        
        CardInstance card = CardInstance(
          id: cardId,
          summary: summaryController?.text ?? '',
          original: originalController?.text ?? '',
          translation: translationController?.text ?? '',
          userTranslation: userTranslationController?.text ?? '',
        );
        
        cardInstances.add(card);
      }
      
      // 按ID排序确保顺序一致
      cardInstances.sort((a, b) => a.id.compareTo(b.id));
      
      setState(() {
        _isLoading = false;
      });
      
      print('从现有控制器重建了 ${cardInstances.length} 张卡片');
    } catch (e) {
      print('从控制器重建卡片数据失败: $e');
      // 如果失败，回退到数据库加载
      _loadCardInstances();
    }
  }

  Future<void> _loadCardInstances() async {
    try {
      // 从数据库加载卡片数据，使用传入的fileId或默认值
      final fileId = widget.fileId ?? 'default';
      print('DEBUG: Loading cards for fileId: $fileId');
      final loadedCards = await _databaseService.getCardInstances(fileId);
      print('DEBUG: Loaded ${loadedCards.length} cards from database');
      
      // 打印加载的卡片详细信息
      for (int i = 0; i < loadedCards.length; i++) {
        final card = loadedCards[i];
        print('DEBUG: Card $i - id: ${card.id}, summary: ${card.summary.length} chars, original: ${card.original.length} chars, userTranslation: ${card.userTranslation.length} chars');
      }
      
      if (loadedCards.isNotEmpty) {
        cardInstances = loadedCards;
        print('Loaded existing cards from database');
        
        // 重要：如果已经存在控制器（说明用户之前编辑过），
        // 则使用控制器中的数据更新卡片实例，而不是被数据库数据覆盖
        for (int i = 0; i < cardInstances.length; i++) {
          final card = cardInstances[i];
          final cardId = card.id;
          
          // 检查是否存在对应的控制器
          final summaryKey = '${fileId}_${cardId}_summary';
          final originalKey = '${fileId}_${cardId}_original';
          final translationKey = '${fileId}_${cardId}_translation';
          final userTranslationKey = '${fileId}_${cardId}_userTranslation';
          
          // 如果控制器存在，使用控制器中的数据（用户的最新修改）
          if (_controllers.containsKey(summaryKey)) {
            card.summary = _controllers[summaryKey]!.text;
          }
          if (_controllers.containsKey(originalKey)) {
            card.original = _controllers[originalKey]!.text;
          }
          if (_controllers.containsKey(translationKey)) {
            card.translation = _controllers[translationKey]!.text;
          }
          if (_controllers.containsKey(userTranslationKey)) {
            card.userTranslation = _controllers[userTranslationKey]!.text;
          }
        }
      } else {
        print('No cards found for fileId: $fileId, creating default data');
        
        // 如果有传入的默认数据，使用它们
        if (widget.cardInstances != null) {
          cardInstances = List.from(widget.cardInstances!);
          print('Using provided cardInstances: ${cardInstances.length} cards');
        } else {
          // 创建一张初始卡片
          cardInstances.add(
            CardInstance(
              id: '1',
              summary: '这里是总结内容，支持Markdown格式。\n- 第一点\n- 第二点\n**加粗文本**',
              original: '点击编辑原文内容',
              translation: 'AI译文',
              userTranslation: '点击编辑您的翻译',
            ),
          );
          print('Created default card');
        }
        
        // 保存到数据库
        print('Saving ${cardInstances.length} cards to database for fileId: $fileId');
        for (final card in cardInstances) {
          await _databaseService.saveCardInstance(fileId, card);
        }
      }
       
       // 控制器将在UI构建时按需创建
       
       setState(() {
         _isLoading = false;
       });
    } catch (e) {
      print('加载卡片数据失败: $e');
      // 发生错误时使用默认数据
      if (widget.cardInstances != null) {
        cardInstances = List.from(widget.cardInstances!);
      } else {
        // 默认只创建一张初始卡片
        cardInstances.add(
          CardInstance(
            id: '1',
            summary: '这里是总结内容，支持Markdown格式。\n- 第一点\n- 第二点\n**加粗文本**',
            original: '点击编辑原文内容',
            translation: 'AI译文',
            userTranslation: '点击编辑您的翻译',
          ),
        );
      }
       
       setState(() {
         _isLoading = false;
       });
    }
  }
  
  // 移除重复的控制器初始化方法，统一使用_getController方法

  // 文本编辑控制器映射，用于代码模式下编辑内容
  // 使用静态变量确保控制器在页面切换时不会丢失
  static final Map<String, TextEditingController> _globalControllers = {};
  
  // 本地引用，方便访问
  Map<String, TextEditingController> get _controllers => _globalControllers;

  // 获取或创建文本编辑控制器
  TextEditingController _getController(String cardId, String fieldName, String initialText) {
    // 直接使用cardId而不是cardIndex，确保控制器key的稳定性
    final fileId = widget.fileId ?? 'default';
    final key = '${fileId}_${cardId}_$fieldName';
    if (!_controllers.containsKey(key)) {
      final controller = TextEditingController(text: initialText);
      _controllers[key] = controller;
      
      // 添加监听器以实时同步文本变化到卡片数据
      controller.addListener(() {
        final currentCardIndex = cardInstances.indexWhere((c) => c.id == cardId);
        if (currentCardIndex >= 0 && currentCardIndex < cardInstances.length) {
          final card = cardInstances[currentCardIndex];
          switch (fieldName) {
            case 'summary':
              card.summary = controller.text;
              break;
            case 'original':
              card.original = controller.text;
              break;
            case 'translation':
              card.translation = controller.text;
              break;
            case 'userTranslation':
              card.userTranslation = controller.text;
              break;
          }
          // 触发实时保存
          _saveCardInstanceRealtime(currentCardIndex);
        }
      });
    }
    // 移除错误的数据同步逻辑，避免覆盖用户的修改
    // 控制器一旦创建，就应该保持其当前状态，不应该被数据库数据覆盖
    return _controllers[key]!;
  }

  /// 实时保存卡片数据到数据库（用于文本变化时的自动保存，带防抖机制）
  void _saveCardInstanceRealtime(int index) {
    // 取消之前的保存定时器
    _saveTimer?.cancel();
    
    // 设置新的保存定时器，500ms后执行保存
    _saveTimer = Timer(const Duration(milliseconds: 500), () async {
      try {
        if (index >= 0 && index < cardInstances.length) {
          final card = cardInstances[index];
          final fileId = widget.fileId ?? 'default';
          final cardId = card.id;
          
          // 从控制器获取最新的文本内容
          final summaryController = _controllers['${fileId}_${cardId}_summary'];
          final originalController = _controllers['${fileId}_${cardId}_original'];
          final translationController = _controllers['${fileId}_${cardId}_translation'];
          final userTranslationController = _controllers['${fileId}_${cardId}_userTranslation'];
          
          // 创建包含最新数据的卡片
          final updatedCard = CardInstance(
            id: card.id,
            summary: summaryController?.text ?? card.summary,
            original: originalController?.text ?? card.original,
            translation: translationController?.text ?? card.translation,
            userTranslation: userTranslationController?.text ?? card.userTranslation,
            showSummary: card.showSummary,
            showOriginal: card.showOriginal,
            showTranslation: card.showTranslation,
            showUserTranslation: card.showUserTranslation,
            codeMode: card.codeMode,
          );
          
          print('DEBUG: Realtime saving card ${cardId} with data: summary=${updatedCard.summary.length} chars, original=${updatedCard.original.length} chars');
          await _databaseService.updateCardInstance(fileId, updatedCard);
          
          // 同步更新内存中的卡片数据
          cardInstances[index] = updatedCard;
        }
      } catch (e) {
        print('实时保存卡片数据失败: $e');
      }
    });
  }

  /// 保存卡片数据到数据库（用于手动保存或批量保存）
  Future<void> _saveCardInstance(int index) async {
    try {
      final card = cardInstances[index];
      // 从控制器获取最新的文本内容
      final fileId = widget.fileId ?? 'default';
      print('Saving card ${card.id} for fileId: $fileId');
      final cardId = card.id;
      final summaryController = _controllers['${fileId}_${cardId}_summary'];
      final originalController = _controllers['${fileId}_${cardId}_original'];
      final translationController = _controllers['${fileId}_${cardId}_translation'];
      final userTranslationController = _controllers['${fileId}_${cardId}_userTranslation'];
      
      // 更新卡片数据
      final updatedCard = CardInstance(
        id: card.id,
        summary: summaryController?.text ?? card.summary,
        original: originalController?.text ?? card.original,
        translation: translationController?.text ?? card.translation,
        userTranslation: userTranslationController?.text ?? card.userTranslation,
        showSummary: card.showSummary,
        showOriginal: card.showOriginal,
        showTranslation: card.showTranslation,
        showUserTranslation: card.showUserTranslation,
        codeMode: card.codeMode,
      );
      
      await _databaseService.updateCardInstance(fileId, updatedCard);
      // 同步更新内存中的卡片数据
      cardInstances[index] = updatedCard;
    } catch (e) {
      print('保存卡片数据失败: $e');
    }
  }

  /// 添加新卡片
  Future<void> _addNewCard() async {
    if (cardInstances.length >= 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('最多只能添加10张卡片')),
      );
      return;
    }

    try {
      // 生成新的卡片ID
      final newId = DateTime.now().millisecondsSinceEpoch.toString();
      
      // 创建新卡片实例
      final newCard = CardInstance(
        id: newId,
        summary: '点击编辑总结内容',
        original: '点击编辑原文内容',
        translation: 'AI译文将在这里显示',
        userTranslation: '点击编辑您的翻译',
        showSummary: true,
        showOriginal: true,
        showTranslation: true,
        showUserTranslation: true,
      );
      
      // 添加到列表
      setState(() {
        cardInstances.add(newCard);
      });
      
      // 控制器将在UI构建时按需创建
      
      // 保存到数据库
      final fileId = widget.fileId ?? 'default';
      await _databaseService.saveCardInstance(fileId, newCard);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('新卡片添加成功')),
      );
    } catch (e) {
      print('添加新卡片失败: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('添加新卡片失败')),
      );
    }
  }

  /// 删除卡片
  Future<void> _deleteCard(CardInstance card) async {
    try {
      final cardIndex = cardInstances.indexOf(card);
      if (cardIndex == -1) return;
      
      // 检查是否至少保留1张卡片
      if (cardInstances.length <= 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('至少需要保留一张卡片')),
        );
        return;
      }
      
      // 从数据库删除
      final fileId = widget.fileId ?? 'default';
      await _databaseService.deleteCardInstance(fileId, card.id);
      
      // 释放对应的控制器
      final cardId = card.id;
      _controllers['${fileId}_${cardId}_summary']?.dispose();
      _controllers['${fileId}_${cardId}_original']?.dispose();
      _controllers['${fileId}_${cardId}_translation']?.dispose();
      _controllers['${fileId}_${cardId}_userTranslation']?.dispose();
      
      // 从控制器映射中移除
      _controllers.remove('${fileId}_${cardId}_summary');
      _controllers.remove('${fileId}_${cardId}_original');
      _controllers.remove('${fileId}_${cardId}_translation');
      _controllers.remove('${fileId}_${cardId}_userTranslation');
      
      // 从列表中移除
      setState(() {
        cardInstances.removeAt(cardIndex);
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('卡片删除成功')),
      );
    } catch (e) {
      print('删除卡片失败: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('删除卡片失败')),
      );
    }
  }


  
  @override
  void dispose() {
    // 移除应用生命周期监听
    WidgetsBinding.instance.removeObserver(this);
    
    // 取消定时器
    _saveTimer?.cancel();
    
    // 在dispose时强制保存所有数据
    _forceSaveAllData();
    
    // 不释放控制器，让它们在全局范围内保持活跃
    // 这样用户重新进入页面时可以恢复之前的编辑状态
    final fileId = widget.fileId ?? 'default';
    print('DEBUG: dispose() called for fileId: $fileId, keeping controllers alive');
    
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    // 当应用进入后台、暂停或分离状态时，强制保存数据
    if (state == AppLifecycleState.paused || 
        state == AppLifecycleState.inactive || 
        state == AppLifecycleState.detached) {
      print('DEBUG: App lifecycle changed to $state, force saving data');
      _forceSaveAllData();
    }
  }
  
  /// 强制保存所有数据（同步操作）
  Future<void> _forceSaveAllData() async {
    if (_isBatchSaving) return; // 防止重复保存
    
    _isBatchSaving = true;
    final fileId = widget.fileId ?? 'default';
    
    try {
      print('DEBUG: Force saving all data for fileId: $fileId');
      
      // 批量保存所有卡片数据
      final List<Future<void>> saveTasks = [];
      
      for (int i = 0; i < cardInstances.length; i++) {
        final card = cardInstances[i];
        final cardId = card.id;
        
        // 获取控制器中的最新内容
        final summaryController = _controllers['${fileId}_${cardId}_summary'];
        final originalController = _controllers['${fileId}_${cardId}_original'];
        final translationController = _controllers['${fileId}_${cardId}_translation'];
        final userTranslationController = _controllers['${fileId}_${cardId}_userTranslation'];
        
        // 创建更新后的卡片实例
        final updatedCard = card.copyWith(
          summary: summaryController?.text ?? card.summary,
          original: originalController?.text ?? card.original,
          translation: translationController?.text ?? card.translation,
          userTranslation: userTranslationController?.text ?? card.userTranslation,
        );
        
        // 添加保存任务
        saveTasks.add(_databaseService.updateCardInstance(fileId, updatedCard));
      }
      
      // 等待所有保存任务完成
      await Future.wait(saveTasks);
      print('DEBUG: All data force saved successfully');
      
    } catch (e) {
      print('ERROR: Force save failed: $e');
    } finally {
      _isBatchSaving = false;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
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
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: '添加新卡片',
            onPressed: cardInstances.length < 10 ? _addNewCard : null,
          ),
          Text(
            '${cardInstances.length}/10',
            style: TextStyle(
              color: cardInstances.length >= 10 ? Colors.red : Colors.grey,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        // 增加 itemCount 以包含标题
        itemCount: cardInstances.length + 1,
        itemBuilder: (context, index) {
          // 如果是第一个项目，返回标题
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                widget.title,  // 使用从参数传入的标题
                style: const TextStyle(
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
    
    // 根据部分类型设置不同的外观和编辑模式
    Color cardColor;
    double translateY; // 使用 translateY 代替 topMargin
    bool isEditable; // 是否可编辑
    
    switch (fieldName) {
      case 'summary':
        cardColor = Colors.white;
        translateY = 0;
        isEditable = false; // AI总结只读
        break;
      case 'original':
        cardColor = Colors.grey.shade50;
        translateY = isFirst ? 0 : -12; // 如果是第一个显示的部分，则不进行位移
        isEditable = true; // 原文可编辑
        break;
      case 'translation':
        cardColor = Colors.grey.shade100;
        translateY = isFirst ? 0 : -12;
        isEditable = false; // 译文只读
        break;
      case 'userTranslation':
        cardColor = Colors.grey.shade200;
        translateY = isFirst ? 0 : -12;
        isEditable = true; // 用户翻译可编辑
        break;
      default:
        cardColor = Colors.white;
        translateY = 0;
        isEditable = false;
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
                // 混合显示模式下，只对可编辑字段显示代码模式切换按钮
                if (isEditable) 
                  IconButton(
                    icon: Icon(card.codeMode ? Icons.visibility : Icons.code),
                    tooltip: card.codeMode ? '预览模式' : '代码模式',
                    onPressed: () {
                      setState(() {
                        card.codeMode = !card.codeMode;
                      });
                    },
                  ),
                // 为原文和用户翻译字段添加编辑按钮
                if (isEditable && (fieldName == 'original' || fieldName == 'userTranslation'))
                  IconButton(
                    icon: const Icon(Icons.edit),
                    tooltip: '编辑内容',
                    onPressed: () {
                      _showEditDialog(context, card, fieldName, controller);
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
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    tooltip: '删除卡片',
                    onPressed: () {
                      // 显示确认对话框
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('确认删除'),
                          content: const Text('确定要删除这张卡片吗？此操作不可撤销。'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('取消'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _deleteCard(card);
                              },
                              child: const Text('删除', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            // 内容区域 - 混合显示模式
            _buildContentArea(card, fieldName, content, controller, isEditable),
          ],
        ),
      ),
    );
  }

  // 构建内容区域，根据是否可编辑显示不同的组件
  Widget _buildContentArea(
    CardInstance card, 
    String fieldName, 
    String content, 
    TextEditingController controller, 
    bool isEditable
  ) {
    if (isEditable) {
      // 可编辑字段：根据代码模式显示编辑器或预览
      return card.codeMode
          ? TextFormField(
              controller: controller,
              maxLines: null,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: '编辑内容',
              ),
              onChanged: (val) {
                // 更新对应的内容到卡片实例
                switch (fieldName) {
                  case 'original':
                    card.original = val;
                    break;
                  case 'userTranslation':
                    card.userTranslation = val;
                    break;
                  case 'summary':
                    card.summary = val;
                    break;
                  case 'translation':
                    card.translation = val;
                    break;
                }
                
                // 实时保存数据到数据库
                final cardIndex = cardInstances.indexOf(card);
                if (cardIndex != -1) {
                  _saveCardInstanceRealtime(cardIndex);
                }
              },
            )
          : Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(4),
              ),
              child: MarkdownBody(data: content.isEmpty ? '暂无内容' : content),
            );
    } else {
      // 只读字段：始终显示为Markdown预览
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(4),
        ),
        child: MarkdownBody(data: content),
      );
    }
  }

  // 显示编辑对话框
  void _showEditDialog(BuildContext context, CardInstance card, String fieldName, TextEditingController controller) {
    // 检查当前内容是否为默认提示文字，如果是则不设置初始值
    String currentText = controller.text;
    bool isDefaultText = (fieldName == 'original' && currentText == '点击编辑原文内容') ||
                        (fieldName == 'userTranslation' && currentText == '点击编辑您的翻译');
    
    final TextEditingController dialogController = TextEditingController(
      text: isDefaultText ? '' : currentText
    );
    String fieldTitle = fieldName == 'original' ? '原文' : '用户翻译';
    String hintText = fieldName == 'original' ? '点击编辑原文内容' : '点击编辑您的翻译';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('编辑$fieldTitle'),
        content: SizedBox(
          width: double.maxFinite,
          child: TextField(
            controller: dialogController,
            maxLines: null,
            minLines: 5,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.grey.shade400),
              border: const OutlineInputBorder(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              // 更新控制器和卡片数据
              controller.text = dialogController.text;
              
              // 更新对应的卡片字段
              switch (fieldName) {
                case 'original':
                  card.original = dialogController.text;
                  break;
                case 'userTranslation':
                  card.userTranslation = dialogController.text;
                  break;
              }
              
              // 保存到数据库
              final cardIndex = cardInstances.indexOf(card);
              if (cardIndex != -1) {
                _saveCardInstance(cardIndex);
              }
              
              setState(() {});
              Navigator.pop(context);
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$fieldTitle已保存')),
              );
            },
            child: const Text('保存'),
          ),
        ],
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
                      // 保存到数据库
                      final cardIndex = cardInstances.indexOf(card);
                      if (cardIndex != -1) {
                        _saveCardInstance(cardIndex);
                      }
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
                      // 保存到数据库
                      final cardIndex = cardInstances.indexOf(card);
                      if (cardIndex != -1) {
                        _saveCardInstance(cardIndex);
                      }
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
                      // 保存到数据库
                      final cardIndex = cardInstances.indexOf(card);
                      if (cardIndex != -1) {
                        _saveCardInstance(cardIndex);
                      }
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
                      // 保存到数据库
                      final cardIndex = cardInstances.indexOf(card);
                      if (cardIndex != -1) {
                        _saveCardInstance(cardIndex);
                      }
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
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.delete, color: Colors.red),
                    title: const Text('删除该卡片', style: TextStyle(color: Colors.red)),
                    onTap: () {
                      Navigator.pop(context);
                      // 显示确认对话框
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('确认删除'),
                          content: const Text('确定要删除这张卡片吗？此操作不可撤销。'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('取消'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _deleteCard(card);
                              },
                              child: const Text('删除', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
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
 
}