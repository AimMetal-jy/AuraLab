/// 音色数据模型
class VoiceModel {
  final String id;
  final String name;
  final String description;
  final String engine;
  final String mode;

  const VoiceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.engine,
    required this.mode,
  });

  @override
  String toString() => '$name ($description)';
}

/// 音色引擎类型
enum VoiceEngine {
  short('short_audio_synthesis_jovi', '短音频合成', 'short'),
  long('long_audio_synthesis_screen', '长音频合成', 'long'),
  humanoid('tts_humanoid_lam', '大模型音色', 'human');

  const VoiceEngine(this.id, this.name, this.mode);

  final String id;
  final String name;
  final String mode;
}

/// 音色配置类
class VoiceConfig {
  static const List<VoiceModel> _shortAudioVoices = [
    VoiceModel(
      id: 'vivoHelper',
      name: '奕雯',
      description: '智能助手音色',
      engine: 'short_audio_synthesis_jovi',
      mode: 'short',
    ),
    VoiceModel(
      id: 'yunye',
      name: '云野',
      description: '温柔男声',
      engine: 'short_audio_synthesis_jovi',
      mode: 'short',
    ),
    VoiceModel(
      id: 'wanqing',
      name: '婉清',
      description: '御姐音色',
      engine: 'short_audio_synthesis_jovi',
      mode: 'short',
    ),
    VoiceModel(
      id: 'xiaofu',
      name: '晓芙',
      description: '少女音色',
      engine: 'short_audio_synthesis_jovi',
      mode: 'short',
    ),
    VoiceModel(
      id: 'yige_child',
      name: '小萌',
      description: '女童音色',
      engine: 'short_audio_synthesis_jovi',
      mode: 'short',
    ),
    VoiceModel(
      id: 'yige',
      name: '依格',
      description: '标准女声',
      engine: 'short_audio_synthesis_jovi',
      mode: 'short',
    ),
    VoiceModel(
      id: 'yiyi',
      name: '依依',
      description: '甜美女声',
      engine: 'short_audio_synthesis_jovi',
      mode: 'short',
    ),
    VoiceModel(
      id: 'xiaoming',
      name: '小茗',
      description: '清新音色',
      engine: 'short_audio_synthesis_jovi',
      mode: 'short',
    ),
  ];

  static const List<VoiceModel> _longAudioVoices = [
    VoiceModel(
      id: 'x2_vivoHelper',
      name: '奕雯',
      description: '智能助手音色',
      engine: 'long_audio_synthesis_screen',
      mode: 'long',
    ),
    VoiceModel(
      id: 'x2_yige',
      name: '依格',
      description: '甜美女声',
      engine: 'long_audio_synthesis_screen',
      mode: 'long',
    ),
    VoiceModel(
      id: 'x2_yige_news',
      name: '依格',
      description: '稳重播报',
      engine: 'long_audio_synthesis_screen',
      mode: 'long',
    ),
    VoiceModel(
      id: 'x2_yunye',
      name: '云野',
      description: '温柔男声',
      engine: 'long_audio_synthesis_screen',
      mode: 'long',
    ),
    VoiceModel(
      id: 'x2_yunye_news',
      name: '云野',
      description: '稳重播报',
      engine: 'long_audio_synthesis_screen',
      mode: 'long',
    ),
    VoiceModel(
      id: 'x2_M02',
      name: '怀斌',
      description: '浑厚男声',
      engine: 'long_audio_synthesis_screen',
      mode: 'long',
    ),
    VoiceModel(
      id: 'x2_M05',
      name: '兆坤',
      description: '成熟男声',
      engine: 'long_audio_synthesis_screen',
      mode: 'long',
    ),
    VoiceModel(
      id: 'x2_M10',
      name: '亚恒',
      description: '磁性男声',
      engine: 'long_audio_synthesis_screen',
      mode: 'long',
    ),
    VoiceModel(
      id: 'x2_F163',
      name: '晓云',
      description: '稳重女声',
      engine: 'long_audio_synthesis_screen',
      mode: 'long',
    ),
    VoiceModel(
      id: 'x2_F25',
      name: '倩倩',
      description: '清甜女声',
      engine: 'long_audio_synthesis_screen',
      mode: 'long',
    ),
    VoiceModel(
      id: 'x2_F22',
      name: '海蔚',
      description: '大气女声',
      engine: 'long_audio_synthesis_screen',
      mode: 'long',
    ),
    VoiceModel(
      id: 'x2_F82',
      name: 'English',
      description: '英文女声',
      engine: 'long_audio_synthesis_screen',
      mode: 'long',
    ),
  ];

  static const List<VoiceModel> _humanoidVoices = [
    VoiceModel(
      id: 'F245_natural',
      name: '知性女声',
      description: '知性柔美',
      engine: 'tts_humanoid_lam',
      mode: 'human',
    ),
    VoiceModel(
      id: 'M24',
      name: '俊朗男声',
      description: '俊朗大气',
      engine: 'tts_humanoid_lam',
      mode: 'human',
    ),
    VoiceModel(
      id: 'M193',
      name: '理性男声',
      description: '理性沉稳',
      engine: 'tts_humanoid_lam',
      mode: 'human',
    ),
    VoiceModel(
      id: 'GAME_GIR_YG',
      name: '游戏少女',
      description: '活泼可爱',
      engine: 'tts_humanoid_lam',
      mode: 'human',
    ),
    VoiceModel(
      id: 'GAME_GIR_MB',
      name: '游戏萌宝',
      description: '萌萌哒',
      engine: 'tts_humanoid_lam',
      mode: 'human',
    ),
    VoiceModel(
      id: 'GAME_GIR_YJ',
      name: '游戏御姐',
      description: '成熟魅力',
      engine: 'tts_humanoid_lam',
      mode: 'human',
    ),
    VoiceModel(
      id: 'GAME_GIR_LTY',
      name: '电台主播',
      description: '专业播音',
      engine: 'tts_humanoid_lam',
      mode: 'human',
    ),
    VoiceModel(
      id: 'YIGEXIAOV',
      name: '依格小V',
      description: '智能助手',
      engine: 'tts_humanoid_lam',
      mode: 'human',
    ),
    VoiceModel(
      id: 'FY_CANTONESE',
      name: '粤语音色',
      description: '粤语发音',
      engine: 'tts_humanoid_lam',
      mode: 'human',
    ),
    VoiceModel(
      id: 'FY_SICHUANHUA',
      name: '四川话',
      description: '四川方言',
      engine: 'tts_humanoid_lam',
      mode: 'human',
    ),
  ];

  /// 获取指定引擎的音色列表
  static List<VoiceModel> getVoicesByEngine(VoiceEngine engine) {
    switch (engine) {
      case VoiceEngine.short:
        return _shortAudioVoices;
      case VoiceEngine.long:
        return _longAudioVoices;
      case VoiceEngine.humanoid:
        return _humanoidVoices;
    }
  }

  /// 获取所有音色
  static List<VoiceModel> getAllVoices() {
    return [..._shortAudioVoices, ..._longAudioVoices, ..._humanoidVoices];
  }

  /// 根据ID查找音色
  static VoiceModel? findVoiceById(String id) {
    try {
      return getAllVoices().firstWhere((voice) => voice.id == id);
    } catch (e) {
      return null;
    }
  }

  /// 获取默认音色
  static VoiceModel getDefaultVoice(VoiceEngine engine) {
    final voices = getVoicesByEngine(engine);
    return voices.isNotEmpty ? voices.first : _humanoidVoices.first;
  }
}