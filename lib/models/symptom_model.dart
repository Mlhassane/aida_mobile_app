import 'package:hive/hive.dart';

part 'symptom_model.g.dart';

@HiveType(typeId: 2)
class SymptomModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  DateTime date; // Date du jour

  @HiveField(2)
  String? mood; // Humeur : 'happy', 'sad', 'anxious', 'calm', 'irritated', 'energetic', 'tired'

  @HiveField(3)
  List<String> symptoms; // Liste des symptômes : 'cramps', 'headache', 'bloating', 'nausea', 'backache', 'breast_tenderness', 'acne', 'fatigue'

  @HiveField(4)
  int? painLevel; // Niveau de douleur (0-10)

  @HiveField(5)
  String? flowLevel; // Niveau de flux : 'light', 'medium', 'heavy', 'spotting'

  @HiveField(6)
  String? notes; // Notes personnelles

  @HiveField(7)
  DateTime createdAt;

  @HiveField(8)
  DateTime? updatedAt;

  SymptomModel({
    required this.id,
    required this.date,
    this.mood,
    this.symptoms = const [],
    this.painLevel,
    this.flowLevel,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  // Copier avec mise à jour
  SymptomModel copyWith({
    String? id,
    DateTime? date,
    String? mood,
    List<String>? symptoms,
    int? painLevel,
    String? flowLevel,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SymptomModel(
      id: id ?? this.id,
      date: date ?? this.date,
      mood: mood ?? this.mood,
      symptoms: symptoms ?? this.symptoms,
      painLevel: painLevel ?? this.painLevel,
      flowLevel: flowLevel ?? this.flowLevel,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'mood': mood,
      'symptoms': symptoms,
      'painLevel': painLevel,
      'flowLevel': flowLevel,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory SymptomModel.fromJson(Map<String, dynamic> json) {
    return SymptomModel(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      mood: json['mood'] as String?,
      symptoms: (json['symptoms'] as List<dynamic>?)?.cast<String>() ?? [],
      painLevel: json['painLevel'] as int?,
      flowLevel: json['flowLevel'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }
}


