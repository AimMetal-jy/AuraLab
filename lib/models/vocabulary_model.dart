class Vocabulary {
  final int? id;
  final int userId;
  final String word;
  final String? translation;
  final String? pronunciation;
  final String? exampleSentence;
  final DateTime createdAt;

  Vocabulary({
    this.id,
    required this.userId,
    required this.word,
    this.translation,
    this.pronunciation,
    this.exampleSentence,
    required this.createdAt,
  });

  factory Vocabulary.fromJson(Map<String, dynamic> json) {
    return Vocabulary(
      id: json['id'] as int?,
      userId: json['user_id'] as int,
      word: json['word'] as String,
      translation: json['translation'] as String?,
      pronunciation: json['pronunciation'] as String?,
      exampleSentence: json['example_sentence'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'word': word,
      'translation': translation,
      'pronunciation': pronunciation,
      'example_sentence': exampleSentence,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Vocabulary copyWith({
    int? id,
    int? userId,
    String? word,
    String? translation,
    String? pronunciation,
    String? exampleSentence,
    DateTime? createdAt,
  }) {
    return Vocabulary(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      word: word ?? this.word,
      translation: translation ?? this.translation,
      pronunciation: pronunciation ?? this.pronunciation,
      exampleSentence: exampleSentence ?? this.exampleSentence,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Vocabulary{id: $id, userId: $userId, word: $word, translation: $translation}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Vocabulary &&
        other.id == id &&
        other.userId == userId &&
        other.word == word &&
        other.translation == translation;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        word.hashCode ^
        translation.hashCode;
  }
}