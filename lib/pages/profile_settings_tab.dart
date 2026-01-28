import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/user_model.dart';
import '../services/theme_service.dart';
import '../services/period_service.dart';
import '../core/theme_colors.dart';
import '../widgets/avatar_widget.dart';
import '../providers/user_provider.dart';
import '../services/ai_motivation_service.dart';

class ProfileSettingsTab extends StatefulWidget {
  final UserModel user;
  final VoidCallback onUserUpdated;

  const ProfileSettingsTab({
    super.key,
    required this.user,
    required this.onUserUpdated,
  });

  @override
  State<ProfileSettingsTab> createState() => _ProfileSettingsTabState();
}

class _ProfileSettingsTabState extends State<ProfileSettingsTab> {
  late TextEditingController _nameController;
  DateTime? _selectedDateOfBirth;
  double _minCycleLength = 21;
  double _maxCycleLength = 35;
  double _minPeriodLength = 3;
  double _maxPeriodLength = 10;
  bool _notificationsEnabled = true;
  bool _allowAiSymptoms = true;
  bool _allowAiJournal = true;
  DateTime? _selectedLastPeriodDate;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _initFields();
  }

  void _initFields() {
    _nameController = TextEditingController(text: widget.user.name);
    _selectedDateOfBirth = widget.user.dateOfBirth;
    _minCycleLength = widget.user.minCycleLength.toDouble();
    _maxCycleLength = widget.user.maxCycleLength.toDouble();
    _minPeriodLength = widget.user.minPeriodLength.toDouble();
    _maxPeriodLength = widget.user.maxPeriodLength.toDouble();
    _notificationsEnabled = widget.user.notificationsEnabled;
    _allowAiSymptoms = widget.user.allowAiSymptoms;
    _allowAiJournal = widget.user.allowAiJournal;
    _selectedLastPeriodDate = widget.user.lastPeriodDate;
  }

  @override
  void didUpdateWidget(ProfileSettingsTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.user != widget.user && !_isEditing) {
      _initFields();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    if (_nameController.text.trim().isEmpty) return;

    final updatedUser = widget.user.copyWith(
      name: _nameController.text.trim(),
      dateOfBirth: _selectedDateOfBirth,
      lastPeriodDate: _selectedLastPeriodDate,
      minCycleLength: _minCycleLength.round(),
      maxCycleLength: _maxCycleLength.round(),
      averageCycleLength: ((_minCycleLength + _maxCycleLength) / 2).round(),
      minPeriodLength: _minPeriodLength.round(),
      maxPeriodLength: _maxPeriodLength.round(),
      averagePeriodLength: ((_minPeriodLength + _maxPeriodLength) / 2).round(),
      notificationsEnabled: _notificationsEnabled,
      allowAiSymptoms: _allowAiSymptoms,
      allowAiJournal: _allowAiJournal,
    );

    await context.read<UserProvider>().updateUser(updatedUser);

    if (_selectedLastPeriodDate != null &&
        _selectedLastPeriodDate != widget.user.lastPeriodDate) {
      final exists = PeriodService.isDateInPeriod(_selectedLastPeriodDate!);
      if (!exists) {
        await PeriodService.recordPeriod(_selectedLastPeriodDate!);
      }
    }

    setState(() => _isEditing = false);
    widget.onUserUpdated();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profil mis à jour ✨'),
          backgroundColor: ThemeColors.getPrimaryColor(context),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);
    return Scaffold(
      backgroundColor: ThemeColors.getBackgroundColor(context),
      body: CustomScrollView(
        slivers: [
          // Dynamic Header with Profile Info
          SliverAppBar(
            expandedHeight: 340,
            floating: false,
            pinned: true,
            backgroundColor: ThemeColors.getBackgroundColor(context),
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                padding: const EdgeInsets.only(top: 60),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            await Navigator.pushNamed(
                              context,
                              '/avatar-selection',
                            );
                            widget.onUserUpdated();
                          },
                          child:
                              AvatarWidget(
                                avatarAsset: widget.user.avatarAsset,
                                profileImagePath: widget.user.profileImagePath,
                                size: 120,
                              ).animate().scale(
                                duration: 600.ms,
                                curve: Curves.elasticOut,
                              ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: ThemeColors.getPrimaryColor(context),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          child: const Icon(
                            IconlyBold.camera,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (!_isEditing) ...[
                      Text(
                        widget.user.name,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: ThemeColors.getTextColor(context),
                          letterSpacing: -1,
                        ),
                      ).animate().fadeIn().slideY(begin: 0.2, end: 0),
                      const SizedBox(height: 4),
                      Text(
                        widget.user.age != null
                            ? '${widget.user.age} ans • ${widget.user.averageCycleLength} jours'
                            : 'Utilisatrice Aida ✨',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: ThemeColors.getSecondaryTextColor(context),
                        ),
                      ),
                    ] else ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: TextField(
                          controller: _nameController,
                          textAlign: Alignment.center.x == 0
                              ? TextAlign.center
                              : TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: ThemeColors.getTextColor(context),
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Ton nom',
                            border: InputBorder.none,
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildActionChip(
                          label: _isEditing
                              ? 'Enregistrer'
                              : 'Modifier le profil',
                          icon: _isEditing ? Icons.check : IconlyBold.edit,
                          onTap: () {
                            if (_isEditing) {
                              _saveSettings();
                            } else {
                              setState(() => _isEditing = true);
                            }
                          },
                          primary: _isEditing,
                        ),
                        if (_isEditing) ...[
                          const SizedBox(width: 12),
                          _buildActionChip(
                            label: 'Annuler',
                            icon: Icons.close,
                            onTap: () {
                              _initFields();
                              setState(() => _isEditing = false);
                            },
                            primary: false,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Settings Sections
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // Section: Cycle
                  _buildSectionTitle('Ton Cycle'),
                  _buildSettingsCard(
                    children: [
                      _buildSettingsRow(
                        icon: IconlyBold.calendar,
                        title: 'Date de naissance',
                        subtitle: _selectedDateOfBirth != null
                            ? DateFormat(
                                'dd MMM yyyy',
                                'fr_FR',
                              ).format(_selectedDateOfBirth!)
                            : 'Non renseigné',
                        onTap: () => _selectDate(context, isBirthDate: true),
                      ),
                      const Divider(),
                      _buildSettingsRow(
                        icon: Icons.water_drop,
                        title: 'Dernière période',
                        subtitle: _selectedLastPeriodDate != null
                            ? DateFormat(
                                'dd MMM yyyy',
                                'fr_FR',
                              ).format(_selectedLastPeriodDate!)
                            : 'Non renseigné',
                        onTap: () => _selectDate(context, isBirthDate: false),
                      ),
                      const Divider(),
                      _buildRangeSetting(
                        title: 'Durée du cycle',
                        min: _minCycleLength,
                        max: _maxCycleLength,
                        rangeMin: 20,
                        rangeMax: 45,
                        onChanged: (v) => setState(() {
                          _minCycleLength = v.start;
                          _maxCycleLength = v.end;
                        }),
                      ),
                      const Divider(),
                      _buildRangeSetting(
                        title: 'Durée des règles',
                        min: _minPeriodLength,
                        max: _maxPeriodLength,
                        rangeMin: 2,
                        rangeMax: 15,
                        onChanged: (v) => setState(() {
                          _minPeriodLength = v.start;
                          _maxPeriodLength = v.end;
                        }),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Section: Apparence
                  _buildSectionTitle('Apparence'),
                  _buildSettingsCard(
                    children: [
                      _buildThemeSelector(themeService),
                      const Divider(),
                      _buildColorSelector(themeService),
                      const Divider(),
                      _buildFontSelector(themeService),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Section: Système
                  _buildSectionTitle('Système & Sécurité'),
                  _buildSettingsCard(
                    children: [
                      _buildSwitchRow(
                        icon: IconlyBold.notification,
                        title: 'Notifications',
                        value: _notificationsEnabled,
                        onChanged: (v) =>
                            setState(() => _notificationsEnabled = v),
                      ),
                      const Divider(),
                      _buildSwitchRow(
                        icon: Icons.auto_awesome,
                        title: 'Analyse IA des symptômes',
                        value: _allowAiSymptoms,
                        onChanged: (v) => setState(() => _allowAiSymptoms = v),
                      ),
                      const Divider(),
                      _buildSwitchRow(
                        icon: IconlyBold.document,
                        title: 'Analyse IA du journal',
                        value: _allowAiJournal,
                        onChanged: (v) => setState(() => _allowAiJournal = v),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Section: Aide & Support
                  _buildSectionTitle('Aide & Support'),
                  _buildSettingsCard(
                    children: [
                      _buildSettingsRow(
                        icon: Icons.auto_awesome,
                        title: 'Tester l\'IA Motivation',
                        subtitle:
                            'Génère une notification motivante via Gemini',
                        onTap: () async {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Génération de la motivation... ✨'),
                            ),
                          );
                          await AIMotivationService.sendDailyMotivation();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: ThemeColors.getSecondaryTextColor(context).withOpacity(0.7),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingsCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: ThemeColors.getCardColor(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: ThemeColors.getBorderColor(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: ThemeColors.getPrimaryColor(context).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: ThemeColors.getPrimaryColor(context),
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: ThemeColors.getTextColor(context),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: ThemeColors.getSecondaryTextColor(context),
        ),
      ),
      trailing: const Icon(IconlyLight.arrow_right_2, size: 16),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }

  Widget _buildRangeSetting({
    required String title,
    required double min,
    required double max,
    required double rangeMin,
    required double rangeMax,
    required ValueChanged<RangeValues> onChanged,
  }) {
    final primaryColor = ThemeColors.getPrimaryColor(context);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: ThemeColors.getTextColor(context),
                ),
              ),
              Text(
                '${min.round()} - ${max.round()} j',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          RangeSlider(
            values: RangeValues(min, max),
            min: rangeMin,
            max: rangeMax,
            onChanged: onChanged,
            activeColor: primaryColor,
            inactiveColor: primaryColor.withOpacity(0.1),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchRow({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile.adaptive(
      secondary: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: ThemeColors.getPrimaryColor(context).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: ThemeColors.getPrimaryColor(context),
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: ThemeColors.getTextColor(context),
        ),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: ThemeColors.getPrimaryColor(context),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }

  Widget _buildActionChip({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    bool primary = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: primary
              ? ThemeColors.getPrimaryColor(context)
              : ThemeColors.getSurfaceColor(context),
          borderRadius: BorderRadius.circular(30),
          boxShadow: primary
              ? [
                  BoxShadow(
                    color: ThemeColors.getPrimaryColor(
                      context,
                    ).withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ]
              : null,
          border: primary
              ? null
              : Border.all(color: ThemeColors.getBorderColor(context)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: primary ? Colors.white : ThemeColors.getTextColor(context),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: primary
                    ? Colors.white
                    : ThemeColors.getTextColor(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Appearence Sub-widgets
  Widget _buildThemeSelector(ThemeService ts) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mode',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: ThemeColors.getTextColor(context),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildThemeItem(
                ts,
                AppThemeMode.light,
                Icons.light_mode,
                'Clair',
              ),
              const SizedBox(width: 12),
              _buildThemeItem(ts, AppThemeMode.dark, Icons.dark_mode, 'Sombre'),
              const SizedBox(width: 12),
              _buildThemeItem(
                ts,
                AppThemeMode.system,
                Icons.brightness_auto,
                'Auto',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThemeItem(
    ThemeService ts,
    AppThemeMode mode,
    IconData icon,
    String label,
  ) {
    final isSelected = ts.themeMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => ts.setThemeMode(mode),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? ThemeColors.getPrimaryColor(context).withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? ThemeColors.getPrimaryColor(context)
                  : ThemeColors.getBorderColor(context),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? ThemeColors.getPrimaryColor(context)
                    : ThemeColors.getSecondaryTextColor(context),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? ThemeColors.getPrimaryColor(context)
                      : ThemeColors.getSecondaryTextColor(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColorSelector(ThemeService ts) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thème de couleur',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: ThemeColors.getTextColor(context),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: ThemeColors.aidaSeedColors.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final color = ThemeColors.aidaSeedColors[index];
                final isSelected = ts.seedColor == color;
                return GestureDetector(
                  onTap: () => ts.setSeedColor(color),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: Colors.white, width: 3)
                          : null,
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: color.withOpacity(0.4),
                                blurRadius: 8,
                              ),
                            ]
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 20)
                        : null,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFontSelector(ThemeService ts) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Police d\'écriture',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: ThemeColors.getTextColor(context),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ThemeColors.availableFonts.map((font) {
              final isSelected = ts.fontFamily == font;
              return GestureDetector(
                onTap: () => ts.setFontFamily(font),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? ThemeColors.getPrimaryColor(context)
                        : ThemeColors.getSurfaceColor(context),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? Colors.transparent
                          : ThemeColors.getBorderColor(context),
                    ),
                  ),
                  child: Text(
                    font,
                    style: TextStyle(
                      fontFamily: font,
                      fontSize: 13,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : ThemeColors.getTextColor(context),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(
    BuildContext context, {
    required bool isBirthDate,
  }) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          (isBirthDate ? _selectedDateOfBirth : _selectedLastPeriodDate) ??
          DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      locale: const Locale('fr', 'FR'),
    );

    if (picked != null) {
      setState(() {
        if (isBirthDate) {
          _selectedDateOfBirth = picked;
        } else {
          _selectedLastPeriodDate = picked;
        }
      });
    }
  }
}
