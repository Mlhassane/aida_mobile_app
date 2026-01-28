import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../core/theme_colors.dart';

class ModulesPage extends StatelessWidget {
  const ModulesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.getBackgroundColor(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Modules',
          style: TextStyle(
            color: ThemeColors.getTextColor(context),
            fontSize: 26,
            fontWeight: FontWeight.w900,
            letterSpacing: -1,
          ),
        ),
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(20),
        crossAxisCount: MediaQuery.of(context).size.width < 380 ? 2 : 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: MediaQuery.of(context).size.width < 380 ? 0.75 : 0.85,
        children: [
          _buildModuleCard(
            context,
            title: 'Éducation',
            subtitle: 'Guides & Articles',
            icon: IconlyLight.document,
            color: ThemeColors.getPrimaryColor(context),
            onTap: () => Navigator.pushNamed(context, '/education'),
          ),
          _buildModuleCard(
            context,
            title: 'Yoga & Fitness',
            subtitle: 'Séances cycliques',
            icon: Icons.self_improvement,
            color: const Color(0xFF4CAF50),
            onTap: () => Navigator.pushNamed(context, '/yoga-fitness'),
          ),
        ],
      ),
    );
  }

  Widget _buildModuleCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isSmallScreen = MediaQuery.of(context).size.width < 380;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          color: ThemeColors.getCardColor(context),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: ThemeColors.getBorderColor(context),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: isSmallScreen ? 24 : 32, color: color),
            ),
            SizedBox(height: isSmallScreen ? 10 : 16),
            Text(
              title,
              style: TextStyle(
                fontSize: isSmallScreen ? 15 : 18,
                fontWeight: FontWeight.bold,
                color: ThemeColors.getTextColor(context),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isSmallScreen ? 10 : 12,
                color: ThemeColors.getSecondaryTextColor(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showWaterTracker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => const WaterTrackerSheet(),
    );
  }
}

class WaterTrackerSheet extends StatefulWidget {
  const WaterTrackerSheet({super.key});

  @override
  State<WaterTrackerSheet> createState() => _WaterTrackerSheetState();
}

class _WaterTrackerSheetState extends State<WaterTrackerSheet> {
  // Simuler une mini base de données locale pour la démo
  int _glasses = 0;
  final int _goal = 8;

  @override
  Widget build(BuildContext context) {
    final progress = _glasses / _goal;

    return Container(
      decoration: BoxDecoration(
        color: ThemeColors.getBackgroundColor(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Hydratation du jour',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: ThemeColors.getTextColor(context),
            ),
          ),
          const SizedBox(height: 32),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 150,
                height: 150,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 12,
                  backgroundColor: Colors.blue.withOpacity(0.1),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Colors.blueAccent,
                  ),
                  strokeCap: StrokeCap.round,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.water_drop, size: 40, color: Colors.blueAccent),
                  Text(
                    '$_glasses / $_goal',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildActionButton(
                icon: Icons.remove,
                onTap: () {
                  if (_glasses > 0) setState(() => _glasses--);
                },
              ),
              const SizedBox(width: 32),
              _buildActionButton(
                icon: Icons.add,
                isPrimary: true,
                onTap: () {
                  if (_glasses < _goal) setState(() => _glasses++);
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isPrimary ? Colors.blueAccent : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: Colors.blueAccent.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Icon(
          icon,
          size: 32,
          color: isPrimary ? Colors.white : Colors.black54,
        ),
      ),
    );
  }
}
