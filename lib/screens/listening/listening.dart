import 'package:flutter/material.dart';
import 'package:auralab/screens/listening/animation/expandable_action_buttons.dart';
import 'package:auralab/screens/listening/subpage/file.dart';
import 'package:auralab/screens/listening/subpage/author.dart';
import 'package:auralab/screens/listening/subpage/playlist.dart';

/// 页面索引状态管理
class ListeningTabState extends InheritedNotifier<ValueNotifier<int>> {
  const ListeningTabState({
    super.key,
    required super.notifier,
    required super.child,
  });

  // 获取当前索引值
  static int of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<ListeningTabState>()
        ?.notifier
        ?.value ?? 0;
  }

  // 切换页面索引
  static void switchPage(BuildContext context, int index) {
    final notifier = context
        .dependOnInheritedWidgetOfExactType<ListeningTabState>()
        ?.notifier;
    if (notifier != null) {
      notifier.value = index;
    }
  }

  @override
  bool updateShouldNotify(ListeningTabState oldWidget) {
    return notifier != oldWidget.notifier;
  }
}

/// 听力页面主组件
/// 包含AppBar、搜索框、内容区域和右下角添加按钮
class ListeningPage extends StatelessWidget {
  const ListeningPage({super.key});


  @override
  Widget build(BuildContext context) {
    // 使用ValueNotifier管理状态
    return ListeningTabState(
      notifier: ValueNotifier<int>(0),
      child: Builder(builder: (context) {
        // 获取当前选中的索引
        final selectedIndex = ListeningTabState.of(context);
        
        // 页面主体使用Scaffold组件
        return Scaffold(
          appBar: AppBar(
            // AppBar标题区域使用Row布局
            backgroundColor: Colors.grey.shade400,
            title: Row(
              children: [
                // 左侧部分：耳机图标和"听力"文字
                const Row(
                  children: [
                    Icon(Icons.headset),
                    SizedBox(width: 5), // 使用SizedBox替代Padding更简洁
                    Text(
                      "听力",
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 15), // 左侧与搜索框之间的间距

                // 中间部分：搜索框（使用Expanded使其自适应宽度）
                // 搜索框区域，包含图标和输入框
                Expanded(
                  child: Container(
                    height: 30,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.search, size: 16),
                        SizedBox(width: 5),
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: '搜索',
                              hintStyle: TextStyle(fontSize: 14),
                              // contentPadding: EdgeInsets.symmetric(vertical: 0),
                              isDense: true,
                            ),
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10), // 搜索框与右边缘的间距
              ],
            ),
          ),
          body: Stack(
            children: [
              // 主要内容区域
              Column(
                children: [
                  const Divider(height: 1, thickness: 1, color: Colors.grey),
                  // 添加文件、作者、歌单标签行
                  Container(
                    color: Colors.grey.shade400,
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: Row(
                      children: [
                        // 文件按钮
                        InkWell(
                          onTap: () => ListeningTabState.switchPage(context, 0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                            decoration: BoxDecoration(
                              color: selectedIndex == 0 ? Colors.white : Colors.grey.shade400,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Text(
                              '文件', 
                              style: TextStyle(
                                fontSize: 14,
                                color: selectedIndex == 0 ? Colors.black : Colors.white,
                              )
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        // 作者按钮
                        InkWell(
                          onTap: () => ListeningTabState.switchPage(context, 1),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                            decoration: BoxDecoration(
                              color: selectedIndex == 1 ? Colors.white : Colors.grey.shade400,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Text(
                              '作者', 
                              style: TextStyle(
                                fontSize: 14,
                                color: selectedIndex == 1 ? Colors.black : Colors.white,
                              )
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        // 歌单按钮
                        InkWell(
                          onTap: () => ListeningTabState.switchPage(context, 2),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                            decoration: BoxDecoration(
                              color: selectedIndex == 2 ? Colors.white : Colors.grey.shade400,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Text(
                              '歌单', 
                              style: TextStyle(
                                fontSize: 14,
                                color: selectedIndex == 2 ? Colors.black : Colors.white,
                              )
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 根据选中的索引显示不同的页面内容
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: selectedIndex == 0
                        ? const FilePage()
                        : selectedIndex == 1
                          ? const AuthorPage()
                          : const PlaylistPage(),
                    ),
                  )
                ],
              ),

              // 使用抽离出来的可展开按钮组件
              const ExpandableActionButtons(),
            ],
          ),
          endDrawer: Drawer(
            // 右侧抽屉菜单
            child: ListView(
              padding: EdgeInsets.zero,
              children: const <Widget>[
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                  ),
                  child: Text('Drawer Header'),
                ),
              ]
            )
          ),
        );
      }),
    );
  }
}

/// 卡片内容组件
/// 展示听力内容卡片列表
class CardDemo extends StatefulWidget {
  const CardDemo({super.key});

  @override
  State<CardDemo> createState() => _CardDemoState();
}

/// 卡片内容组件状态类
class _CardDemoState extends State<CardDemo> {
  @override
  Widget build(BuildContext context) {
    return ListView(children: const [
      Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          elevation: 10,
          child: ListTile(title: Text("When Are You Really An Adult?")))
    ]);
  }
}