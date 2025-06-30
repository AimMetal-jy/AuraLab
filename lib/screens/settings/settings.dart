import 'package:flutter/material.dart';
// Flutter材料设计组件库

/// 设置页面主组件
/// 
/// 提供应用的各种设置选项，包括大模型设置、主题设置、管理功能和显示偏好等
/// 使用StatefulWidget以支持设置状态的变化
class Settings extends StatefulWidget {
  /// 创建一个Settings实例
  /// 
  /// super.key为必有格式
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

/// 设置页面状态类
/// 
/// 管理设置页面的状态和UI构建
class _SettingsState extends State<Settings> {
  /// 定义各种设置开关的状态
  bool _collapseTranslation = false; // 是否默认收起翻译
  bool _collapseOriginal = false;    // 是否默认收起原文
  bool _expandAll = true;            // 是否默认全部展开
  bool _autoHidePlayButton = false;  // 是否自动收起播放按钮

  /// 更新收起翻译状态的方法
  /// 
  /// 当用户切换收起翻译开关时调用
  /// [value] 新的开关状态
  void _updateCollapseTranslation(bool value) {
    setState(() {
      _collapseTranslation = value;
      if (value) {
        // 如果收起翻译为true，则全部展开必须为false
        // 因为收起翻译和全部展开是互斥的
        _expandAll = false;
      } else if (!_collapseOriginal) {
        // 如果两个收起都为false，则全部展开为true
        // 保持设置的逻辑一致性
        _expandAll = true;
      }
    });
  }

  /// 更新收起原文状态的方法
  /// 
  /// 当用户切换收起原文开关时调用
  /// [value] 新的开关状态
  void _updateCollapseOriginal(bool value) {
    setState(() {
      _collapseOriginal = value;
      if (value) {
        // 如果收起原文为true，则全部展开必须为false
        // 因为收起原文和全部展开是互斥的
        _expandAll = false;
      } else if (!_collapseTranslation) {
        // 如果两个收起都为false，则全部展开为true
        // 保持设置的逻辑一致性
        _expandAll = true;
      }
    });
  }

  /// 更新全部展开状态的方法
  /// 
  /// 当用户切换全部展开开关时调用
  /// [value] 新的开关状态
  void _updateExpandAll(bool value) {
    setState(() {
      _expandAll = value;
      if (value) {
        // 如果全部展开为true，则两个收起都必须为false
        // 因为全部展开与收起翻译和收起原文是互斥的
        _collapseTranslation = false;
        _collapseOriginal = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 设置页面的应用栏
      appBar: AppBar(
        title: const Text('设置'),
      ),
      // 使用ListView作为主体，支持滚动查看所有设置项
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        children: [
          // 大模型设置区域 - 点击后可以选择默认使用的AI大模型
          _SettingSection(
            title: '默认使用的大模型',
            trailing: Icon(Icons.arrow_forward_ios, size: 16), // 右侧箭头图标，表示可以点击进入下一级页面
            onTap: () {},
          ),

          const SizedBox(height: 8),

          // 主题设置区域 - 点击后可以选择应用的主题和背景
          _SettingSection(
            title: '主题: 默认背景',
            trailing: Icon(Icons.arrow_forward_ios, size: 16), // 右侧箭头图标，表示可以点击进入下一级页面
            onTap: () {},
          ),

          const SizedBox(height: 16),

          // 管理区域标题 - 用于分组显示管理类设置项
          const Padding(
            padding: EdgeInsets.only(left: 8, bottom: 8, top: 8), // 设置内边距，使布局更美观
            child: Text('管理',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), // 使用粗体突出显示分组标题
          ),

          // 配置备份设置项 - 点击后可以进行应用配置的备份和恢复
          _SettingSection(
            title: '配置备份',
            trailing: Icon(Icons.arrow_forward_ios, size: 16), // 右侧箭头图标，表示可以点击进入下一级页面
            onTap: () {},
          ),

          // 语言设置项 - 点击后可以设置应用的全局目标语言和当前语言
          _SettingSection(
            title: '设置全局目标语言和当前语言',
            trailing: Icon(Icons.arrow_forward_ios, size: 16), // 右侧箭头图标，表示可以点击进入下一级页面
            onTap: () {},
          ),


          // 默认收起翻译设置项 - 控制是否默认收起翻译内容
          _SettingSection(
            title: '默认收起翻译',
            trailing: Switch(
              value: _collapseTranslation, // 开关的当前状态
              onChanged: _updateCollapseTranslation, // 开关状态变化时的回调函数
            ),
          ),

          // 默认收起原文设置项 - 控制是否默认收起原文内容
          _SettingSection(
            title: '默认收起原文',
            trailing: Switch(
              value: _collapseOriginal, // 开关的当前状态
              onChanged: _updateCollapseOriginal, // 开关状态变化时的回调函数
            ),
          ),

          // 默认全部展开设置项 - 控制是否默认展开所有内容
          _SettingSection(
            title: '默认全部展开',
            trailing: Switch(
              value: _expandAll, // 开关的当前状态
              onChanged: _updateExpandAll, // 开关状态变化时的回调函数
            ),
          ),

          // 双击页面功能设置项 - 点击后可以设置双击页面的行为
          _SettingSection(
            title: '双击页面: 暂停; 选词',
            trailing: Icon(Icons.arrow_forward_ios, size: 16), // 右侧箭头图标，表示可以点击进入下一级页面
            onTap: () {},
          ),

          // 自动收起播放按钮设置项 - 控制是否自动隐藏播放控制按钮
          _SettingSection(
            title: '自动收起播放按钮',
            trailing: Switch(
              value: _autoHidePlayButton, // 开关的当前状态
              onChanged: (value) {
                setState(() {
                  _autoHidePlayButton = value; // 更新状态
                });
              },
            ),
          ),

          // AI切片默认存储位置设置项 - 点击后可以设置AI生成内容的存储位置
          _SettingSection(
            title: 'AI切片默认存储位置: 新建同名文件夹; 直接存在当前目录下',
            trailing: Icon(Icons.arrow_forward_ios, size: 16), // 右侧箭头图标，表示可以点击进入下一级页面
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

/// 设置项组件
/// 
/// 用于显示单个设置选项，包括标题和交互控件
/// 使用StatefulWidget以支持后续可能的状态变化
class _SettingSection extends StatefulWidget {
  /// 设置项的标题文本
  final String title;
  
  /// 设置项右侧的控件，通常是开关或箭头图标
  final Widget? trailing;
  
  /// 点击设置项时的回调函数
  final VoidCallback? onTap;
  
  // 注释掉的代码，可能是之前考虑过的功能
  // final bool? initialSwitchValue;

  /// 创建一个_SettingSection实例
  /// 
  /// [title] 设置项的标题
  /// [trailing] 设置项右侧的控件
  /// [onTap] 点击设置项时的回调函数
  const _SettingSection({
    required this.title,
    this.trailing,
    this.onTap,
    // this.initialSwitchValue,
  });

  @override
  State<_SettingSection> createState() => __SettingSectionState();
}

/// 设置项组件状态类
/// 
/// 管理_SettingSection组件的状态和UI构建
class __SettingSectionState extends State<_SettingSection> {
  // 注释掉的代码，可能是之前考虑过的功能
  // late bool _switchValue;

  @override
  void initState() {
    super.initState();
    // 注释掉的代码，可能是之前考虑过的功能
    // _switchValue = widget.initialSwitchValue ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      // 设置卡片的外边距
      margin: const EdgeInsets.symmetric(vertical: 4),
      // 设置卡片形状为圆角矩形
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)), // 所有边角都使用12像素的圆角
      ),
      // 设置卡片阴影高度
      elevation: 1,
      // 使用ListTile作为卡片内容，提供标准的列表项布局
      child: ListTile(
        title: Text(widget.title), // 显示设置项标题
        trailing: widget.trailing, // 显示设置项右侧的控件
        onTap: widget.onTap        // 设置点击事件回调
      ),
    );
  }
}
