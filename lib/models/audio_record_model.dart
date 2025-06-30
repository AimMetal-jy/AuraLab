class AudioRecord {
  final int? id;
  final int userId;
  final String filePath;
  final String fileName;
  final int? duration; // 音频时长（秒）
  final String? transcription; // 转录文本
  final DateTime createdAt;

  AudioRecord({
    this.id,
    required this.userId,
    required this.filePath,
    required this.fileName,
    this.duration,
    this.transcription,
    required this.createdAt,
  });

  factory AudioRecord.fromJson(Map<String, dynamic> json) {
    return AudioRecord(
      id: json['id'] as int?,
      userId: json['user_id'] as int,
      filePath: json['file_path'] as String,
      fileName: json['file_name'] as String,
      duration: json['duration'] as int?,
      transcription: json['transcription'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'file_path': filePath,
      'file_name': fileName,
      'duration': duration,
      'transcription': transcription,
      'created_at': createdAt.toIso8601String(),
    };
  }

  AudioRecord copyWith({
    int? id,
    int? userId,
    String? filePath,
    String? fileName,
    int? duration,
    String? transcription,
    DateTime? createdAt,
  }) {
    return AudioRecord(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      filePath: filePath ?? this.filePath,
      fileName: fileName ?? this.fileName,
      duration: duration ?? this.duration,
      transcription: transcription ?? this.transcription,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'AudioRecord{id: $id, userId: $userId, fileName: $fileName, duration: $duration}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AudioRecord &&
        other.id == id &&
        other.userId == userId &&
        other.filePath == filePath &&
        other.fileName == fileName;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        filePath.hashCode ^
        fileName.hashCode;
  }
}