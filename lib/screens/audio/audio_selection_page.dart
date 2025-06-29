import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;
import '../../services/audio_service.dart';
import '../../widgets/tab_page_scaffold.dart';
import '../../models/voice_model.dart';

/// 音频选择页面
/// 提供两种添加音频的方式：AI生成语音和本地文件上传
class AudioSelectionPage extends StatefulWidget {
  const AudioSelectionPage({super.key});

  @override
  State<AudioSelectionPage> createState() => _AudioSelectionPageState();
}

class _AudioSelectionPageState extends State<AudioSelectionPage>
    with SingleTickerProviderStateMixin {
  static const String baseUrl = 'http://localhost:8888';
  late TabController _tabController;
  
  // AI生成语音相关状态
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _chatController = TextEditingController();
  VoiceEngine _selectedEngine = VoiceEngine.humanoid;
  VoiceModel? _selectedVoice;
  bool _isGenerating = false;
  bool _isChatting = false;
  List<Map<String, String>> _chatHistory = [];
  String? _sessionId;
  String? _errorMessage;
  
  // 本地文件上传相关状态
  File? _selectedFile;
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  
  // AI生成语音的步骤控制
  int _aiGenerationStep = 1; // 1: AI对话, 2: 文本转语音
  
  // 滚动控制器
  final ScrollController _chatScrollController = ScrollController();
  final ScrollController _textScrollController = ScrollController();
  
  // 音频播放器
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // 设置默认音色
    _selectedVoice = VoiceConfig.getDefaultVoice(_selectedEngine);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _textController.dispose();
    _chatController.dispose();
    _chatScrollController.dispose();
    _textScrollController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  // 发送聊天消息
  Future<void> _sendChatMessage() async {
    final message = _chatController.text.trim();
    if (message.isEmpty) return;

    setState(() {
      _chatHistory.add({'role': 'user', 'content': message});
      _isChatting = true;
      _errorMessage = null;
    });
    _chatController.clear();
    
    // 滚动到底部
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_chatScrollController.hasClients) {
        _chatScrollController.animateTo(
          _chatScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    try {
      final response = await AudioService.sendChatMessage(
        message,
        sessionId: _sessionId,
        historyMessages: _chatHistory.where((msg) => msg['role'] != 'error').toList(),
      );
      
      if (mounted) {
        setState(() {
          _sessionId = response['session_id'];
          _chatHistory.add({
            'role': 'assistant', 
            'content': response['reply'] ?? '无回复内容',
            'timestamp': response['timestamp'] ?? DateTime.now().toString(),
          });
          _isChatting = false;
        });
        
        // 再次滚动到底部
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_chatScrollController.hasClients) {
            _chatScrollController.animateTo(
              _chatScrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _chatHistory.add({
            'role': 'error', 
            'content': '发送失败：$e'
          });
          _isChatting = false;
          _errorMessage = e.toString();
        });
      }
    }
  }
  
  // 将AI回复添加到文本框
  void _addAIReplyToText(String content) {
    setState(() {
      if (_textController.text.isNotEmpty) {
        _textController.text += '\n$content';
      } else {
        _textController.text = content;
      }
    });
  }
  
  // 切换到下一步
  void _goToNextStep() {
    if (_textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先添加一些文本内容')),
      );
      return;
    }
    setState(() {
      _aiGenerationStep = 2;
    });
  }
  
  // 返回上一步
  void _goToPreviousStep() {
    setState(() {
      _aiGenerationStep = 1;
    });
  }
  
  // 切换音色引擎
  void _onEngineChanged(VoiceEngine? engine) {
    if (engine != null && engine != _selectedEngine) {
      setState(() {
        _selectedEngine = engine;
        _selectedVoice = VoiceConfig.getDefaultVoice(engine);
        _errorMessage = null;
      });
    }
  }
  
  // 选择音色
  void _onVoiceChanged(VoiceModel? voice) {
    if (voice != null) {
      setState(() {
        _selectedVoice = voice;
        _errorMessage = null;
      });
    }
  }
  
  // 生成语音
  Future<void> _generateSpeech() async {
    if (_textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请输入要转换的文本'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    if (_selectedVoice == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请选择音色'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    setState(() {
      _isGenerating = true;
      _errorMessage = null;
    });
    
    try {
      // 调用后端TTS接口
      final audioBytes = await AudioService.generateSpeech(
        text: _textController.text,
        voice: _selectedVoice!,
      );
      
      if (mounted) {
        // 保存音频文件到本地
        final directory = await getApplicationDocumentsDirectory();
        final fileName = 'generated_audio_${DateTime.now().millisecondsSinceEpoch}.wav';
        final file = File('${directory.path}/$fileName');
        await file.writeAsBytes(audioBytes);
        
        // 显示预览对话框
        _showAudioPreviewDialog(file, _textController.text);
        
        // 可选：返回上一页或清空文本
        // Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('生成失败: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: '重试',
              textColor: Colors.white,
              onPressed: _generateSpeech,
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }
  
  // 选择本地文件
  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );
      
      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('文件选择失败: $e')),
      );
    }
  }
  
  // 上传文件
  Future<void> _uploadFile() async {
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先选择文件')),
      );
      return;
    }
    
    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });
    
    try {
      // 调用后端上传接口
      final result = await AudioService.uploadAudio(
        _selectedFile!,
        onProgress: (progress) {
          setState(() {
            _uploadProgress = progress;
          });
        },
      );
      
      setState(() {
        _isUploading = false;
      });
      
      if (result['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('文件上传成功！任务ID: ${result['task_id']}')),
          );
          Navigator.of(context).pop();
        }
      } else {
        throw Exception(result['message'] ?? '上传失败');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('上传失败: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
          _uploadProgress = 0.0;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return TabPageScaffold(
      title: '添加音频',
      tabs: const [
        Tab(
          icon: Icon(Icons.smart_toy),
          text: 'AI生成语音',
        ),
        Tab(
          icon: Icon(Icons.upload_file),
          text: '本地上传',
        ),
      ],
      children: [
        _buildAIGenerationTab(),
        _buildLocalUploadTab(),
      ],
    );
  }
  
  // AI生成语音标签页
  Widget _buildAIGenerationTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: _aiGenerationStep == 1 
          ? _buildAIChatStep() 
          : _buildTextToSpeechStep(),
    );
  }
  
  // 第一步：AI对话
  Widget _buildAIChatStep() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        // 步骤指示器
        Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  '1',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'AI对话生成文本',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // AI对话区域
        SizedBox(
          height: 400, // 设置固定高度
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '与AI对话，生成您需要的文本内容',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Expanded(
                          child: ListView.builder(
                            controller: _chatScrollController,
                            padding: const EdgeInsets.all(8),
                            itemCount: _chatHistory.length + (_isChatting ? 1 : 0),
                            itemBuilder: (context, index) {
                              // 显示加载指示器
                              if (index == _chatHistory.length && _isChatting) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.smart_toy, size: 16),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade200,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            Text('AI正在思考...'),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                              
                              final message = _chatHistory[index];
                              final isUser = message['role'] == 'user';
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  mainAxisAlignment: isUser 
                                      ? MainAxisAlignment.end 
                                      : MainAxisAlignment.start,
                                  children: [
                                    if (!isUser) ...[
                                      const Icon(Icons.smart_toy, size: 16, color: Colors.blue),
                                      const SizedBox(width: 8),
                                    ],
                                    Flexible(
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: isUser 
                                              ? Theme.of(context).primaryColor
                                              : Colors.grey.shade200,
                                          borderRadius: BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withAlpha(26),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              message['content']!,
                                              style: TextStyle(
                                                color: isUser ? Colors.white : Colors.black87,
                                                fontSize: 14,
                                              ),
                                            ),
                                            if (message['timestamp'] != null)
                                              Padding(
                                                padding: const EdgeInsets.only(top: 4),
                                                child: Text(
                                                  message['timestamp']!,
                                                  style: TextStyle(
                                                    color: isUser 
                                                        ? Colors.white.withAlpha(179)
                                                        : Colors.grey[600],
                                                    fontSize: 10,
                                                  ),
                                                ),
                                              ),
                                            if (!isUser)
                                              Padding(
                                                padding: const EdgeInsets.only(top: 8),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    TextButton.icon(
                                                      onPressed: () => _addAIReplyToText(message['content']!),
                                                      icon: const Icon(Icons.add, size: 16),
                                                      label: const Text(
                                                        '添加到文本框',
                                                        style: TextStyle(fontSize: 12),
                                                      ),
                                                      style: TextButton.styleFrom(
                                                        padding: const EdgeInsets.symmetric(
                                                          horizontal: 8, vertical: 4
                                                        ),
                                                        minimumSize: Size.zero,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    if (isUser) ...[
                                      const SizedBox(width: 8),
                                      const Icon(Icons.person, size: 16, color: Colors.green),
                                    ],
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                          Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                border: Border(top: BorderSide(color: Colors.grey.shade300)),
                              ),
                              child: Column(
                                children: [
                                  // 错误消息显示
                                  if (_errorMessage?.isNotEmpty == true)
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(8),
                                      margin: const EdgeInsets.only(bottom: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade50,
                                        border: Border.all(color: Colors.red.shade200),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.error_outline,
                                            color: Colors.red.shade600,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              _errorMessage ?? '',
                                              style: TextStyle(
                                                color: Colors.red.shade700,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: () {
                                              setState(() {
                                                _errorMessage = '';
                                              });
                                            },
                                            icon: Icon(
                                              Icons.close,
                                              color: Colors.red.shade600,
                                              size: 16,
                                            ),
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                          ),
                                        ],
                                      ),
                                    ),
                                  // 输入区域
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: _chatController,
                                          enabled: !_isChatting,
                                          decoration: InputDecoration(
                                            hintText: _isChatting ? 'AI正在回复中...' : '输入消息...',
                                            border: const OutlineInputBorder(),
                                            contentPadding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 8
                                            ),
                                            suffixIcon: _chatController.text.isNotEmpty
                                                ? IconButton(
                                                    onPressed: () {
                                                      _chatController.clear();
                                                      setState(() {});
                                                    },
                                                    icon: const Icon(Icons.clear, size: 16),
                                                  )
                                                : null,
                                          ),
                                          onSubmitted: (_) => _isChatting ? null : _sendChatMessage(),
                                          onChanged: (value) {
                                            setState(() {});
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        onPressed: _isChatting || _chatController.text.trim().isEmpty
                                            ? null
                                            : _sendChatMessage,
                                        icon: _isChatting
                                            ? const SizedBox(
                                                width: 16,
                                                height: 16,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                ),
                                              )
                                            : const Icon(Icons.send),
                                        color: Theme.of(context).primaryColor,
                                        tooltip: _isChatting ? '发送中...' : '发送消息',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // 文本预览和下一步按钮
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '文本预览',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  height: 100,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey.shade50,
                  ),
                  child: TextField(
                    controller: _textController,
                    maxLines: null,
                    decoration: const InputDecoration(
                      hintText: '通过AI对话添加的文本将显示在这里...',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _goToNextStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      '下一步：文本转语音',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }
  
  // 第二步：文本转语音
  Widget _buildTextToSpeechStep() {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        // 步骤指示器
        Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  '2',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              '文本转语音',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: _goToPreviousStep,
              child: const Text('返回上一步'),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // 文本转语音设置区域
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '配置语音参数并生成',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // 引擎选择
                  Row(
                    children: [
                      const Text(
                        '引擎模式：',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButton<VoiceEngine>(
                          value: _selectedEngine,
                          isExpanded: true,
                          items: VoiceEngine.values.map((engine) {
                            String displayName;
                            String description;
                            switch (engine) {
                              case VoiceEngine.short:
                                displayName = '短音频合成';
                                description = '适合短文本，响应快速';
                                break;
                              case VoiceEngine.long:
                                displayName = '长音频合成';
                                description = '适合长文本，质量更高';
                                break;
                              case VoiceEngine.humanoid:
                                displayName = '大模型语音';
                                description = '最自然的语音效果';
                                break;
                            }
                            return DropdownMenuItem<VoiceEngine>(
                              value: engine,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    displayName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    description,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: _onEngineChanged,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 音色选择
                  Row(
                    children: [
                      const Text(
                        '音色选择：',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButton<VoiceModel>(
                          value: _selectedVoice,
                          isExpanded: true,
                          hint: const Text('请选择音色'),
                          items: VoiceConfig.getVoicesByEngine(_selectedEngine)
                              .map((voice) {
                            return DropdownMenuItem<VoiceModel>(
                              value: voice,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    voice.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  if (voice.description.isNotEmpty)
                                    Text(
                                      voice.description,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: _onVoiceChanged,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 文本输入框
                  Container(
                    height: 200, // 设置固定高度
                    child: TextField(
                        controller: _textController,
                        maxLines: null,
                        expands: true,
                        decoration: const InputDecoration(
                          hintText: '请编辑要转换为语音的文本...',
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
                        ),
                      ),
                    ),
                  
                  const SizedBox(height: 16),
                  
                  // 错误消息显示
                  if (_errorMessage?.isNotEmpty == true)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        border: Border.all(color: Colors.red.shade200),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red.shade600,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '生成失败',
                                  style: TextStyle(
                                    color: Colors.red.shade700,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _errorMessage ?? '',
                                  style: TextStyle(
                                    color: Colors.red.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _errorMessage = '';
                              });
                              _generateSpeech();
                            },
                            child: const Text('重试'),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _errorMessage = '';
                              });
                            },
                            icon: Icon(
                              Icons.close,
                              color: Colors.red.shade600,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  // 生成按钮
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (_isGenerating || 
                                  _textController.text.trim().isEmpty || 
                                  _selectedVoice == null) 
                          ? null 
                          : _generateSpeech,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: _isGenerating ? 0 : 2,
                      ),
                      child: _isGenerating
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text('生成中...'),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.mic, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  _textController.text.trim().isEmpty
                                      ? '请输入文本'
                                      : _selectedVoice == null
                                          ? '请选择音色'
                                          : '生成语音',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // 本地上传标签页
  Widget _buildLocalUploadTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '选择音频文件',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // 文件选择区域
                  Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey.shade300,
                        style: BorderStyle.solid,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey.shade50,
                    ),
                    child: _selectedFile == null
                        ? InkWell(
                            onTap: _pickFile,
                            borderRadius: BorderRadius.circular(12),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.cloud_upload,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  '点击选择音频文件',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  '支持 MP3, WAV, M4A 等格式',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.audio_file,
                                size: 64,
                                color: Colors.blue,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _selectedFile!.path.split('/').last,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '文件大小: ${(_selectedFile!.lengthSync() / 1024 / 1024).toStringAsFixed(2)} MB',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  TextButton(
                                    onPressed: _pickFile,
                                    child: const Text('重新选择'),
                                  ),
                                  const SizedBox(width: 16),
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _selectedFile = null;
                                      });
                                    },
                                    child: const Text('移除文件'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // 上传进度
                  if (_isUploading) ...[
                    const Text(
                      '上传进度',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: _uploadProgress,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${(_uploadProgress * 100).toInt()}%',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // 上传按钮
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (_selectedFile == null || _isUploading) 
                          ? null 
                          : _uploadFile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isUploading
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text('上传中...'),
                              ],
                            )
                          : const Text(
                              '上传文件',
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          ],
        ),
      ),
    );
  }

  // 音频转文字功能
  Future<void> _transcribeAudio(File audioFile) async {
    try {
      // 显示加载对话框
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text('正在转换音频为文字...'),
              ],
            ),
          );
        },
      );

      // 准备请求
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/transcribe'),
      );
      
      // 添加音频文件
      request.files.add(
        await http.MultipartFile.fromPath(
          'audio',
          audioFile.path,
        ),
      );

      // 发送请求
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      
      // 关闭加载对话框
      Navigator.of(context).pop();

      if (response.statusCode == 200) {
        var data = json.decode(responseBody);
        String transcribedText = data['text'] ?? '转换失败';
        
        // 显示转换结果
        _showTranscriptionResult(transcribedText);
      } else {
        _showErrorDialog('音频转文字失败: ${response.statusCode}');
      }
    } catch (e) {
      // 关闭加载对话框
      Navigator.of(context).pop();
      _showErrorDialog('音频转文字失败: $e');
    }
  }

  // 显示转换结果对话框
  void _showTranscriptionResult(String transcribedText) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('音频转文字结果'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '转换结果:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SelectableText(
                    transcribedText,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('关闭'),
            ),
            ElevatedButton(
              onPressed: () {
                // 复制到剪贴板
                Clipboard.setData(ClipboardData(text: transcribedText));
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('文字已复制到剪贴板'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('复制文字'),
            ),
          ],
        );
      },
    );
  }

  // 显示错误对话框
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('错误'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }

  // 显示音频预览对话框
  void _showAudioPreviewDialog(File audioFile, String text) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AudioPreviewDialog(
          audioFile: audioFile,
          text: text,
          audioPlayer: _audioPlayer,
          onAddToHome: () {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('音频已添加到主页'),
                backgroundColor: Colors.green,
              ),
            );
            // TODO: 实现添加到主页的逻辑
          },
          onCancel: () {
            Navigator.of(context).pop();
          },
          onContinueToTranscription: () {
            Navigator.of(context).pop();
            _transcribeAudio(audioFile);
          },
        );
      },
    );
  }
}

// 音频预览对话框组件
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '文本内容:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.text,
                style: const TextStyle(fontSize: 14),
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