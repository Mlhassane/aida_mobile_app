import 'package:hive/hive.dart';

part 'period_model.g.dart';

@HiveType(typeId: 1)
class PeriodModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  DateTime startDate; // Date de début des règles

  @HiveField(2)
  DateTime? endDate; // Date de fin des règles (null si en cours)

  @HiveField(3)
  int duration; // Durée en jours

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  DateTime? updatedAt;

  PeriodModel({
    required this.id,
    required this.startDate,
    this.endDate,
    required this.duration,
    required this.createdAt,
    this.updatedAt,
  });

  // Vérifier si les règles sont en cours
  bool get isActive {
    if (endDate != null) return false;
    final now = DateTime.now();
    final daysSinceStart = now.difference(startDate).inDays;
    return daysSinceStart >= 0 && daysSinceStart < duration;
  }

  // Obtenir la date de fin calculée
  DateTime get calculatedEndDate {
    return startDate.add(Duration(days: duration - 1));
  }

  // Copier avec mise à jour
  PeriodModel copyWith({
    String? id,
    DateTime? startDate,
    DateTime? endDate,
    int? duration,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PeriodModel(
      id: id ?? this.id,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      duration: duration ?? this.duration,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'duration': duration,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory PeriodModel.fromJson(Map<String, dynamic> json) {
    return PeriodModel(
      id: json['id'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : null,
      duration: json['duration'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }
}

