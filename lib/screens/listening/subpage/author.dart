import 'package:flutter/material.dart';

/// 作者页面组件
/// 展示听力内容作者列表
class AuthorPage extends StatefulWidget {
  const AuthorPage({super.key});

  @override
  State<AuthorPage> createState() => _AuthorPageState();
}

class _AuthorPageState extends State<AuthorPage> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          elevation: 10,
          child: ListTile(
            leading: CircleAvatar(child: Icon(Icons.person)),
            title: Text("TED Talks"),
            subtitle: Text("科普演讲"),
          )
        ),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          elevation: 10,
          child: ListTile(
            leading: CircleAvatar(child: Icon(Icons.person)),
            title: Text("BBC Learning"),
            subtitle: Text("英语教育"),
          )
        ),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          elevation: 10,
          child: ListTile(
            leading: CircleAvatar(child: Icon(Icons.person)),
            title: Text("NPR"),
            subtitle: Text("新闻广播"),
          )
        ),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          elevation: 10,
          child: ListTile(
            leading: CircleAvatar(child: Icon(Icons.person)),
            title: Text("Audible Originals"),
            subtitle: Text("有声读物"),
          )
        ),
      ],
    );
  }
}