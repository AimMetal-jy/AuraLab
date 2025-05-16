import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 可展开按钮组件
/// 包含一个主按钮和三个子按钮，长按主按钮可以展开/收起子按钮
class ExpandableActionButtons extends StatefulWidget {
  const ExpandableActionButtons({super.key});

  @override
  State<ExpandableActionButtons> createState() =>
      _ExpandableActionButtonsState();
}

class _ExpandableActionButtonsState extends State<ExpandableActionButtons>
    with SingleTickerProviderStateMixin {
  // 控制按钮是否展开的状态
  bool _isExpanded = false;

  // 动画控制器
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // 切换按钮展开/收起状态
  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
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
          curve: Curves.easeOut,
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
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(16),
              backgroundColor: _isExpanded ? Colors.green : Colors.transparent,
              foregroundColor: Colors.white,
              elevation: _isExpanded ? 6 : 0,
            ),
            child: AnimatedOpacity(
              opacity: _isExpanded ? 1.0 : 0.0,
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
          curve: Curves.easeOut,
          child: ElevatedButton(
            onPressed: _isExpanded
                ? () {
                    // 文本按钮点击逻辑
                    ScaffoldMessenger.of(context)
                        .showSnackBar(const SnackBar(content: Text('添加文本')));
                    _toggleExpand(); // 点击后收起菜单
                  }
                : null,
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
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

        // 音频按钮
        AnimatedPositioned(
          right: _isExpanded ? 135 : 30, // 展开时向右上方移动
          bottom: _isExpanded ? 55 : 50, // 展开时向右上方移动
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          child: ElevatedButton(
            onPressed: _isExpanded
                ? () {
                    // 音频按钮点击逻辑
                    ScaffoldMessenger.of(context)
                        .showSnackBar(const SnackBar(content: Text('添加音频')));
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
                    color: Colors.black.withOpacity(0.2),
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
