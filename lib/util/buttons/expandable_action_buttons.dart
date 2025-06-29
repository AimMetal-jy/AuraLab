import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../screens/audio/audio_selection_page.dart';

/// 可展开按钮组件
/// 包含一个主按钮和三个子按钮，长按主按钮可以展开/收起子按钮
/// 用于提供多个操作选项，节省界面空间
class ExpandableActionButtons extends StatefulWidget {
  final Function(String title, String content)? onAddText;
  
  const ExpandableActionButtons({super.key, this.onAddText});

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
    final contentController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('添加文本'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: '标题',
                    hintText: '请输入文件标题',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: contentController,
                  decoration: const InputDecoration(
                    labelText: '内容',
                    hintText: '请输入文件内容',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 5,
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
                final content = contentController.text.trim();
                
                if (title.isEmpty || content.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('标题和内容不能为空')),
                  );
                  return;
                }
                
                // 调用回调函数
                if (widget.onAddText != null) {
                  widget.onAddText!(title, content);
                }
                
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('文件添加成功')),
                );
              },
              child: const Text('保存'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 图片按钮 - 使用AnimatedPositioned实现动画效果
        AnimatedPositioned(
          right: _isExpanded ? 100 : 30, // 展开时向左上方移动
          bottom: _isExpanded ? 120 : 50, // 展开时向左上方移动
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
          right: _isExpanded ? 30 : 30, // 展开时向上方移动
          bottom: _isExpanded ? 150 : 50, // 展开时向上方移动
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
          right: _isExpanded ? 135 : 30, // 展开时向右上方移动
          bottom: _isExpanded ? 55 : 50, // 展开时向右上方移动
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

        // 主加号按钮 - 使用Positioned固定在右下角
        Positioned(
          right: 30,
          bottom: 50,
          child: GestureDetector(
            onLongPress: () {
              // 触发震动反馈
              HapticFeedback.mediumImpact();
              // 切换展开状态
              _toggleExpand();
            }, // 使用长按触发震动和展开状态切换
            onTap: _isExpanded ? _toggleExpand : null, // 如果已展开，点击可以收起
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
    );
  }
}
