import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../screens/audio/audio_selection_page.dart';

/// 可展开按钮组件
/// 包含一个主按钮和三个子按钮，点击主按钮可以展开/收起子按钮
/// 用于提供多个操作选项，节省界面空间
class ExpandableActionButtons extends StatefulWidget {
  final Function(String title)? onAddText;
  final Function(String title)? onAddFile; // 新增文件回调
  
  const ExpandableActionButtons({super.key, this.onAddText, this.onAddFile});

  @override
  State<ExpandableActionButtons> createState() =>
      _ExpandableActionButtonsState();
}

class _ExpandableActionButtonsState extends State<ExpandableActionButtons>
    with SingleTickerProviderStateMixin {
  // 控制按钮是否展开的状态
  bool _isExpanded = false;

  // 动画控制器，用于控制展开/收起的动画效果
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300), // 动画持续时间
      vsync: this,
    );
  }

  // 显示添加文件对话框
  void _showAddFileDialog() {
    final titleController = TextEditingController();
    String selectedType = '英译中'; // 默认类型

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('新增翻译文件'),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: '文件标题',
                        hintText: '请输入翻译文件标题',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedType,
                      decoration: const InputDecoration(
                        labelText: '翻译类型',
                        border: OutlineInputBorder(),
                      ),
                      items: ['英译中', '中译英'].map((String type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedType = newValue!;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('取消'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final title = titleController.text.trim();
                    
                    if (title.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('标题不能为空')),
                      );
                      return;
                    }
                    
                    // 自动添加类型后缀
                    final finalTitle = '$title-$selectedType';
                    
                    // 调用新增文件回调函数
                    if (widget.onAddFile != null) {
                      widget.onAddFile!(finalTitle);
                    }
                    
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('翻译文件创建成功')),
                    );
                  },
                  child: const Text('创建'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _animationController.dispose(); // 释放动画控制器资源
    super.dispose();
  }

  // 切换按钮展开/收起状态
  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward(); // 播放展开动画
      } else {
        _animationController.reverse(); // 播放收起动画
      }
    });
  }

  // 显示添加文本对话框
  void _showAddTextDialog() {
    final titleController = TextEditingController();
    String selectedType = '英译中'; // 默认类型

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('添加翻译文本'),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: '文件标题',
                        hintText: '请输入翻译文件标题',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedType,
                      decoration: const InputDecoration(
                        labelText: '翻译类型',
                        border: OutlineInputBorder(),
                      ),
                      items: ['英译中', '中译英'].map((String type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedType = newValue!;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('取消'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final title = titleController.text.trim();
                    
                    if (title.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('标题不能为空')),
                      );
                      return;
                    }
                    
                    // 自动添加类型后缀
                    final finalTitle = '$title-$selectedType';
                    
                    // 调用回调函数
                    if (widget.onAddText != null) {
                      widget.onAddText!(finalTitle);
                    }
                    
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('翻译文件创建成功')),
                    );
                  },
                  child: const Text('创建'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300, // 给Stack一个明确的宽度约束
      height: 300, // 给Stack一个明确的高度约束
      child: Stack(
        children: [
        // 图片按钮 - 使用AnimatedPositioned实现动画效果
        AnimatedPositioned(
          right: _isExpanded ? 0 : 0, // 展开时保持右侧位置
          bottom: _isExpanded ? 230 : 0, // 展开时向上移动更多距离
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut, // 使用缓出曲线使动画更自然
          child: ElevatedButton(
            onPressed: _isExpanded
                ? () {
                    // 图片按钮点击逻辑
                    ScaffoldMessenger.of(context)
                        .showSnackBar(const SnackBar(content: Text('添加图片')));
                    _toggleExpand(); // 点击后收起菜单
                  }
                : null,
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(), // 圆形按钮
              padding: const EdgeInsets.all(16),
              backgroundColor: _isExpanded ? Colors.green : Colors.transparent,
              foregroundColor: Colors.white,
              elevation: _isExpanded ? 6 : 0, // 展开时有阴影，收起时无阴影
            ),
            child: AnimatedOpacity(
              opacity: _isExpanded ? 1.0 : 0.0, // 展开时显示，收起时隐藏
              duration: const Duration(milliseconds: 300),
              child: const Icon(Icons.image),
            ),
          ),
        ),

        // 文本按钮
        AnimatedPositioned(
          right: _isExpanded ? 0 : 0, // 展开时保持右侧位置
          bottom: _isExpanded ? 166 : 0, // 展开时向上移动适中距离
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut, // 使用缓出曲线使动画更自然
          child: GestureDetector(
            onLongPress: _isExpanded ? () {
              // 长按文本按钮弹出添加文本对话框
              _showAddTextDialog();
              _toggleExpand(); // 收起菜单
            } : null,
            child: ElevatedButton(
              onPressed: _isExpanded
                  ? () {
                      // 直接调用添加文本对话框
                      _showAddTextDialog();
                      _toggleExpand(); // 点击后收起菜单
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(), // 圆形按钮
                padding: const EdgeInsets.all(16),
                backgroundColor: _isExpanded ? Colors.blue : Colors.transparent,
                foregroundColor: Colors.white,
                elevation: _isExpanded ? 6 : 0,
              ),
              child: AnimatedOpacity(
                opacity: _isExpanded ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: const Icon(Icons.text_fields),
              ),
            ),
          ),
        ),

        // 音频按钮
        AnimatedPositioned(
          right: _isExpanded ? 0 : 0, // 展开时保持右侧位置
          bottom: _isExpanded ? 100 : 0, // 展开时向上移动较小距离
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          child: ElevatedButton(
            onPressed: _isExpanded
                ? () {
                    // 导航到音频选择页面
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const AudioSelectionPage(),
                      ),
                    );
                    _toggleExpand(); // 点击后收起菜单
                  }
                : null,
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(16),
              backgroundColor: _isExpanded ? Colors.orange : Colors.transparent,
              foregroundColor: Colors.white,
              elevation: _isExpanded ? 6 : 0,
            ),
            child: AnimatedOpacity(
              opacity: _isExpanded ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: const Icon(Icons.music_note),
            ),
          ),
        ),

        // 主加号按钮 - 使用Positioned绝对定位
        Positioned(
          right: 0,
          bottom: 0, // 相对于Stack容器底部
          child: GestureDetector(
            onTap: () {
              // 触发震动反馈
              HapticFeedback.mediumImpact();
              // 切换展开状态
              _toggleExpand();
            }, // 使用点击触发震动和展开状态切换
            child: Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color:
                    _isExpanded ? Colors.red : Theme.of(context).primaryColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(51),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: AnimatedRotation(
                turns: _isExpanded ? 0.125 : 0, // 展开时旋转45度
                duration: const Duration(milliseconds: 300),
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),
          ),
        ),
        ],
      ),
    );
  }
}
