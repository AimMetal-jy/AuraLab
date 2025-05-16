import 'package:flutter/material.dart';
import 'package:auralab/util/widgets/custom_card.dart';
/// 文件页面组件
/// 展示听力文件列表
class FilePage extends StatefulWidget {
  const FilePage({super.key});

  @override
  State<FilePage> createState() => _FilePageState();
}

class _FilePageState extends State<FilePage> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        CustomCard(
          child: ListTile(title: Text("When Are You Really An Adult?")),
        ),
        CustomCard(
          child: ListTile(title: Text("The Science of Happiness")),
        ),
        CustomCard(
          child: ListTile(title: Text("How to Learn a New Language")),
        ),
        CustomCard(
          child: ListTile(title: Text("The Future of Technology")),
        ),
      ],
    );
  }
}