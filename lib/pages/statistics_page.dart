import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:iconly/iconly.dart';
import '../services/period_service.dart';
import '../services/symptom_service.dart';
import '../services/user_service.dart';
import '../models/period_model.dart';
import '../models/user_model.dart';
import '../core/theme_colors.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:hive_flutter/hive_flutter.dart';
import '../services/hive_service.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: HiveService.userBox.listenable(),
      builder: (context, _, __) {
        final user = UserService.getUser();
        if (user == null) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: ThemeColors.getPrimaryColor(context),
              ),
            ),
          );
        }

        return ValueListenableBuilder(
          valueListenable: HiveService.periodsBox.listenable(),
          builder: (context, _, __) {
            return ValueListenableBuilder(
              valueListenable: HiveService.symptomsBox.listenable(),
              builder: (context, _, __) {
                final periodStats = PeriodService.getStatistics();
                final symptomStats = SymptomService.getSymptomStatistics();
                final periods = PeriodService.getAllPeriods();

                return Scaffold(
                  backgroundColor: ThemeColors.getBackgroundColor(context),
                  appBar: AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    automaticallyImplyLeading: false,
                    title: Text(
                      'Analyses & Tendances',
                      style: TextStyle(
                        color: ThemeColors.getTextColor(context),
                        fontSize: MediaQuery.of(context).size.width < 380
                            ? 22
                            : 26,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                      ),
                    ),
                  ),
                  body: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Graphique de régularité
                        _buildRegularityChart(periodStats)
                            .animate()
                            .fadeIn(duration: 600.ms)
                            .slideY(begin: 0.2, end: 0),
                        const SizedBox(height: 24),

                        // Graphique des cycles
                        _buildCycleLengthChart(periods)
                            .animate()
                            .fadeIn(delay: 200.ms, duration: 600.ms)
                            .slideY(begin: 0.2, end: 0),
                        const SizedBox(height: 24),

                        // Statistiques des symptômes
                        if (symptomStats['totalEntries'] > 0) ...[
                          _buildSymptomStats(symptomStats)
                              .animate()
                              .fadeIn(delay: 400.ms, duration: 600.ms)
                              .slideY(begin: 0.2, end: 0),
                          const SizedBox(height: 24),
                          _buildSymptomPieChart(
                            symptomStats['symptomCounts'],
                          ).animate().fadeIn(delay: 600.ms, duration: 600.ms),
                          const SizedBox(height: 24),
                          _buildMoodPieChart(
                            symptomStats['moodCounts'],
                          ).animate().fadeIn(delay: 800.ms, duration: 600.ms),
                          const SizedBox(height: 24),
                          _buildSymptomFrequencyChart().animate().fadeIn(
                            delay: 900.ms,
                            duration: 600.ms,
                          ),
                          const SizedBox(height: 24),
                        ] else ...[
                          _buildNoSymptomDataWidget(),
                          const SizedBox(height: 24),
                        ],

                        // Statistiques générales
                        _buildGeneralStats(periodStats, user)
                            .animate()
                            .fadeIn(delay: 1000.ms, duration: 600.ms)
                            .slideY(begin: 0.2, end: 0),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildRegularityChart(Map<String, dynamic> stats) {
    final regularity = stats['regularity'] ?? 0;
    final status = stats['regularityStatus'] ?? 'Inconnu';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, const Color(0xFFFAFAFA)],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: ThemeColors.getPrimaryColor(context).withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ThemeColors.getPrimaryColor(context),
                      ThemeColors.getPrimaryColor(context).withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  IconlyBold.tick_square,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Régularité du cycle',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A),
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      status,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: MediaQuery.of(context).size.width < 380 ? 160 : 200,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: MediaQuery.of(context).size.width < 380
                    ? 45
                    : 60,
                sections: [
                  PieChartSectionData(
                    value: regularity.toDouble(),
                    color: ThemeColors.getPrimaryColor(context),
                    title: '$regularity%',
                    radius: MediaQuery.of(context).size.width < 380 ? 40 : 50,
                    titleStyle: TextStyle(
                      fontSize: MediaQuery.of(context).size.width < 380
                          ? 14
                          : 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    value: (100 - regularity).toDouble(),
                    color: ThemeColors.getBorderColor(context),
                    title: '',
                    radius: MediaQuery.of(context).size.width < 380 ? 40 : 50,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCycleLengthChart(List<PeriodModel> periods) {
    // Calculer les longueurs de cycle pour le graphique
    final sortedPeriods = List<PeriodModel>.from(periods);
    sortedPeriods.sort((a, b) => a.startDate.compareTo(b.startDate));

    final cycleLengths = <int>[];
    final cycleLabels = <String>[];

    for (int i = 0; i < sortedPeriods.length - 1; i++) {
      final currentStart = sortedPeriods[i].startDate;
      final nextStart = sortedPeriods[i + 1].startDate;
      final cycleLength = nextStart.difference(currentStart).inDays;
      if (cycleLength > 15 && cycleLength < 60) {
        cycleLengths.add(cycleLength);
        cycleLabels.add('C${i + 1}');
      }
    }

    if (cycleLengths.isEmpty) {
      return _buildInsufficientDataCard(
        'Longueur des cycles',
        'Enregistre au moins 2 cycles pour voir l\'évolution de ta durée de cycle.',
        IconlyBold.activity,
      );
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, const Color(0xFFFAFAFA)],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: ThemeColors.getPrimaryColor(context).withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ThemeColors.getPeriodColor(context),
                      ThemeColors.getPeriodColor(context).withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  IconlyBold.activity,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Longueur des cycles',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: MediaQuery.of(context).size.width < 380 ? 160 : 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: cycleLengths.isEmpty
                    ? 35
                    : (cycleLengths.reduce((a, b) => a > b ? a : b) + 5)
                          .toDouble(),
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt() - 1;
                        if (index >= 0 && index < cycleLabels.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              'C${index + 1}',
                              style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.width < 380
                                    ? 9
                                    : 11,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}j',
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width < 380
                                ? 9
                                : 11,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 5,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(color: Colors.grey[200]!, strokeWidth: 1);
                  },
                ),
                borderData: FlBorderData(show: false),
                barGroups: cycleLengths.asMap().entries.map((entry) {
                  return BarChartGroupData(
                    x: entry.key + 1,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value.toDouble(),
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            ThemeColors.getPeriodColor(context),
                            ThemeColors.getPeriodColor(
                              context,
                            ).withOpacity(0.8),
                          ],
                        ),
                        width: MediaQuery.of(context).size.width < 380
                            ? 14
                            : 20,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(8),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSymptomPieChart(Map<String, int> symptomCounts) {
    if (symptomCounts.isEmpty) return const SizedBox.shrink();

    final List<Color> sliceColors = [
      ThemeColors.getPeriodColor(context),
      ThemeColors.getFertilityColor(context),
      ThemeColors.getSecondaryActionColor(context),
      ThemeColors.getStatsColor(context),
      const Color(0xFF9C27B0),
      const Color(0xFFFF9800),
    ];

    final sortedEntries = symptomCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // On garde les 5 plus fréquents et on groupe le reste
    final top5 = sortedEntries.take(5).toList();
    final total = symptomCounts.values.reduce((a, b) => a + b);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: ThemeColors.getCardColor(context),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: ThemeColors.getBorderColor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Distribution des symptômes',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: top5.asMap().entries.map((entry) {
                  final index = entry.key;
                  final data = entry.value;
                  final percentage = (data.value / total * 100).toStringAsFixed(
                    1,
                  );
                  return PieChartSectionData(
                    value: data.value.toDouble(),
                    color: sliceColors[index % sliceColors.length],
                    title: '$percentage%',
                    radius: 60,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Légende
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: top5.asMap().entries.map((entry) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: sliceColors[entry.key % sliceColors.length],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    entry.value.key,
                    style: TextStyle(
                      fontSize: 12,
                      color: ThemeColors.getTextColor(context),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodPieChart(Map<String, int> moodCounts) {
    if (moodCounts.isEmpty) return const SizedBox.shrink();

    final List<Color> moodColors = [
      const Color(0xFFFFD54F), // Heureuse
      const Color(0xFF64B5F6), // Triste
      const Color(0xFFE57373), // Irritée
      const Color(0xFF81C784), // Calme
      const Color(0xFFBA68C8), // Stressée
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: ThemeColors.getCardColor(context),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: ThemeColors.getBorderColor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Répartition des humeurs',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sectionsSpace: 4,
                centerSpaceRadius: 0,
                sections: moodCounts.entries.toList().asMap().entries.map((
                  entry,
                ) {
                  final index = entry.key;
                  final data = entry.value;
                  return PieChartSectionData(
                    value: data.value.toDouble(),
                    color: moodColors[index % moodColors.length],
                    title: data.key,
                    radius: 80,
                    titleStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSymptomStats(Map<String, dynamic> stats) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, const Color(0xFFFAFAFA)],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: ThemeColors.getPrimaryColor(context).withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ThemeColors.getStatsColor(context),
                      ThemeColors.getStatsColor(context).withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  IconlyBold.activity,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Statistiques des symptômes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Entrées',
                  '${stats['totalEntries']}',
                  IconlyBold.document,
                  ThemeColors.getStatsColor(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Douleur moy.',
                  '${stats['averagePainLevel']}/10',
                  IconlyBold.danger,
                  ThemeColors.getErrorColor(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralStats(Map<String, dynamic> periodStats, UserModel user) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, const Color(0xFFFAFAFA)],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: ThemeColors.getPrimaryColor(context).withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Statistiques générales',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 20),
          _buildInfoRow(
            'Périodes enregistrées',
            '${periodStats['totalPeriods']}',
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            'Cycle moyen',
            periodStats['averageCycleLength'] > 0
                ? '${periodStats['averageCycleLength']} jours'
                : 'Non disponible',
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            'Règles moyennes',
            periodStats['averagePeriodLength'] > 0
                ? '${periodStats['averagePeriodLength']} jours'
                : 'Non disponible',
          ),
          if (user.nextPeriodDate != null) ...[
            const SizedBox(height: 12),
            _buildInfoRow(
              'Prochaines règles',
              DateFormat('dd MMMM yyyy', 'fr_FR').format(user.nextPeriodDate!),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSymptomFrequencyChart() {
    final now = DateTime.now();
    final List<Map<String, dynamic>> dailyData = [];

    // Récupérer les données des 7 derniers jours
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final symptom = SymptomService.getSymptomForDate(date);
      dailyData.add({
        'day': DateFormat('E', 'fr_FR').format(date), // Lun, Mar...
        'count': symptom?.symptoms.length ?? 0,
        'date': date,
      });
    }

    // Si aucune donnée, ne rien afficher ou une placeholder ?
    // On affiche quand même le graph vide pour montrer la structure

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: ThemeColors.getCardColor(context),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: ThemeColors.getBorderColor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade400, Colors.blue.shade600],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  IconlyBold.graph,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                'Fréquence des symptômes',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '7 derniers jours',
            style: TextStyle(
              fontSize: 14,
              color: ThemeColors.getSecondaryTextColor(context),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 10, // Max attendu arbitraire
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => ThemeColors.getCardColor(context),
                    tooltipPadding: const EdgeInsets.all(8),
                    tooltipMargin: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${rod.toY.toInt()} symptômes\n${DateFormat('dd MMM', 'fr_FR').format(dailyData[groupIndex]['date'])}',
                        TextStyle(
                          color: ThemeColors.getTextColor(context),
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < dailyData.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              dailyData[index]['day'],
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: ThemeColors.getSecondaryTextColor(
                                  context,
                                ),
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        if (value % 2 == 0) {
                          return Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              fontSize: 12,
                              color: ThemeColors.getSecondaryTextColor(context),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 2,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: ThemeColors.getBorderColor(context),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: dailyData.asMap().entries.map((entry) {
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: (entry.value['count'] as int).toDouble(),
                        color: ThemeColors.getPrimaryColor(context),
                        width: 16,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(6),
                        ),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: 10,
                          color: ThemeColors.getPrimaryColor(
                            context,
                          ).withOpacity(0.05),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoSymptomDataWidget() {
    return _buildInsufficientDataCard(
      'Symptômes & Humeur',
      'Enregistre tes symptômes quotidiens pour voir tes tendances de bien-être ici.',
      IconlyBold.heart,
    );
  }

  Widget _buildInsufficientDataCard(
    String title,
    String message,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: ThemeColors.getCardColor(context),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: ThemeColors.getBorderColor(context)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: ThemeColors.getPrimaryColor(context).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: ThemeColors.getPrimaryColor(context),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: ThemeColors.getSecondaryTextColor(context),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            color: ThemeColors.getSecondaryTextColor(context),
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            color: ThemeColors.getTextColor(context),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
