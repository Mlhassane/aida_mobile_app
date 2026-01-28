import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../providers/user_provider.dart';
import '../providers/periods_provider.dart';
import '../core/theme_colors.dart';
import 'package:aida/widgets/app_navbar.dart';
import 'profile_settings_tab.dart';
import 'statistics_page.dart';
import 'modules_page.dart';
import 'home_tab.dart';
import 'chat_list_page.dart';

class AidaTab extends StatefulWidget {
  const AidaTab({super.key});

  @override
  State<AidaTab> createState() => _AidaTabState();
}

class _AidaTabState extends State<AidaTab> {
  int _currentIndex = 0;

  Future<void> _markPeriodStart(BuildContext context) async {
    final now = DateTime.now();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirmer'),
        content: Text(
          'Marquer le début de vos règles pour aujourd\'hui (${DateFormat('dd MMMM yyyy', 'fr_FR').format(now)}) ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeColors.getPrimaryColor(context),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Confirmer',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final periodsProvider = context.read<PeriodsProvider>();
      await periodsProvider.recordPeriod(now);
      _showSuccessSnackBar(context, 'Période enregistrée avec succès');
    }
  }

  Future<void> _markPeriodEnd(BuildContext context) async {
    final now = DateTime.now();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Terminer les règles'),
        content: Text(
          'Marquer la fin de vos règles pour aujourd\'hui (${DateFormat('dd MMMM yyyy', 'fr_FR').format(now)}) ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4ECDC4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Confirmer',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final periodsProvider = context.read<PeriodsProvider>();
      await periodsProvider.endPeriod(now);
      _showSuccessSnackBar(context, 'Fin des règles enregistrée');
    }
  }

  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: ThemeColors.getPrimaryColor(context),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.user;

    if (user == null) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: ThemeColors.getPrimaryColor(context),
          ),
        ),
      );
    }

    // Calculs pour l'affichage
    final isOnPeriod = user.isCurrentlyOnPeriod;
    final daysUntil = user.daysUntilNextPeriod ?? 0;
    final currentCycleDay = _calculateCurrentCycleDay(user);
    final cycleLength = user.averageCycleLength;
    final progress = currentCycleDay / cycleLength;

    return Scaffold(
      backgroundColor: ThemeColors.getBackgroundColor(context),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeTab(
            user: user,
            isOnPeriod: isOnPeriod,
            daysUntil: daysUntil,
            currentCycleDay: currentCycleDay,
            cycleLength: cycleLength,
            progress: progress,
            onSwitchTab: (index) => setState(() => _currentIndex = index),
            onMarkPeriodStart: () => _markPeriodStart(context),
            onMarkPeriodEnd: () => _markPeriodEnd(context),
          ),
          const ModulesPage(),
          const ChatListPage(),
          const StatisticsPage(),
          ProfileSettingsTab(user: user, onUserUpdated: () => setState(() {})),
        ],
      ),
      bottomNavigationBar: AppNavBar(
        currentIndex: _currentIndex,
        onItemSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  int _calculateCurrentCycleDay(UserModel user) {
    if (user.lastPeriodDate == null) return 1;
    final difference = DateTime.now().difference(user.lastPeriodDate!).inDays;
    return (difference % user.averageCycleLength) + 1;
  }
}
