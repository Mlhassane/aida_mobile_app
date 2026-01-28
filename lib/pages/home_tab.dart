import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconly/iconly.dart';
import 'dart:math' as math;
import 'dart:ui';
import '../services/notification_service.dart';
import '../models/user_model.dart';
import '../core/theme_colors.dart';
import '../widgets/avatar_widget.dart';

class HomeTab extends StatefulWidget {
  final UserModel user;
  final bool isOnPeriod;
  final int daysUntil;
  final int currentCycleDay;
  final int cycleLength;
  final double progress;
  final Function(int) onSwitchTab;
  final VoidCallback onMarkPeriodStart;
  final VoidCallback onMarkPeriodEnd;

  const HomeTab({
    super.key,
    required this.user,
    required this.isOnPeriod,
    required this.daysUntil,
    required this.currentCycleDay,
    required this.cycleLength,
    required this.progress,
    required this.onSwitchTab,
    required this.onMarkPeriodStart,
    required this.onMarkPeriodEnd,
  });

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Helper pour les phases (identique au calendrier pour la cohérence)
  String _getPhase() {
    if (widget.isOnPeriod) return 'Règles';
    if (widget.currentCycleDay <= 12) return 'Folliculaire';
    if (widget.currentCycleDay <= 16) return 'Ovulation';
    return 'Lutéale';
  }

  Color _getPhaseColor(String phase) {
    switch (phase) {
      case 'Règles':
        return const Color(0xFFFF4D6D);
      case 'Folliculaire':
        return const Color(0xFF9181F4);
      case 'Ovulation':
        return const Color(0xFFFFD166);
      case 'Lutéale':
        return const Color(0xFF4ECDC4);
      default:
        return ThemeColors.getPrimaryColor(context);
    }
  }

  String _getPhaseEmoji(String phase) {
    switch (phase) {
      case 'Règles':
        return '🩸';
      case 'Folliculaire':
        return '🌿';
      case 'Ovulation':
        return '✨';
      case 'Lutéale':
        return '🌙';
      default:
        return '🌸';
    }
  }

  String _getAidaInsight(String phase) {
    switch (phase) {
      case 'Règles':
        return 'C\'est le moment de ralentir. Ton corps a besoin de douceur et de chaleur.';
      case 'Folliculaire':
        return 'Ton énergie explose ! Profites-en pour être créative et bouger.';
      case 'Ovulation':
        return 'Tu es au pic de ta forme. C\'est ta période la plus rayonnante.';
      case 'Lutéale':
        return 'Prends soin de ton sommeil. Ton corps prépare son prochain cycle.';
      default:
        return 'Ravie de te revoir pour suivre ton évolution.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final phase = _getPhase();
    final phaseColor = _getPhaseColor(phase);
    final phaseEmoji = _getPhaseEmoji(phase);

    return Stack(
      children: [
        // Arrière-plan dynamique avec sphères floues
        Positioned.fill(
          child: AnimatedContainer(
            duration: 800.ms,
            color: ThemeColors.getBackgroundColor(context),
            child: Stack(
              children: [
                // Sphère 1 (Haut Gauche)
                Positioned(
                  top: -100,
                  left: -50,
                  child: AnimatedContainer(
                    duration: 1200.ms,
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      color: phaseColor.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                // Sphère 2 (Milieu Droite)
                Positioned(
                  top: 200,
                  right: -100,
                  child: AnimatedContainer(
                    duration: 1500.ms,
                    width: 400,
                    height: 400,
                    decoration: BoxDecoration(
                      color: ThemeColors.getPrimaryColor(
                        context,
                      ).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                // Effet de flou gaussien sur tout l'arrière-plan
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
                    child: Container(color: Colors.transparent),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Contenu principal
        SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context)
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: -0.2, end: 0),
                const SizedBox(height: 24),

                // Card Insight AIDA
                _buildAidaInsightCard(
                  phase,
                  phaseColor,
                  phaseEmoji,
                ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.1, end: 0),

                const SizedBox(height: 32),

                _buildModernCycleTracker(context, phase, phaseColor)
                    .animate()
                    .fadeIn(delay: 200.ms)
                    .scale(begin: const Offset(0.9, 0.9), duration: 800.ms, curve: Curves.easeOutBack),

                const SizedBox(height: 48),

                _buildModernActions(context)
                    .animate()
                    .fadeIn(delay: 600.ms)
                    .slideY(begin: 0.1, end: 0),

                const SizedBox(height: 32),

                if (!widget.isOnPeriod)
                  _buildPeriodStartButton(context, phaseColor)
                      .animate()
                      .scale(
                        begin: const Offset(0.95, 0.95),
                        duration: 600.ms,
                        delay: 1000.ms,
                      )
                      .fadeIn()
                else
                  _buildPeriodEndButton(context, const Color(0xFF4ECDC4))
                      .animate()
                      .scale(
                        begin: const Offset(0.95, 0.95),
                        duration: 600.ms,
                        delay: 1000.ms,
                      )
                      .fadeIn(),

                const SizedBox(height: 40),
                
                _buildQuickActions(context)
                    .animate()
                    .fadeIn(delay: 800.ms)
                    .slideY(begin: 0.1, end: 0),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),

        Positioned(
          bottom: 28,
          right: 20,
          child: GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/ai-coach'),
            child:
                Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [phaseColor, phaseColor.withOpacity(0.8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: phaseColor.withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        color: Colors.white,
                        size: 30,
                      ),
                    )
                    .animate(
                      onPlay: (controller) => controller.repeat(reverse: true),
                    )
                    .shimmer(
                      delay: 2000.ms,
                      duration: 1500.ms,
                      color: Colors.white.withOpacity(0.3),
                    )
                    .moveY(
                      begin: 0,
                      end: -8,
                      duration: 2000.ms,
                      curve: Curves.easeInOut,
                    )
                    .animate() // Deuxième chaîne pour l'entrée
                    .scale(
                      begin: const Offset(0.2, 0.2),
                      end: const Offset(1, 1),
                      duration: 800.ms,
                      curve: Curves.elasticOut,
                    )
                    .slideY(
                      begin: 1.5,
                      end: 0,
                      duration: 800.ms,
                      curve: Curves.easeOutBack,
                    )
                    .fadeIn(duration: 400.ms),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 380;

    return Row(
      children: [
        GestureDetector(
          onTap: () => widget.onSwitchTab(3),
          child:
              AvatarWidget(
                avatarAsset: widget.user.avatarAsset,
                profileImagePath: widget.user.profileImagePath,
                size: isSmallScreen ? 45 : 60,
              ).animate().scale(
                delay: 300.ms,
                duration: 600.ms,
                curve: Curves.elasticOut,
              ),
        ),
        SizedBox(width: isSmallScreen ? 12 : 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quoi de neuf,',
                style: TextStyle(
                  fontSize: isSmallScreen ? 15 : 18,
                  color: ThemeColors.getSecondaryTextColor(context),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                widget.user.name,
                style: TextStyle(
                  fontSize: isSmallScreen ? 19 : 22,
                  fontWeight: FontWeight.w900,
                  color: ThemeColors.getTextColor(context),
                  height: 0.9,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/notifications');
          },
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
                decoration: BoxDecoration(
                  color: ThemeColors.getPrimaryColor(context).withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  IconlyBold.notification,
                  color: ThemeColors.getPrimaryColor(context),
                  size: isSmallScreen ? 24 : 28,
                ),
              ),
              ValueListenableBuilder<int>(
                valueListenable: NotificationService.unreadCount,
                builder: (context, count, _) {
                  if (count == 0) return const SizedBox.shrink();
                  return Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF4D6D),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 20,
                        minHeight: 20,
                      ),
                      child: Center(
                        child: Text(
                          count > 99 ? '99+' : count.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ).animate(onPlay: (c) => c.repeat(reverse: true))
                     .scale(duration: 1000.ms, begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1)),
                  );
                },
              ),
            ],
          ).animate().fadeIn(delay: 400.ms).scale(curve: Curves.elasticOut),
        ),
      ],
    );
  }

  Widget _buildAidaInsightCard(String phase, Color color, String emoji) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ThemeColors.getCardColor(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Text(emoji, style: const TextStyle(fontSize: 24)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Conseil d\'Aida',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getAidaInsight(phase),
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                    color: ThemeColors.getTextColor(context).withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernCycleTracker(
    BuildContext context,
    String phase,
    Color phaseColor,
  ) {
    final size = MediaQuery.of(context).size;
    final trackerSize = size.width * 0.75;
    
    // Ordinal suffix helper
    String getOrdinal(int day) {
      if (day == 1) return 'st';
      if (day == 2) return 'nd';
      if (day == 3) return 'rd';
      return 'th';
    }

    return Center(
      child: SizedBox(
        width: trackerSize,
        height: trackerSize,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Circular Progress with Segments and Dots
            CustomPaint(
              size: Size(trackerSize, trackerSize),
              painter: ModernCyclePainter(
                progress: widget.progress,
                cycleLength: widget.cycleLength,
                isPeriod: widget.isOnPeriod,
                isDark: Theme.of(context).brightness == Brightness.dark,
              ),
            ),
            
            // Central Content
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.isOnPeriod) ...[
                  Icon(Icons.water_drop, color: const Color(0xFFFF4D6D), size: 28),
                  const SizedBox(height: 4),
                  Text(
                    'Period',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: ThemeColors.getSecondaryTextColor(context),
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 32),
                ],
                const SizedBox(height: 12),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '${widget.currentCycleDay}',
                      style: TextStyle(
                        fontSize: 62,
                        fontWeight: FontWeight.w800,
                        color: ThemeColors.getTextColor(context),
                        letterSpacing: -2,
                      ),
                    ),
                    Text(
                      getOrdinal(widget.currentCycleDay),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: ThemeColors.getTextColor(context),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Days',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w400,
                        color: ThemeColors.getSecondaryTextColor(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.white.withOpacity(0.05) 
                        : Colors.black.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Theme.of(context).brightness == Brightness.dark 
                          ? Colors.white.withOpacity(0.1) 
                          : Colors.black.withOpacity(0.05),
                    ),
                  ),
                  child: Text(
                    '${widget.daysUntil} days left',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: ThemeColors.getSecondaryTextColor(context),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildCircularActionButton(
          context,
          icon: Icons.water_drop,
          label: 'Edit Cycle',
          color: const Color(0xFFFF4D6D),
          onTap: () => widget.onMarkPeriodStart(),
        ),
        _buildCircularActionButton(
          context,
          icon: Icons.add,
          label: 'Add Symptoms',
          color: Colors.white,
          iconColor: Colors.black,
          onTap: () => Navigator.pushNamed(context, '/symptoms'),
        ),
      ],
    );
  }

  Widget _buildCircularActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    Color? iconColor,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.35),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
              border: Border.all(
                color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
                width: 1,
              ),
            ),
            child: Icon(icon, color: iconColor ?? Colors.white, size: 30),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: ThemeColors.getTextColor(context),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mon Suivi',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: ThemeColors.getTextColor(context),
          ),
        ),
        const SizedBox(height: 20),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _buildModuleCard(
              context,
              IconlyBold.calendar,
              'Calendrier',
              'Vue mensuelle',
              ThemeColors.getPrimaryColor(context),
              () => Navigator.pushNamed(context, '/calendar'),
            ),
            _buildModuleCard(
              context,
              IconlyBold.activity,
              'Symptômes',
              'Suivi quotidien',
              ThemeColors.getFertilityColor(context),
              () => Navigator.pushNamed(context, '/symptoms'),
            ),
            _buildModuleCard(
              context,
              IconlyBold.document,
              'Historique',
              'Tes cycles',
              ThemeColors.getStatsColor(context),
              () => Navigator.pushNamed(context, '/history'),
            ),
            _buildModuleCard(
              context,
              IconlyBold.edit,
              'Journal',
              'Notes & Humeur',
              ThemeColors.getSecondaryActionColor(context),
              () => Navigator.pushNamed(context, '/journal'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildModuleCard(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: ThemeColors.getCardColor(context),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: ThemeColors.getBorderColor(context)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: ThemeColors.getPrimaryColor(context),
                size: 28,
              ),
            ),
            const Spacer(),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: ThemeColors.getTextColor(context),
              ),
            ),
            const Spacer(),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: ThemeColors.getSecondaryTextColor(context),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodStartButton(BuildContext context, Color color) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onMarkPeriodStart,
        borderRadius: BorderRadius.circular(32),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                ThemeColors.getPrimaryColor(context),
                ThemeColors.getPrimaryColor(context).withOpacity(0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  IconlyBold.heart,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                'Mes règles ont commencé',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodEndButton(BuildContext context, Color color) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onMarkPeriodEnd,
        borderRadius: BorderRadius.circular(32),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                ThemeColors.getPrimaryColor(context),
                ThemeColors.getPrimaryColor(context).withOpacity(0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: ThemeColors.getPrimaryColor(context).withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  IconlyBold.tick_square,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                'Mes règles sont finies',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ModernCyclePainter extends CustomPainter {
    final double progress;
    final int cycleLength;
    final bool isPeriod;
    final bool isDark;

    ModernCyclePainter({
      required this.progress,
      required this.cycleLength,
      required this.isPeriod,
      required this.isDark,
    });

    @override
    void paint(Canvas canvas, Size size) {
      final center = Offset(size.width / 2, size.height / 2);
      final radius = size.width / 2;
      final strokeWidth = 20.0;
      final innerRadius = radius - strokeWidth - 10;

      // Draw day dots
      final dotPaint = Paint()
        ..color = isDark ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.2)
        ..style = PaintingStyle.fill;

      for (int i = 0; i < cycleLength; i++) {
        final angle = (2 * math.pi * i / cycleLength) - math.pi / 2;
        final x = center.dx + innerRadius * math.cos(angle);
        final y = center.dy + innerRadius * math.sin(angle);
        canvas.drawCircle(Offset(x, y), 2.5, dotPaint);
      }

      // Draw current progress dot highlight
      final currentAngle = (2 * math.pi * progress) - math.pi / 2;
      final highlightX = center.dx + innerRadius * math.cos(currentAngle);
      final highlightY = center.dy + innerRadius * math.sin(currentAngle);
      final highlightPaint = Paint()
        ..color = const Color(0xFFFF4D6D)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(highlightX, highlightY), 4, highlightPaint);

      final rect = Rect.fromCircle(center: center, radius: radius - strokeWidth / 2);
      final arcPaint = Paint()
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      // 1. Background Arc (Grey)
      arcPaint.color = isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.04);
      canvas.drawArc(rect, 0, 2 * math.pi, false, arcPaint);

      // 2. Period Arc (Pink)
      // Representing average period (e.g., 5 days)
      final periodProgress = 5 / cycleLength;
      arcPaint.color = const Color(0xFFFF4D6D);
      canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * periodProgress, false, arcPaint);

      // Add a small circle at the end of period arc
      final periodEndAngle = (2 * math.pi * periodProgress) - math.pi / 2;
      _drawCapCircle(canvas, center, radius - strokeWidth / 2, periodEndAngle, const Color(0xFFFF4D6D));

      // 3. Ovulation Arc (Blue/Green)
      // Usually around day 12-16
      final ovulationStart = 12 / cycleLength;
      final ovulationDuration = 4 / cycleLength;
      arcPaint.color = const Color(0xFF6B99FB);
      canvas.drawArc(rect, (2 * math.pi * ovulationStart) - math.pi / 2, 2 * math.pi * ovulationDuration, false, arcPaint);

      // Add a small circle at the start and end of ovulation arc
      _drawCapCircle(canvas, center, radius - strokeWidth / 2, (2 * math.pi * ovulationStart) - math.pi / 2, const Color(0xFF6B99FB));
      _drawCapCircle(canvas, center, radius - strokeWidth / 2, (2 * math.pi * (ovulationStart + ovulationDuration)) - math.pi / 2, const Color(0xFF6B99FB));

      // 4. Current Progress Pointer (Arrow / Marker)
      final markerPaint = Paint()
        ..color = isDark ? Colors.white.withOpacity(0.3) : Colors.black.withOpacity(0.2)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      
      final markerAngle = (2 * math.pi * progress) - math.pi / 2;
      final markerX = center.dx + (radius + 15) * math.cos(markerAngle);
      final markerY = center.dy + (radius + 15) * math.sin(markerAngle);
      
      // Draw arrow marker
      final path = Path();
      path.moveTo(markerX, markerY);
      path.lineTo(markerX + 10 * math.cos(markerAngle + 2.5), markerY + 10 * math.sin(markerAngle + 2.5));
      path.moveTo(markerX, markerY);
      path.lineTo(markerX + 10 * math.cos(markerAngle - 2.5), markerY + 10 * math.sin(markerAngle - 2.5));
      canvas.drawPath(path, markerPaint);
    }

    void _drawCapCircle(Canvas canvas, Offset center, double radius, double angle, Color color) {
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      
      // Inner white dot
      canvas.drawCircle(Offset(x, y), 5, Paint()..color = Colors.white);
      // Outer border
      canvas.drawCircle(Offset(x, y), 5, Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 2);
    }

    @override
    bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
  }
