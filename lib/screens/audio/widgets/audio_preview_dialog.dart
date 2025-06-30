import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:io';

/// 音频预览对话框组件
class AudioPreviewDialog extends StatefulWidget {
  final File audioFile;
  final String text;
  final AudioPlayer audioPlayer;
  final VoidCallback onAddToHome;
  final VoidCallback onCancel;
  final VoidCallback? onContinueToTranscription;

  const AudioPreviewDialog({
    super.key,
    required this.audioFile,
    required this.text,
    required this.audioPlayer,
    required this.onAddToHome,
    required this.onCancel,
    this.onContinueToTranscription,
  });

  @override
  State<AudioPreviewDialog> createState() => _AudioPreviewDialogState();
}

class _AudioPreviewDialogState extends State<AudioPreviewDialog> {
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _setupAudioPlayer();
  }

  void _setupAudioPlayer() {
    widget.audioPlayer.onDurationChanged.listen((duration) {
      setState(() {
        _duration = duration;
      });
    });

    widget.audioPlayer.onPositionChanged.listen((position) {
      setState(() {
        _position = position;
      });
    });

    widget.audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        _isPlaying = state == PlayerState.playing;
      });
    });
  }

  Future<void> _playPause() async {
    if (_isPlaying) {
      await widget.audioPlayer.pause();
    } else {
      await widget.audioPlayer.play(DeviceFileSource(widget.audioFile.path));
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('音频预览'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              '文本内容:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: Container(
                width: double.infinity, // 让Container宽度占满
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    widget.text,
                    style: const TextStyle(fontSize: 14),
                    textAlign: TextAlign.center, // 文本居中
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '音频播放:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  onPressed: _playPause,
                  icon: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    size: 32,
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Slider(
                        value: _position.inSeconds.toDouble(),
                        max: _duration.inSeconds.toDouble(),
                        onChanged: (value) async {
                          await widget.audioPlayer.seek(
                            Duration(seconds: value.toInt()),
                          );
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_formatDuration(_position)),
                          Text(_formatDuration(_duration)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: widget.onCancel,
          child: const Text('取消'),
        ),
        if (widget.onContinueToTranscription != null)
          ElevatedButton(
            onPressed: widget.onContinueToTranscription,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('继续转文字'),
          ),
        ElevatedButton(
          onPressed: widget.onAddToHome,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
          ),
          child: const Text('添加到主页'),
        ),
      ],
    );
  }
}