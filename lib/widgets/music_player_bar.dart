import 'package:flutter/material.dart';

/// 底部音乐播放器横条组件
/// 参考QQ音乐、网易云音乐等播放器设计
/// 包含封面、歌曲信息和播放控制按钮
class MusicPlayerBar extends StatefulWidget {
  final String? songTitle;
  final String? artist;
  final String? coverImagePath;
  final bool hasAudio;
  
  const MusicPlayerBar({
    super.key,
    this.songTitle,
    this.artist,
    this.coverImagePath,
    this.hasAudio = false,
  });

  @override
  State<MusicPlayerBar> createState() => _MusicPlayerBarState();
}

class _MusicPlayerBarState extends State<MusicPlayerBar> {
  bool _isPlaying = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 左侧封面
          Container(
            width: 44,
            height: 44,
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[300],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/images/default_cover.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.music_note,
                      color: Colors.grey,
                      size: 24,
                    ),
                  );
                },
              ),
            ),
          ),
          // 中间歌曲信息
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.hasAudio ? (widget.songTitle ?? '未知歌曲') : '无音频',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.hasAudio ? (widget.artist ?? '未知艺术家') : '暂无播放内容',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          // 右侧控制按钮
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 播放/暂停按钮
              IconButton(
                onPressed: () {
                  setState(() {
                    _isPlaying = !_isPlaying;
                  });
                },
                icon: Icon(
                  _isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.black87,
                  size: 24,
                ),
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(
                  minWidth: 40,
                  minHeight: 40,
                ),
              ),
              // 下一首按钮
              IconButton(
                onPressed: () {
                  // TODO: 实现下一首功能
                },
                icon: const Icon(
                  Icons.skip_next,
                  color: Colors.black87,
                  size: 24,
                ),
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(
                  minWidth: 40,
                  minHeight: 40,
                ),
              ),
              // 播放列表按钮
              IconButton(
                onPressed: () {
                  // TODO: 实现播放列表功能
                },
                icon: const Icon(
                  Icons.queue_music,
                  color: Colors.black87,
                  size: 24,
                ),
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(
                  minWidth: 40,
                  minHeight: 40,
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ],
      ),
    );
  }
}