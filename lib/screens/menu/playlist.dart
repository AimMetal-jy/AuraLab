import 'package:flutter/material.dart';

/// 歌单页面组件
/// 展示文档内容歌单列表
class PlaylistPage extends StatefulWidget {
  const PlaylistPage({super.key});

  @override
  State<PlaylistPage> createState() => _PlaylistPageState();
}

class _PlaylistPageState extends State<PlaylistPage> {
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
            leading: CircleAvatar(child: Icon(Icons.playlist_play)),
            title: Text("英语学习精选"),
            subtitle: Text("10个音频"),
          )
        ),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          elevation: 10,
          child: ListTile(
            leading: CircleAvatar(child: Icon(Icons.playlist_play)),
            title: Text("科技前沿讲座"),
            subtitle: Text("8个音频"),
          )
        ),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          elevation: 10,
          child: ListTile(
            leading: CircleAvatar(child: Icon(Icons.playlist_play)),
            title: Text("每日冥想"),
            subtitle: Text("15个音频"),
          )
        ),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          elevation: 10,
          child: ListTile(
            leading: CircleAvatar(child: Icon(Icons.playlist_play)),
            title: Text("经典有声书"),
            subtitle: Text("12个音频"),
          )
        ),
      ],
    );
  }
}