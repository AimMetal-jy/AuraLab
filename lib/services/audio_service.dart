import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/voice_model.dart';

/// 音频服务类
/// 负责处理音频相关的后端API调用
class AudioService {
  // 后端服务地址
  static const String _baseUrl = 'http://localhost:8888';
  static const String _flaskUrl = 'http://localhost:5000';
  
  /// 生成语音
  /// 
  /// [text] 要转换的文本
  /// [voice] 音色选择 (VoiceModel)
  /// [mode] 合成模式 (可选，从voice中获取)
  /// 
  /// 返回生成的音频文件字节数据
  static Future<List<int>> generateSpeech({
    required String text,
    required VoiceModel voice,
    String? mode,
  }) async {
    try {
      final requestBody = {
        'text': text,
        'vcn': voice.id,
        'mode': mode ?? voice.mode,
      };
      
      final response = await http.post(
        Uri.parse('$_baseUrl/bluelm/tts'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      ).timeout(const Duration(seconds: 30));
      
      if (response.statusCode == 200) {
        // 返回音频文件的字节数据
        return response.bodyBytes;
      } else {
        throw Exception('语音生成失败: HTTP ${response.statusCode}');
      }
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception('请求超时，请检查网络连接');
      }
      throw Exception('语音生成错误: $e');
    }
  }
  
  /// AI对话
  /// 
  /// [message] 用户消息
  /// [sessionId] 会话ID (可选)
  /// [historyMessages] 历史消息 (可选)
  /// 
  /// 返回AI回复内容
  static Future<Map<String, dynamic>> chatWithAI({
    required String message,
    String? sessionId,
    List<Map<String, String>>? historyMessages,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/bluelm/chat'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'message': message,
          'session_id': sessionId,
          'history_messages': historyMessages ?? [],
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': data['success'] ?? false,
          'reply': data['data']?['reply'] ?? '',
          'session_id': data['session_id'] ?? '',
          'messages': data['data']?['messages'] ?? [],
        };
      } else {
        throw Exception('AI对话请求失败: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('AI对话服务错误: $e');
    }
  }
  
  /// 发送聊天消息
  /// 
  /// [message] 用户消息
  /// [sessionId] 会话ID (可选)
  /// [historyMessages] 历史消息 (可选)
  /// 
  /// 返回AI回复和会话信息
  static Future<Map<String, dynamic>> sendChatMessage(
    String message, {
    String? sessionId,
    List<Map<String, String>>? historyMessages,
  }) async {
    try {
      final requestBody = {
        'message': message,
        if (sessionId != null) 'session_id': sessionId,
        'history_messages': historyMessages ?? [],
      };
      
      final response = await http.post(
        Uri.parse('$_baseUrl/bluelm/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      ).timeout(const Duration(seconds: 30));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return {
            'reply': data['data']['reply'] ?? '',
            'session_id': data['session_id'] ?? sessionId,
            'messages': data['data']['messages'] ?? [],
            'timestamp': data['timestamp'] ?? DateTime.now().toString(),
          };
        } else {
          throw Exception(data['message'] ?? 'AI回复失败');
        }
      } else {
        throw Exception('AI回复失败: HTTP ${response.statusCode}');
      }
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception('请求超时，请检查网络连接');
      }
      throw Exception('AI对话失败: $e');
    }
  }
  
  /// 上传音频文件
  /// 
  /// [audioFile] 要上传的音频文件
  /// [onProgress] 上传进度回调 (可选)
  /// 
  /// 返回上传结果
  static Future<Map<String, dynamic>> uploadAudio(
    File audioFile, {
    Function(double progress)? onProgress,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_flaskUrl/whisperx/process'),
      );
      
      // 添加文件
      var multipartFile = await http.MultipartFile.fromPath(
        'file',
        audioFile.path,
      );
      request.files.add(multipartFile);
      
      // 发送请求
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': data['success'] ?? false,
          'task_id': data['task_id'] ?? '',
          'message': data['message'] ?? '',
          'filename': data['filename'] ?? '',
        };
      } else {
        throw Exception('文件上传失败: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('文件上传错误: $e');
    }
  }
  
  /// 查询任务状态
  /// 
  /// [taskId] 任务ID
  /// 
  /// 返回任务状态信息
  static Future<Map<String, dynamic>> getTaskStatus(String taskId) async {
    try {
      final response = await http.get(
        Uri.parse('$_flaskUrl/whisperx/status/$taskId'),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('查询任务状态失败: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('查询任务状态错误: $e');
    }
  }
  
  /// 下载处理结果
  /// 
  /// [taskId] 任务ID
  /// [fileType] 文件类型 (transcript/srt/vtt等)
  /// 
  /// 返回下载的文件内容
  static Future<String> downloadResult(
    String taskId, 
    String fileType,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$_flaskUrl/whisperx/download/$taskId/$fileType'),
      );
      
      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw Exception('下载文件失败: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('下载文件错误: $e');
    }
  }
  
  /// 获取任务列表
  /// 
  /// 返回所有任务的列表
  static Future<List<Map<String, dynamic>>> getTaskList() async {
    try {
      final response = await http.get(
        Uri.parse('$_flaskUrl/whisperx/tasks'),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['tasks'] ?? []);
      } else {
        throw Exception('获取任务列表失败: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('获取任务列表错误: $e');
    }
  }
  
  /// 统一模型API - 提交任务
  /// 
  /// [model] 模型名称 (whisperx/bluelm)
  /// [audioFile] 音频文件
  /// [additionalParams] 额外参数 (可选)
  /// 
  /// 返回任务提交结果
  static Future<Map<String, dynamic>> submitUnifiedTask(
    String model,
    File audioFile, {
    Map<String, String>? additionalParams,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/model/?model=$model&action=submit'),
      );
      
      // 添加音频文件
      var multipartFile = await http.MultipartFile.fromPath(
        'audio',
        audioFile.path,
      );
      request.files.add(multipartFile);
      
      // 添加额外参数
      if (additionalParams != null) {
        request.fields.addAll(additionalParams);
      }
      
      // 发送请求
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('统一API任务提交失败: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('统一API任务提交错误: $e');
    }
  }
  
  /// 统一模型API - 查询状态
  /// 
  /// [model] 模型名称 (whisperx/bluelm)
  /// [taskId] 任务ID
  /// 
  /// 返回任务状态
  static Future<Map<String, dynamic>> getUnifiedTaskStatus(
    String model,
    String taskId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/model/?model=$model&action=status&task_id=$taskId'),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('统一API状态查询失败: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('统一API状态查询错误: $e');
    }
  }
  
  /// 统一模型API - 下载结果
  /// 
  /// [model] 模型名称 (whisperx/bluelm)
  /// [taskId] 任务ID
  /// [fileType] 文件类型 (可选)
  /// 
  /// 返回下载内容
  static Future<String> downloadUnifiedResult(
    String model,
    String taskId, {
    String? fileType,
  }) async {
    try {
      String url = '$_baseUrl/model/?model=$model&action=download&task_id=$taskId';
      if (fileType != null) {
        url += '&file_type=$fileType';
      }
      
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw Exception('统一API下载失败: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('统一API下载错误: $e');
    }
  }
  
  /// 统一模型API - 获取任务列表
  /// 
  /// [model] 模型名称 (whisperx/bluelm)
  /// 
  /// 返回任务列表
  static Future<List<Map<String, dynamic>>> getUnifiedTaskList(
    String model,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/model/?model=$model&action=list'),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['tasks'] ?? []);
      } else {
        throw Exception('统一API任务列表获取失败: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('统一API任务列表获取错误: $e');
    }
  }
}