import 'package:hive/hive.dart';

part 'journal_model.g.dart';

@HiveType(typeId: 3)
class JournalModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  DateTime date; // Date de l'entrée

  @HiveField(2)
  String? title; // Titre optionnel

  @HiveField(3)
  String content; // Contenu libre - le cœur du journal

  @HiveField(4)
  String? mood; // Humeur optionnelle : 'happy', 'sad', 'anxious', 'calm', 'irritated', 'energetic', 'tired', 'grateful', 'confused', 'peaceful'

  @HiveField(5)
  List<String> tags; // Tags personnels pour organiser

  @HiveField(6)
  DateTime createdAt;

  @HiveField(7)
  DateTime? updatedAt;

  @HiveField(8)
  bool isFavorite; // Marquer comme favori

  JournalModel({
    required this.id,
    required this.date,
    this.title,
    required this.content,
    this.mood,
    this.tags = const [],
    required this.createdAt,
    this.updatedAt,
    this.isFavorite = false,
  });

  // Copier avec mise à jour
  JournalModel copyWith({
    String? id,
    DateTime? date,
    String? title,
    String? content,
    String? mood,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isFavorite,
  }) {
    return JournalModel(
      id: id ?? this.id,
      date: date ?? this.date,
      title: title ?? this.title,
      content: content ?? this.content,
      mood: mood ?? this.mood,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'title': title,
      'content': content,
      'mood': mood,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isFavorite': isFavorite,
    };
  }

  factory JournalModel.fromJson(Map<String, dynamic> json) {
    return JournalModel(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      title: json['title'] as String?,
      content: json['content'] as String,
      mood: json['mood'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }
}

