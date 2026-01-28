import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme_colors.dart';
import '../services/user_service.dart';
import '../models/user_model.dart';

class YogaFitnessPage extends StatefulWidget {
  const YogaFitnessPage({super.key});

  @override
  State<YogaFitnessPage> createState() => _YogaFitnessPageState();
}

class _YogaFitnessPageState extends State<YogaFitnessPage> {
  final List<Map<String, dynamic>> _routines = [
    {
      'title': 'Soulagement Crampes',
      'phase': 'Règles',
      'duration': '12 min',
      'level': 'Débutant',
      'icon': Icons.self_improvement,
      'color': const Color(0xFFFF4D6D),
      'description': 'Postures douces pour détendre le bassin.',
    },
    {
      'title': 'Power Flow',
      'phase': 'Folliculaire',
      'duration': '25 min',
      'level': 'Intermédiaire',
      'icon': Icons.bolt,
      'color': const Color(0xFF4CAF50),
      'description': 'Dynamisme et renforcement musculaire.',
    },
    {
      'title': 'Vinyasa Énergie',
      'phase': 'Ovulation',
      'duration': '30 min',
      'level': 'Avancé',
      'icon': Icons.wb_sunny,
      'color': const Color(0xFFFFB703),
      'description': 'Profitez de votre pic d\'énergie.',
    },
    {
      'title': 'Détente & Ancrage',
      'phase': 'Lutéale',
      'duration': '15 min',
      'level': 'Tout niveau',
      'icon': Icons.nights_stay,
      'color': const Color(0xFF9181F4),
      'description': 'Calmer l\'esprit et réduire le stress.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final user = UserService.getUser();
    final currentPhase = _getCurrentPhase(user);
    final phaseColor = _getPhaseColor(currentPhase);

    return Scaffold(
      backgroundColor: ThemeColors.getBackgroundColor(context),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(currentPhase, phaseColor),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDailyRecommendation(currentPhase, phaseColor),
                  const SizedBox(height: 32),
                  const Text(
                    'Parcourir par phase',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ..._routines.map((routine) => _buildRoutineCard(routine)),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(String phase, Color color) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: color,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(IconlyLight.arrow_left_2, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color, color.withOpacity(0.8)],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -50,
                bottom: -20,
                child: Icon(
                  Icons.self_improvement,
                  size: 200,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Phase $phase',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Yoga & Fitness',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDailyRecommendation(String phase, Color color) {
    final recommendation = _routines.firstWhere(
      (r) => r['phase'] == phase,
      orElse: () => _routines[0],
    );

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(IconlyBold.star, color: Colors.amber, size: 20),
              const SizedBox(width: 8),
              Text(
                'Recommandation du jour',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(recommendation['icon'], color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recommendation['title'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${recommendation['duration']} • ${recommendation['level']}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              elevation: 0,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text('Commencer la séance'),
          ),
        ],
      ),
    );
  }

  Widget _buildRoutineCard(Map<String, dynamic> routine) {
    final color = routine['color'] as Color;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(routine['icon'], color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  routine['title'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  routine['description'],
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.grey[400]),
        ],
      ),
    );
  }

  String _getCurrentPhase(UserModel? user) {
    if (user == null || user.lastPeriodDate == null) return 'Inconnue';
    final now = DateTime.now();
    final difference = now.difference(user.lastPeriodDate!).inDays;
    final dayInCycle = (difference % user.averageCycleLength) + 1;

    if (dayInCycle <= user.averagePeriodLength) return 'Règles';
    if (dayInCycle <= 12) return 'Folliculaire';
    if (dayInCycle <= 16) return 'Ovulation';
    return 'Lutéale';
  }

  Color _getPhaseColor(String phase) {
    switch (phase) {
      case 'Règles':
        return const Color(0xFFFF4D6D);
      case 'Folliculaire':
        return const Color(0xFF4CAF50);
      case 'Ovulation':
        return const Color(0xFFFFB703);
      case 'Lutéale':
        return const Color(0xFF9181F4);
      default:
        return const Color(0xFFFF7043);
    }
  }
}
