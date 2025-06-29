import 'package:flutter/material.dart';

/// 统一的Tab页面脚手架组件
/// 提供一致的Tab页面布局和样式
class TabPageScaffold extends StatefulWidget {
  final String title;
  final List<Tab> tabs;
  final List<Widget> children;
  final Color? backgroundColor;
  final Color? primaryColor;
  final Color? indicatorColor;
  final Color? labelColor;
  final Color? unselectedLabelColor;
  
  const TabPageScaffold({
    super.key,
    required this.title,
    required this.tabs,
    required this.children,
    this.backgroundColor,
    this.primaryColor,
    this.indicatorColor,
    this.labelColor,
    this.unselectedLabelColor,
  });
  
  @override
  State<TabPageScaffold> createState() => _TabPageScaffoldState();
}

class _TabPageScaffoldState extends State<TabPageScaffold>
    with TickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.tabs.length,
      vsync: this,
    );
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = widget.primaryColor ?? theme.primaryColor;
    
    return Scaffold(
      backgroundColor: widget.backgroundColor ?? theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: widget.indicatorColor ?? Colors.white,
          labelColor: widget.labelColor ?? Colors.white,
          unselectedLabelColor: widget.unselectedLabelColor ?? Colors.white70,
          indicatorWeight: 3,
          tabs: widget.tabs,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: widget.children,
      ),
    );
  }
}

/// 简化的Tab页面脚手架组件（无Tab功能）
/// 用于单页面但需要保持一致样式的场景
class SimplePageScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final Color? backgroundColor;
  final Color? primaryColor;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? bottomNavigationBar;
  final Widget? drawer;
  final Widget? endDrawer;
  final bool automaticallyImplyLeading;
  
  const SimplePageScaffold({
    super.key,
    required this.title,
    required this.body,
    this.backgroundColor,
    this.primaryColor,
    this.actions,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.bottomNavigationBar,
    this.drawer,
    this.endDrawer,
    this.automaticallyImplyLeading = true,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = this.primaryColor ?? theme.primaryColor;
    
    return Scaffold(
      backgroundColor: backgroundColor ?? theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: actions,
        automaticallyImplyLeading: automaticallyImplyLeading,
      ),
      body: body,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      bottomNavigationBar: bottomNavigationBar,
      drawer: drawer,
      endDrawer: endDrawer,
    );
  }
}

/// 自定义Tab组件
/// 提供更丰富的Tab样式选项
class CustomTab extends StatelessWidget {
  final IconData? icon;
  final String text;
  final Color? iconColor;
  final Color? textColor;
  final double? iconSize;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry? padding;
  
  const CustomTab({
    super.key,
    this.icon,
    required this.text,
    this.iconColor,
    this.textColor,
    this.iconSize,
    this.textStyle,
    this.padding,
  });
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null)
            Icon(
              icon,
              color: iconColor,
              size: iconSize ?? 24,
            ),
          if (icon != null) const SizedBox(height: 4),
          Text(
            text,
            style: textStyle ?? TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}