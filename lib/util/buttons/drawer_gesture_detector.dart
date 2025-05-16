import 'package:flutter/material.dart';

/// DrawerGestureDetector
/// 用于检测左右滑动手势并自动打开/关闭Scaffold的Drawer
/// 优化版本：使用Scaffold.maybeOf方法获取ScaffoldState，并添加边缘检测功能
class DrawerGestureDetector extends StatefulWidget {
  final Widget child;
  final double minDragDistance;
  final double minVelocity;
  
  /// 边缘检测宽度，只有从屏幕左边缘这个距离内开始的滑动才会触发打开抽屉
  final double edgeDragWidth;
  
  /// 抽屉状态变化回调
  final DrawerCallback? onDrawerChanged;

  const DrawerGestureDetector({
    super.key,
    required this.child,
    this.minDragDistance = 20.0,
    this.minVelocity = 300.0,
    this.edgeDragWidth = 20.0,
    this.onDrawerChanged,
  });

  @override
  State<DrawerGestureDetector> createState() => _DrawerGestureDetectorState();
}

class _DrawerGestureDetectorState extends State<DrawerGestureDetector> {
  // 记录拖动的起始位置
  Offset? _dragStartPosition;
  // 记录当前拖动的总距离
  double _dragDistance = 0.0;
  // 标记是否是有效的边缘拖动
  bool _isValidEdgeDrag = false;
  // 记录抽屉状态
  bool _isDrawerOpen = false;
  // 记录上一次检查抽屉状态的时间，防止频繁检查
  DateTime? _lastDrawerCheckTime;

  @override
  void initState() {
    super.initState();
    // 在下一帧检查抽屉状态
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkDrawerState();
    });
  }

  // 检查抽屉状态的方法
  void _checkDrawerState() {
    final now = DateTime.now();
    // 如果上次检查时间为空或者距离上次检查已经过去了100毫秒以上
    if (_lastDrawerCheckTime == null ||
        now.difference(_lastDrawerCheckTime!).inMilliseconds > 100) {
      _lastDrawerCheckTime = now;
      
      final scaffoldState = Scaffold.maybeOf(context);
      if (scaffoldState != null) {
        final isOpen = scaffoldState.isDrawerOpen;
        if (_isDrawerOpen != isOpen) {
          setState(() {
            _isDrawerOpen = isOpen;
          });
          widget.onDrawerChanged?.call(isOpen);
        }
      }
    }
  }

  void _handleDragStart(DragStartDetails details) {
    _dragStartPosition = details.globalPosition;
    _dragDistance = 0.0;
    
    // 检查抽屉当前状态
    _checkDrawerState();
    
    // 检查是否是从左边缘开始的拖动（用于打开抽屉）
    if (details.globalPosition.dx <= widget.edgeDragWidth) {
      // 只有当抽屉关闭时，才允许从左边缘打开
      if (!_isDrawerOpen) {
        _isValidEdgeDrag = true;
      }
    } else {
      // 如果不是从边缘开始，只有当抽屉已经打开时才允许拖动关闭
      _isValidEdgeDrag = _isDrawerOpen;
    }
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (_dragStartPosition != null && _isValidEdgeDrag) {
      setState(() {
        _dragDistance += details.delta.dx;
      });
    }
  }

  void _handleDragEnd(DragEndDetails details) {
    if (!_isValidEdgeDrag) {
      // 如果不是有效的边缘拖动，重置状态并返回
      _resetDragState();
      return;
    }
    
    final velocity = details.primaryVelocity ?? 0;
    
    // 使用Builder获取正确的上下文
    final scaffoldState = Scaffold.maybeOf(context);
    if (scaffoldState == null) {
      _resetDragState();
      return;
    }
    
    // 右滑打开抽屉 (检查速度和距离)
    if ((velocity > widget.minVelocity || _dragDistance > widget.minDragDistance) && 
        _dragDistance > 0 && 
        !_isDrawerOpen) {
      scaffoldState.openDrawer();
      _notifyDrawerChange(true);
    }
    
    // 左滑关闭抽屉 (检查速度和距离)
    if ((velocity < -widget.minVelocity || _dragDistance < -widget.minDragDistance) && 
        _dragDistance < 0 && 
        _isDrawerOpen) {
      Navigator.of(context).pop();
      _notifyDrawerChange(false);
    }
    
    _resetDragState();
  }
  
  void _notifyDrawerChange(bool isOpen) {
    if (_isDrawerOpen != isOpen) {
      setState(() {
        _isDrawerOpen = isOpen;
      });
      widget.onDrawerChanged?.call(isOpen);
    }
  }
  
  void _resetDragState() {
    _dragStartPosition = null;
    _dragDistance = 0.0;
    _isValidEdgeDrag = false;
  }

  @override
  Widget build(BuildContext context) {
    // 使用Builder确保我们能够正确获取到Scaffold上下文
    return Builder(
      builder: (context) => GestureDetector(
        // 使用translucent确保手势检测不会干扰子组件的点击事件
        behavior: HitTestBehavior.translucent,
        onHorizontalDragStart: _handleDragStart,
        onHorizontalDragUpdate: _handleDragUpdate,
        onHorizontalDragEnd: _handleDragEnd,
        child: widget.child,
      ),
    );
  }
}