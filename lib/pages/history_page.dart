import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:intl/intl.dart';
import '../core/theme_colors.dart';
import '../services/period_service.dart';
import '../services/hive_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/period_model.dart';
import 'add_period_dialog.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: HiveService.periodsBox.listenable(),
      builder: (context, box, _) {
        final periods = PeriodService.getAllPeriods();
        final stats = PeriodService.getStatistics();
        final rawAvgLength = stats['averagePeriodLength'];
        final avgLength = rawAvgLength is num ? rawAvgLength.round() : 0;

        return Scaffold(
          backgroundColor: ThemeColors.getBackgroundColor(context),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                IconlyLight.arrow_left_2,
                color: ThemeColors.getTextColor(context),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Historique',
              style: TextStyle(
                color: ThemeColors.getTextColor(context),
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          floatingActionButton: periods.isNotEmpty
              ? FloatingActionButton.extended(
                  onPressed: _addPastCycle,
                  backgroundColor: ThemeColors.getPrimaryColor(context),
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    'Ajouter',
                    style: TextStyle(color: Colors.white),
                  ),
                )
              : null,
          body: periods.isEmpty
              ? _buildEmptyState()
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Stats Summary
                      _buildStatsCard(periods.length, avgLength),
                      const SizedBox(height: 24),

                      // History Title
                      Text(
                        'Cycles précédents',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: ThemeColors.getTextColor(context),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Period History List
                      ...periods.map((period) => _buildPeriodCard(period)),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: ThemeColors.getPrimaryColor(context).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                IconlyBold.document,
                size: 64,
                color: ThemeColors.getPrimaryColor(context),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Aucun historique',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: ThemeColors.getTextColor(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ajoute tes cycles passés pour obtenir des analyses précises.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: ThemeColors.getSecondaryTextColor(context),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _addPastCycle,
              icon: const Icon(Icons.add),
              label: const Text('Ajouter un cycle'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeColors.getPrimaryColor(context),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addPastCycle() async {
    final result = await showDialog(
      context: context,
      builder: (context) => const AddPeriodDialog(isPastPeriod: true),
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Cycle ajouté avec succès')));
    }
  }

  void _editCycle(PeriodModel period) async {
    final result = await showDialog(
      context: context,
      builder: (context) => AddPeriodDialog(periodToEdit: period),
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cycle modifié avec succès')),
      );
    }
  }

  void _deletePeriod(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer'),
        content: const Text('Voulez-vous vraiment supprimer ce cycle ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await PeriodService.deletePeriod(id);
    }
  }

  Widget _buildStatsCard(int periodCount, int avgLength) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ThemeColors.getPrimaryColor(context),
            ThemeColors.getPrimaryColor(context).withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: ThemeColors.getPrimaryColor(context).withOpacity(0.3),
            blurRadius: 20,
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  IconlyBold.chart,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Statistiques',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatItem('Cycles enregistrés', '${periodCount}'),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.3),
              ),
              Expanded(
                child: _buildStatItem(
                  'Durée moyenne',
                  avgLength > 0 ? '$avgLength jours' : 'N/A',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.8)),
        ),
      ],
    );
  }

  Widget _buildPeriodCard(PeriodModel period) {
    final startDate = period.startDate;
    final duration = period.duration;

    return InkWell(
      onTap: () => _editCycle(period),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: ThemeColors.getCardColor(context),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: ThemeColors.getBorderColor(context),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ThemeColors.getPeriodColor(context).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                IconlyBold.calendar,
                color: ThemeColors.getPeriodColor(context),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('dd MMMM yyyy', 'fr_FR').format(startDate),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: ThemeColors.getTextColor(context),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Durée: $duration jours',
                    style: TextStyle(
                      fontSize: 13,
                      color: ThemeColors.getSecondaryTextColor(context),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => _deletePeriod(period.id),
              icon: Icon(
                IconlyLight.delete,
                color: ThemeColors.getErrorColor(context).withOpacity(0.6),
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
