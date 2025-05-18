import 'package:flutter/material.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  // 定义开关的状态
  bool _collapseTranslation = false;
  bool _collapseOriginal = false;
  bool _expandAll = true;
  bool _autoHidePlayButton = false; // 自动收起播放按钮的状态

  // 更新收起翻译状态的方法
  void _updateCollapseTranslation(bool value) {
    setState(() {
      _collapseTranslation = value;
      if (value) {
        // 如果收起翻译为true，则全部展开必须为false
        _expandAll = false;
      } else if (!_collapseOriginal) {
        // 如果两个收起都为false，则全部展开为true
        _expandAll = true;
      }
    });
  }

  // 更新收起原文状态的方法
  void _updateCollapseOriginal(bool value) {
    setState(() {
      _collapseOriginal = value;
      if (value) {
        // 如果收起原文为true，则全部展开必须为false
        _expandAll = false;
      } else if (!_collapseTranslation) {
        // 如果两个收起都为false，则全部展开为true
        _expandAll = true;
      }
    });
  }

  // 更新全部展开状态的方法
  void _updateExpandAll(bool value) {
    setState(() {
      _expandAll = value;
      if (value) {
        // 如果全部展开为true，则两个收起都必须为false
        _collapseTranslation = false;
        _collapseOriginal = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        children: [
          // 大模型设置区域
          const _SettingSection(
            title: '默认使用的大模型',
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
          ),

          const SizedBox(height: 8),

          // 主题设置区域
          const _SettingSection(
            title: '主题: 默认背景',
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
          ),

          const SizedBox(height: 16),

          // 管理区域
          const Padding(
            padding: EdgeInsets.only(left: 8, bottom: 8, top: 8),
            child: Text('管理',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),

          // 配置备份
          const _SettingSection(
            title: '配置备份',
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
          ),

          // 设置全局目标语言和当前语言
          const _SettingSection(
            title: '设置全局目标语言和当前语言',
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
          ),

          // 默认收起翻译
          _SettingSection(
            title: '默认收起翻译',
            trailing: Switch(
              value: _collapseTranslation,
              onChanged: _updateCollapseTranslation,
            ),
          ),

          // 默认收起原文
          _SettingSection(
            title: '默认收起原文',
            trailing: Switch(
              value: _collapseOriginal,
              onChanged: _updateCollapseOriginal,
            ),
          ),

          // 默认全部展开
          _SettingSection(
            title: '默认全部展开',
            trailing: Switch(
              value: _expandAll,
              onChanged: _updateExpandAll,
            ),
          ),

          // 双击页面功能
          const _SettingSection(
            title: '双击页面: 暂停; 选词',
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
          ),

          // 自动收起播放按钮
          _SettingSection(
            title: '自动收起播放按钮',
            trailing: Switch(
              value: _autoHidePlayButton,
              onChanged: (value) {
                setState(() {
                  _autoHidePlayButton = value;
                });
              },
            ),
          ),

          // AI切片默认存储位置
          const _SettingSection(
            title: 'AI切片默认存储位置: 新建同名文件夹; 直接存在当前目录下',
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
          ),
        ],
      ),
    );
  }
}

/// 设置项组件
/// 用于显示单个设置选项
class _SettingSection extends StatefulWidget {
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;
  // final bool? initialSwitchValue;

  const _SettingSection({
    required this.title,
    this.trailing,
    this.onTap,
    // this.initialSwitchValue,
  });

  @override
  State<_SettingSection> createState() => __SettingSectionState();
}

class __SettingSectionState extends State<_SettingSection> {
  // late bool _switchValue;

  @override
  void initState() {
    super.initState();
    // _switchValue = widget.initialSwitchValue ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      elevation: 1,
      child: ListTile(
        title: Text(widget.title),
        trailing: widget.trailing,
        onTap: widget.onTap
      ),
    );
  }
}
