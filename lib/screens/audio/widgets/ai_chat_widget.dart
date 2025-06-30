import 'package:flutter/material.dart';
import '../../../services/audio_service.dart';

/// AI聊天组件
class AIChatWidget extends StatefulWidget {
  final TextEditingController textController;
  final VoidCallback? onTextAdded;
  final VoidCallback? onNextStep;

  const AIChatWidget({
    super.key,
    required this.textController,
    this.onTextAdded,
    this.onNextStep,
  });

  @override
  State<AIChatWidget> createState() => _AIChatWidgetState();
}

class _AIChatWidgetState extends State<AIChatWidget> {
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();
  
  bool _isChatting = false;
  List<Map<String, String>> _chatHistory = [];
  String? _sessionId;
  String? _errorMessage;

  @override
  void dispose() {
    _chatController.dispose();
    _chatScrollController.dispose();
    super.dispose();
  }

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
  
  void _addAIReplyToText(String content) {
    if (widget.textController.text.isNotEmpty) {
      widget.textController.text += '\n$content';
    } else {
      widget.textController.text = content;
    }
    widget.onTextAdded?.call();
  }

  @override
  Widget build(BuildContext context) {
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
                  crossAxisAlignment: CrossAxisAlignment.center,
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
                    controller: widget.textController,
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
                    onPressed: widget.onNextStep,
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
      ],
      ),
    );
  }
}