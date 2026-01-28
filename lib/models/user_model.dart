import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  DateTime? dateOfBirth;

  @HiveField(3)
  DateTime? lastPeriodDate;

  @HiveField(4)
  int averageCycleLength; // Durée moyenne du cycle en jours (par défaut 28)

  @HiveField(5)
  int averagePeriodLength; // Durée moyenne des règles en jours (par défaut 5)

  @HiveField(6)
  DateTime createdAt;

  @HiveField(7)
  DateTime? updatedAt;

  @HiveField(8)
  double? weight; // Poids en kg (optionnel)

  @HiveField(9)
  double? height; // Taille en cm (optionnel)

  @HiveField(10)
  bool notificationsEnabled;

  @HiveField(11)
  String? profileImagePath; // Chemin de l'image (asset ou fichier local)

  @HiveField(12)
  String? avatarAsset;

  @HiveField(13)
  int minCycleLength;

  @HiveField(14)
  int maxCycleLength;

  @HiveField(15)
  int minPeriodLength;

  @HiveField(16)
  int maxPeriodLength;

  @HiveField(17)
  bool allowAiSymptoms;

  @HiveField(18)
  bool allowAiJournal;

  UserModel({
    required this.id,
    required this.name,
    this.dateOfBirth,
    this.lastPeriodDate,
    this.averageCycleLength = 28,
    this.averagePeriodLength = 5,
    this.minCycleLength = 28,
    this.maxCycleLength = 28,
    this.minPeriodLength = 5,
    this.maxPeriodLength = 5,
    this.allowAiSymptoms = true,
    this.allowAiJournal = true,
    required this.createdAt,
    this.updatedAt,
    this.weight,
    this.height,
    this.notificationsEnabled = true,
    this.profileImagePath,
    this.avatarAsset,
  });

  // Calculer l'âge à partir de la date de naissance
  int? get age {
    if (dateOfBirth == null) return null;
    final now = DateTime.now();
    int age = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month ||
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      age--;
    }
    return age;
  }

  // Calculer la prochaine période prévue
  DateTime? get nextPeriodDate {
    if (lastPeriodDate == null) return null;

    // Calculer la prochaine période en s'assurant qu'elle est dans le futur
    DateTime prediction = lastPeriodDate!.add(
      Duration(days: averageCycleLength),
    );
    final now = DateTime.now();

    // Si la prédiction est dans le passé, ajouter des cycles jusqu'à être dans le futur
    while (prediction.isBefore(now)) {
      prediction = prediction.add(Duration(days: averageCycleLength));
    }

    return prediction;
  }

  // Calculer les jours restants jusqu'à la prochaine période
  int? get daysUntilNextPeriod {
    if (nextPeriodDate == null) return null;
    final now = DateTime.now();
    final difference = nextPeriodDate!.difference(now).inDays;
    return difference >= 0 ? difference : null;
  }

  // Vérifier si l'utilisatrice est actuellement en période
  bool get isCurrentlyOnPeriod {
    if (lastPeriodDate == null) return false;
    final now = DateTime.now();
    final daysSinceLastPeriod = now.difference(lastPeriodDate!).inDays;
    return daysSinceLastPeriod >= 0 &&
        daysSinceLastPeriod < averagePeriodLength;
  }

  // Copier avec mise à jour
  UserModel copyWith({
    String? id,
    String? name,
    DateTime? dateOfBirth,
    DateTime? lastPeriodDate,
    int? averageCycleLength,
    int? averagePeriodLength,
    int? minCycleLength,
    int? maxCycleLength,
    int? minPeriodLength,
    int? maxPeriodLength,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? weight,
    double? height,
    bool? notificationsEnabled,
    String? profileImagePath,
    String? avatarAsset,
    bool? allowAiSymptoms,
    bool? allowAiJournal,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      lastPeriodDate: lastPeriodDate ?? this.lastPeriodDate,
      averageCycleLength: averageCycleLength ?? this.averageCycleLength,
      averagePeriodLength: averagePeriodLength ?? this.averagePeriodLength,
      minCycleLength: minCycleLength ?? this.minCycleLength,
      maxCycleLength: maxCycleLength ?? this.maxCycleLength,
      minPeriodLength: minPeriodLength ?? this.minPeriodLength,
      maxPeriodLength: maxPeriodLength ?? this.maxPeriodLength,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      weight: weight ?? this.weight,
      height: height ?? this.height,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      avatarAsset: avatarAsset ?? this.avatarAsset,
      allowAiSymptoms: allowAiSymptoms ?? this.allowAiSymptoms,
      allowAiJournal: allowAiJournal ?? this.allowAiJournal,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'lastPeriodDate': lastPeriodDate?.toIso8601String(),
      'averageCycleLength': averageCycleLength,
      'averagePeriodLength': averagePeriodLength,
      'minCycleLength': minCycleLength,
      'maxCycleLength': maxCycleLength,
      'minPeriodLength': minPeriodLength,
      'maxPeriodLength': maxPeriodLength,
      'allowAiSymptoms': allowAiSymptoms,
      'allowAiJournal': allowAiJournal,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'weight': weight,
      'height': height,
      'notificationsEnabled': notificationsEnabled,
      'profileImagePath': profileImagePath,
      'avatarAsset': avatarAsset,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'] as String)
          : null,
      lastPeriodDate: json['lastPeriodDate'] != null
          ? DateTime.parse(json['lastPeriodDate'] as String)
          : null,
      averageCycleLength: json['averageCycleLength'] as int? ?? 28,
      averagePeriodLength: json['averagePeriodLength'] as int? ?? 5,
      minCycleLength:
          json['minCycleLength'] as int? ??
          json['averageCycleLength'] as int? ??
          28,
      maxCycleLength:
          json['maxCycleLength'] as int? ??
          json['averageCycleLength'] as int? ??
          28,
      minPeriodLength:
          json['minPeriodLength'] as int? ??
          json['averagePeriodLength'] as int? ??
          5,
      maxPeriodLength:
          json['maxPeriodLength'] as int? ??
          json['averagePeriodLength'] as int? ??
          5,
      allowAiSymptoms: json['allowAiSymptoms'] as bool? ?? true,
      allowAiJournal: json['allowAiJournal'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      weight: json['weight'] != null
          ? (json['weight'] as num).toDouble()
          : null,
      height: json['height'] != null
          ? (json['height'] as num).toDouble()
          : null,
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      profileImagePath: json['profileImagePath'] as String?,
      avatarAsset: json['avatarAsset'] as String?,
    );
  }
}
