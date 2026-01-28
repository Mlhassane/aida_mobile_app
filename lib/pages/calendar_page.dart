import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:iconly/iconly.dart';
import '../services/period_service.dart';
import '../services/user_service.dart';
import '../models/period_model.dart';
import '../models/user_model.dart';
import '../core/theme_colors.dart';
import 'add_period_dialog.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;

  // Calculer la phase pour une date donnée
  String _getPhaseForDate(DateTime date, UserModel user) {
    if (user.lastPeriodDate == null) return 'Inconnue';

    // Normaliser la date (sans l'heure)
    final checkDate = DateTime(date.year, date.month, date.day);
    final lastStart = DateTime(
      user.lastPeriodDate!.year,
      user.lastPeriodDate!.month,
      user.lastPeriodDate!.day,
    );

    // Calculer le jour dans le cycle (cycle circulaire)
    final diffDays = checkDate.difference(lastStart).inDays;
    final dayInCycle = (diffDays % user.averageCycleLength) + 1;

    if (dayInCycle <= user.averagePeriodLength) return 'Règles';
    if (dayInCycle <= 12) return 'Folliculaire';
    if (dayInCycle <= 16) return 'Ovulation';
    return 'Lutéale';
  }

  // Obtenir le style de la phase
  Color _getPhaseColor(String phase, BuildContext context) {
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
        return Colors.grey;
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
        return '❓';
    }
  }

  String _getPhaseInsight(String phase) {
    switch (phase) {
      case 'Règles':
        return 'Repose-toi, ton corps se régénère. Un thé chaud et du cocooning te feront du bien. ☕';
      case 'Folliculaire':
        return 'Ton énergie remonte ! C\'est le moment idéal pour lancer de nouveaux projets. 🚀';
      case 'Ovulation':
        return 'Tu es au sommet de ta forme et de ta radiance. Profites-en au maximum ! 🌟';
      case 'Lutéale':
        return 'Ton corps ralentit. Prends soin de toi et écoute tes émotions. Douceur avant tout. 🍵';
      default:
        return 'Bientôt de nouvelles prédictions disponibles !';
    }
  }

  // Obtenir l'intervalle des prochaines règles
  bool _isInPredictionWindow(DateTime date, UserModel user) {
    if (user.lastPeriodDate == null) return false;

    final lastStart = user.lastPeriodDate!;
    final checkDate = DateTime(date.year, date.month, date.day);

    final minNext = lastStart.add(Duration(days: user.minCycleLength));
    final maxNext = lastStart.add(
      Duration(days: user.maxCycleLength + user.averagePeriodLength),
    );

    return checkDate.isAfter(minNext.subtract(const Duration(days: 1))) &&
        checkDate.isBefore(maxNext.add(const Duration(days: 1)));
  }

  @override
  Widget build(BuildContext context) {
    final user = UserService.getUser();
    if (user == null) {
      return Container(
        color: ThemeColors.getBackgroundColor(context),
        child: Center(
          child: CircularProgressIndicator(
            color: ThemeColors.getPrimaryColor(context),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: ThemeColors.getBackgroundColor(context),
      body: Container(
        decoration: BoxDecoration(
          color: ThemeColors.getBackgroundColor(context),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(
                          IconlyBold.arrow_left,
                          color: ThemeColors.getPrimaryColor(context),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Calendrier',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: ThemeColors.getTextColor(context),
                                letterSpacing: -0.5,
                              ),
                            ),
                            Text(
                              'Suivi de tes cycles',
                              style: TextStyle(
                                fontSize: 14,
                                color: ThemeColors.getSecondaryTextColor(
                                  context,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: ThemeColors.getCardColor(context),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: ThemeColors.getBorderColor(context),
                            width: 1,
                          ),
                        ),
                        child: IconButton(
                          icon: Icon(
                            IconlyLight.filter,
                            color: ThemeColors.getPrimaryColor(context),
                            size: 20,
                          ),
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const SizedBox(height: 8),

                    // Statistiques en haut
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildPremiumStatCard(
                              'Cycle actuel',
                              '${_calculateCurrentCycleDay(user)} / ${user.averageCycleLength}',
                              IconlyBold.activity,
                              ThemeColors.getPrimaryColor(context),
                              ThemeColors.getPrimaryColor(
                                context,
                              ).withOpacity(0.8),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildPremiumStatCard(
                              'Prochain cycle',
                              '${user.daysUntilNextPeriod ?? 0}j',
                              IconlyBold.calendar,
                              ThemeColors.getPeriodColor(context),
                              ThemeColors.getPeriodColor(
                                context,
                              ).withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Calendrier
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: ThemeColors.getCardColor(context),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: ThemeColors.getBorderColor(context),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: ThemeColors.getPrimaryColor(
                              context,
                            ).withOpacity(0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TableCalendar<PeriodModel>(
                        firstDay: DateTime.utc(2020, 1, 1),
                        lastDay: DateTime.utc(2030, 12, 31),
                        focusedDay: _focusedDay,
                        selectedDayPredicate: (day) =>
                            isSameDay(_selectedDay, day),
                        calendarFormat: _calendarFormat,
                        startingDayOfWeek: StartingDayOfWeek.monday,
                        locale: 'fr_FR',
                        headerStyle: HeaderStyle(
                          formatButtonVisible: true,
                          titleCentered: true,
                          formatButtonShowsNext: false,
                          titleTextStyle: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: ThemeColors.getTextColor(context),
                          ),
                          formatButtonDecoration: BoxDecoration(
                            color: ThemeColors.getPrimaryColor(
                              context,
                            ).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          formatButtonTextStyle: TextStyle(
                            color: ThemeColors.getPrimaryColor(context),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        calendarStyle: CalendarStyle(
                          todayDecoration: BoxDecoration(
                            color: Colors.transparent,
                            border: Border.all(
                              color: ThemeColors.getPrimaryColor(context),
                              width: 2,
                            ),
                            shape: BoxShape.circle,
                          ),
                          todayTextStyle: TextStyle(
                            color: ThemeColors.getPrimaryColor(context),
                            fontWeight: FontWeight.bold,
                          ),
                          selectedDecoration: BoxDecoration(
                            color: ThemeColors.getPrimaryColor(context),
                            shape: BoxShape.circle,
                          ),
                          selectedTextStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          markerDecoration: BoxDecoration(
                            color: ThemeColors.getPeriodColor(context),
                            shape: BoxShape.circle,
                          ),
                        ),
                        eventLoader: (day) {
                          return PeriodService.getPeriodsInRange(
                            DateTime(day.year, day.month, day.day),
                            DateTime(day.year, day.month, day.day + 1),
                          );
                        },
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay;
                          });
                        },
                        onFormatChanged: (format) {
                          setState(() {
                            _calendarFormat = format;
                          });
                        },
                        onPageChanged: (focusedDay) {
                          setState(() {
                            _focusedDay = focusedDay;
                          });
                        },
                        calendarBuilders: CalendarBuilders(
                          defaultBuilder: (context, day, focusedDay) {
                            final phase = _getPhaseForDate(day, user);
                            final isPrediction = _isInPredictionWindow(
                              day,
                              user,
                            );
                            final isPeriod = PeriodService.isDateInPeriod(day);
                            final phaseColor = _getPhaseColor(phase, context);

                            if (isPeriod) {
                              return _buildSpecialDay(
                                day,
                                const Color(0xFFFF4D6D),
                                '🩸',
                              );
                            }

                            if (isPrediction) {
                              return _buildSpecialDay(
                                day,
                                const Color(0xFFFF4D6D).withOpacity(0.3),
                                '⏳',
                              );
                            }

                            // Indicateur de phase discret
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${day.day}',
                                    style: TextStyle(
                                      color: ThemeColors.getTextColor(context),
                                      fontWeight: day.weekday > 5
                                          ? FontWeight.w400
                                          : FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Container(
                                    width: 4,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: phaseColor.withOpacity(0.6),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          // Personnalisation du jour actuel
                          todayBuilder: (context, day, focusedDay) {
                            return _buildSpecialDay(
                              day,
                              ThemeColors.getPrimaryColor(context),
                              '📍',
                              isToday: true,
                            );
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Info sélection
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: ThemeColors.getCardColor(context),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: ThemeColors.getBorderColor(context),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat(
                              'dd MMMM yyyy',
                              'fr_FR',
                            ).format(_selectedDay),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: ThemeColors.getTextColor(context),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Builder(
                            builder: (context) {
                              final isPeriod = PeriodService.isDateInPeriod(
                                _selectedDay,
                              );
                              final phase = _getPhaseForDate(
                                _selectedDay,
                                user,
                              );
                              final phaseColor = _getPhaseColor(phase, context);

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Phase Card Premium
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          phaseColor.withOpacity(0.2),
                                          phaseColor.withOpacity(0.05),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: phaseColor.withOpacity(0.2),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              _getPhaseEmoji(phase),
                                              style: const TextStyle(
                                                fontSize: 24,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              'Phase $phase',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w800,
                                                color: phaseColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          _getPhaseInsight(phase),
                                          style: TextStyle(
                                            fontSize: 14,
                                            height: 1.5,
                                            color: ThemeColors.getTextColor(
                                              context,
                                            ).withOpacity(0.8),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  // Action Button
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: () async {
                                        if (isPeriod) {
                                          final period =
                                              PeriodService.getPeriodAtDate(
                                                _selectedDay,
                                              );
                                          if (period != null) {
                                            final confirmed = await showDialog<bool>(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: const Text('Supprimer'),
                                                content: const Text(
                                                  'Voulez-vous supprimer ces règles ?',
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                          context,
                                                          false,
                                                        ),
                                                    child: const Text(
                                                      'Annuler',
                                                    ),
                                                  ),
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                          context,
                                                          true,
                                                        ),
                                                    child: const Text(
                                                      'Supprimer',
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                            if (confirmed == true) {
                                              await PeriodService.deletePeriod(
                                                period.id,
                                              );
                                              setState(() {});
                                            }
                                          }
                                        } else {
                                          final result = await showDialog<bool>(
                                            context: context,
                                            builder: (context) =>
                                                AddPeriodDialog(
                                                  isPastPeriod: _selectedDay
                                                      .isBefore(DateTime.now()),
                                                ),
                                          );
                                          if (result == true) {
                                            setState(() {});
                                          }
                                        }
                                      },
                                      icon: Icon(
                                        isPeriod
                                            ? IconlyLight.delete
                                            : IconlyLight.plus,
                                      ),
                                      label: Text(
                                        isPeriod
                                            ? 'Retirer les règles'
                                            : 'Marquer début règles',
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isPeriod
                                            ? const Color(0xFFFF4D6D)
                                            : phaseColor,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Légende
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: ThemeColors.getCardColor(context),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: ThemeColors.getBorderColor(context),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Légende',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: ThemeColors.getTextColor(context),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildLegendItem('🩸', 'Règles confirmées'),
                          _buildLegendItem('⏳', 'Fenêtre de prédiction'),
                          _buildLegendItem('🌿', 'Phase Folliculaire'),
                          _buildLegendItem('✨', 'Ovulation'),
                          _buildLegendItem('🌙', 'Phase Lutéale'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumStatCard(
    String label,
    String value,
    IconData icon,
    Color color1,
    Color color2,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeColors.getCardColor(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: ThemeColors.getBorderColor(context),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color1, size: 20),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: ThemeColors.getSecondaryTextColor(context),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: color1,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String emoji, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: ThemeColors.getTextColor(context),
            ),
          ),
        ],
      ),
    );
  }

  int _calculateCurrentCycleDay(UserModel user) {
    if (user.lastPeriodDate == null) return 1;
    final difference = DateTime.now().difference(user.lastPeriodDate!).inDays;
    return (difference % user.averageCycleLength) + 1;
  }

  Widget _buildSpecialDay(
    DateTime day,
    Color color,
    String emoji, {
    bool isToday = false,
  }) {
    final isConfirmed = emoji == '🩸';
    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isConfirmed ? color.withOpacity(0.9) : color.withOpacity(0.15),
        border: isToday
            ? Border.all(color: color, width: 2)
            : (isConfirmed ? Border.all(color: Colors.white, width: 1) : null),
        borderRadius: BorderRadius.circular(12),
        boxShadow: isConfirmed
            ? [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${day.day}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isConfirmed
                    ? Colors.white
                    : ThemeColors.getTextColor(context),
              ),
            ),
            if (isConfirmed)
              const SizedBox(height: 1)
            else
              Text(emoji, style: const TextStyle(fontSize: 10)),
          ],
        ),
      ),
    );
  }
}
