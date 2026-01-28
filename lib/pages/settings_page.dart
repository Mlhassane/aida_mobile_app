import 'dart:io';
import 'package:aida/services/period_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';
import '../services/notification_service.dart';
import '../services/theme_service.dart';
import '../services/avatar_service.dart';
import '../core/theme_colors.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  UserModel? _user;
  final TextEditingController _nameController = TextEditingController();
  DateTime? _selectedDateOfBirth;
  double _minCycleLength = 21;
  double _maxCycleLength = 35;
  double _minPeriodLength = 3;
  double _maxPeriodLength = 10;
  bool _notificationsEnabled = true;
  bool _allowAiSymptoms = true;
  bool _allowAiJournal = true;
  DateTime? _selectedLastPeriodDate;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _loadUser() {
    final user = UserService.getUser();
    if (user != null) {
      setState(() {
        _user = user;
        _nameController.text = user.name;
        _selectedDateOfBirth = user.dateOfBirth;
        _minCycleLength = user.minCycleLength.toDouble();
        _maxCycleLength = user.maxCycleLength.toDouble();
        _minPeriodLength = user.minPeriodLength.toDouble();
        _maxPeriodLength = user.maxPeriodLength.toDouble();
        _notificationsEnabled = user.notificationsEnabled;
        _allowAiSymptoms = user.allowAiSymptoms;
        _allowAiJournal = user.allowAiJournal;
        _selectedLastPeriodDate = user.lastPeriodDate;
      });
    }
  }

  Future<void> _selectDateOfBirth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _selectedDateOfBirth ??
          DateTime.now().subtract(const Duration(days: 365 * 20)),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      locale: const Locale('fr', 'FR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: ThemeColors.getPrimaryColor(context),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: const Color(0xFF424242),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      setState(() {
        _selectedDateOfBirth = picked;
      });
    }
  }

  Future<void> _selectLastPeriodDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedLastPeriodDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 90)),
      lastDate: DateTime.now(),
      locale: const Locale('fr', 'FR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: ThemeColors.getPrimaryColor(context),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: const Color(0xFF424242),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      setState(() {
        _selectedLastPeriodDate = picked;
      });
    }
  }

  Future<void> _saveSettings() async {
    if (_user == null) return;

    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 12),
              Text('Le nom ne peut pas être vide'),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    final updatedUser = _user!.copyWith(
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

    await UserService.updateUser(updatedUser);

    // Si la date a changé, on s'assure qu'une PeriodModel existe pour cette date
    if (_selectedLastPeriodDate != null &&
        _selectedLastPeriodDate != _user?.lastPeriodDate) {
      final exists = PeriodService.isDateInPeriod(_selectedLastPeriodDate!);
      if (!exists) {
        await PeriodService.recordPeriod(_selectedLastPeriodDate!);
      }
    }

    // Mettre à jour les notifications si nécessaire
    if (_notificationsEnabled) {
      // await NotificationService.updateNotifications();
    } else {
      // await NotificationService.cancelAllNotifications();
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('Paramètres enregistrés avec succès'),
            ],
          ),
          backgroundColor: ThemeColors.getPrimaryColor(context),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: ThemeColors.getPrimaryColor(context),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: ThemeColors.getBackgroundColor(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: ThemeColors.getSurfaceColor(context),
              shape: BoxShape.circle,
            ),
            child: Icon(
              IconlyLight.arrow_left_2,
              color: ThemeColors.getTextColor(context),
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Paramètres',
          style: TextStyle(
            color: ThemeColors.getTextColor(context),
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Profil
            _buildSectionTitle(
              'Profil',
              IconlyBold.profile,
              ThemeColors.getPrimaryColor(context),
            ),
            const SizedBox(height: 20),
            _buildProfileCard(),
            const SizedBox(height: 32),

            // Section Cycle
            _buildSectionTitle(
              'Cycle menstruel',
              IconlyBold.calendar,
              ThemeColors.getPrimaryColor(context),
            ),
            const SizedBox(height: 20),
            _buildCycleCard(),
            const SizedBox(height: 32),

            // Section Notifications
            _buildSectionTitle(
              'Notifications',
              IconlyBold.notification,
              ThemeColors.getPrimaryColor(context),
            ),
            const SizedBox(height: 20),
            _buildNotificationsCard(),
            const SizedBox(height: 32),

            // Section Confidentialité & IA
            _buildSectionTitle(
              'Confidentialité & IA',
              IconlyBold.lock,
              ThemeColors.getPrimaryColor(context),
            ),
            const SizedBox(height: 20),
            _buildPrivacyCard(),
            const SizedBox(height: 32),

            // Section Apparence
            _buildSectionTitle(
              'Apparence',
              IconlyBold.setting,
              ThemeColors.getPrimaryColor(context),
            ),
            const SizedBox(height: 20),
            _buildThemeCard(),
            const SizedBox(height: 20),
            _buildColorSelectorCard(),
            const SizedBox(height: 32),

            // Section Police d'écriture
            _buildSectionTitle(
              'Police d\'écriture',
              Icons.font_download,
              ThemeColors.getPrimaryColor(context),
            ),
            const SizedBox(height: 20),
            _buildFontSelectorCard(),
            const SizedBox(height: 32),

            // Bouton Enregistrer
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeColors.getPrimaryColor(context),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Enregistrer les modifications',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Row(
        children: [
          Icon(icon, color: color.withOpacity(0.8), size: 20),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: ThemeColors.getTextColor(context),
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: ThemeColors.getCardColor(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: ThemeColors.getBorderColor(context),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Avatar
          Center(
            child: Column(
              children: [
                GestureDetector(
                  onTap: () async {
                    final result = await Navigator.pushNamed(
                      context,
                      '/avatar-selection',
                    );
                    if (result == true) {
                      _loadUser();
                    }
                  },
                  child: _buildAvatarWidget(
                    _user?.avatarAsset,
                    _user?.profileImagePath,
                  ),
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: () async {
                    final result = await Navigator.pushNamed(
                      context,
                      '/avatar-selection',
                    );
                    if (result == true) {
                      _loadUser();
                    }
                  },
                  icon: Icon(
                    IconlyBold.edit,
                    size: 16,
                    color: ThemeColors.getPrimaryColor(context),
                  ),
                  label: Text(
                    'Changer l\'avatar',
                    style: TextStyle(
                      color: ThemeColors.getPrimaryColor(context),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Nom
          _buildTextField(
            label: 'Nom',
            controller: _nameController,
            icon: IconlyBold.profile,
            color: ThemeColors.getPrimaryColor(context),
          ),
          const SizedBox(height: 24),
          // Date de naissance
          _buildDateField(
            label: 'Date de naissance',
            date: _selectedDateOfBirth,
            onTap: _selectDateOfBirth,
            icon: IconlyBold.calendar,
            color: ThemeColors.getPrimaryColor(context),
          ),
        ],
      ),
    );
  }

  Widget _buildCycleCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: ThemeColors.getCardColor(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: ThemeColors.getBorderColor(context),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Durée du cycle (Intervalle)
          _buildRangeSliderField(
            label: 'Intervalle du cycle',
            values: RangeValues(_minCycleLength, _maxCycleLength),
            min: 21,
            max: 45,
            unit: 'jours',
            icon: IconlyBold.time_circle,
            color: ThemeColors.getPrimaryColor(context),
            onChanged: (values) {
              setState(() {
                _minCycleLength = values.start;
                _maxCycleLength = values.end;
              });
            },
          ),
          const SizedBox(height: 32),
          // Durée des règles (Intervalle)
          _buildRangeSliderField(
            label: 'Intervalle des règles',
            values: RangeValues(_minPeriodLength, _maxPeriodLength),
            min: 2,
            max: 15,
            unit: 'jours',
            icon: IconlyBold.activity,
            color: ThemeColors.getPrimaryColor(context),
            onChanged: (values) {
              setState(() {
                _minPeriodLength = values.start;
                _maxPeriodLength = values.end;
              });
            },
          ),
          const SizedBox(height: 32),
          // Dernière date des règles
          _buildDateField(
            label: 'Dernière date des règles',
            date: _selectedLastPeriodDate,
            onTap: _selectLastPeriodDate,
            icon: IconlyBold.calendar,
            color: ThemeColors.getPrimaryColor(context),
          ),
        ],
      ),
    );
  }

  Widget _buildRangeSliderField({
    required String label,
    required RangeValues values,
    required double min,
    required double max,
    required String unit,
    required IconData icon,
    required Color color,
    required Function(RangeValues) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: ThemeColors.getTextColor(context),
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                values.start.round() == values.end.round()
                    ? '${values.start.round()} $unit'
                    : '${values.start.round()} - ${values.end.round()} $unit',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        RangeSlider(
          values: values,
          min: min,
          max: max,
          divisions: (max - min).toInt(),
          activeColor: color,
          inactiveColor: color.withOpacity(0.2),
          labels: RangeLabels(
            values.start.round().toString(),
            values.end.round().toString(),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildNotificationsCard() {
    return Container(
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
              gradient: LinearGradient(
                colors: [
                  ThemeColors.getPrimaryColor(context).withOpacity(0.2),
                  ThemeColors.getPrimaryColor(context).withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              IconlyBold.notification,
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
                  'Activer les notifications',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: ThemeColors.getTextColor(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Recevoir des rappels pour vos règles',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Switch(
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
            activeColor: ThemeColors.getPrimaryColor(context),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: ThemeColors.getCardColor(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: ThemeColors.getBorderColor(context),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF9181F4).withOpacity(0.2),
                      Color(0xFF9181F4).withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Color(0xFF9181F4),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Assistant IA (Aida)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: ThemeColors.getTextColor(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Autoriser le partage pour l\'analyse :',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSwitchOption(
            title: 'Mes symptômes',
            subtitle: 'Pour des conseils santé adaptés',
            value: _allowAiSymptoms,
            onChanged: (val) => setState(() => _allowAiSymptoms = val),
          ),
          const SizedBox(height: 16),
          _buildSwitchOption(
            title: 'Mon journal',
            subtitle: 'Pour analyser ton humeur',
            value: _allowAiJournal,
            onChanged: (val) => setState(() => _allowAiJournal = val),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchOption({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: ThemeColors.getTextColor(context),
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: ThemeColors.getPrimaryColor(context),
        ),
      ],
    );
  }

  Widget _buildThemeCard() {
    return Consumer<ThemeService>(
      builder: (context, themeService, _) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: ThemeColors.getCardColor(context),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: ThemeColors.getBorderColor(context),
              width: 1,
            ),
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
                          ThemeColors.getPrimaryColor(context).withOpacity(0.2),
                          ThemeColors.getPrimaryColor(context).withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      IconlyBold.setting,
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
                          'Mode d\'affichage',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: ThemeColors.getTextColor(context),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Thème actuel: ${themeService.themeModeLabel}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildThemeOption(
                title: 'Clair',
                icon: Icons.light_mode,
                value: AppThemeMode.light,
                selectedValue: themeService.themeMode,
                onTap: () {
                  themeService.setThemeMode(AppThemeMode.light);
                },
              ),
              const SizedBox(height: 12),
              _buildThemeOption(
                title: 'Sombre',
                icon: Icons.dark_mode,
                value: AppThemeMode.dark,
                selectedValue: themeService.themeMode,
                onTap: () {
                  themeService.setThemeMode(AppThemeMode.dark);
                },
              ),
              const SizedBox(height: 12),
              _buildThemeOption(
                title: 'Système',
                subtitle: 'Suivre les paramètres du système',
                icon: Icons.brightness_auto,
                value: AppThemeMode.system,
                selectedValue: themeService.themeMode,
                onTap: () {
                  themeService.setThemeMode(AppThemeMode.system);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeOption({
    required String title,
    String? subtitle,
    required IconData icon,
    required AppThemeMode value,
    required AppThemeMode selectedValue,
    required VoidCallback onTap,
  }) {
    final isSelected = value == selectedValue;
    final color = isSelected
        ? ThemeColors.getPrimaryColor(context)
        : ThemeColors.getSecondaryTextColor(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? ThemeColors.getPrimaryColor(context).withOpacity(0.1)
                : ThemeColors.getSurfaceColor(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? ThemeColors.getPrimaryColor(context)
                  : ThemeColors.getBorderColor(context),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? ThemeColors.getPrimaryColor(context).withOpacity(0.2)
                      : ThemeColors.getBorderColor(context),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? ThemeColors.getTextColor(context)
                            : ThemeColors.getSecondaryTextColor(context),
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: ThemeColors.getSecondaryTextColor(context),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (isSelected)
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: ThemeColors.getPrimaryColor(context),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 16),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColorSelectorCard() {
    return Consumer<ThemeService>(
      builder: (context, themeService, _) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: ThemeColors.getCardColor(context),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: ThemeColors.getBorderColor(context),
              width: 1,
            ),
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
                          themeService.seedColor.withOpacity(0.2),
                          themeService.seedColor.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      IconlyBold.play,
                      color: themeService.seedColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Couleur du thème',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: ThemeColors.getTextColor(context),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Personnalisez la couleur principale',
                          style: TextStyle(
                            fontSize: 13,
                            color: ThemeColors.getSecondaryTextColor(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: ThemeColors.aidaSeedColors.length,
                itemBuilder: (context, index) {
                  final color = ThemeColors.aidaSeedColors[index];
                  final isSelected = themeService.seedColor == color;

                  return GestureDetector(
                    onTap: () {
                      themeService.setSeedColor(color);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: Colors.white, width: 3)
                            : null,
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: color.withOpacity(0.5),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ]
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 20,
                            )
                          : null,
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFontSelectorCard() {
    final List<String> fonts = ThemeColors.availableFonts;

    return Consumer<ThemeService>(
      builder: (context, themeService, _) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: ThemeColors.getCardColor(context),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: ThemeColors.getBorderColor(context),
              width: 1,
            ),
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
                          ThemeColors.getPrimaryColor(context).withOpacity(0.2),
                          ThemeColors.getPrimaryColor(context).withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.font_download,
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
                          'Police de caractères',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: ThemeColors.getTextColor(context),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Actuelle: ${themeService.fontFamily}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: fonts.map((font) {
                  return _buildFontOption(
                    context,
                    font,
                    themeService.fontFamily == font,
                    () {
                      themeService.setFontFamily(font);
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFontOption(
    BuildContext context,
    String fontName,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? ThemeColors.getPrimaryColor(context).withOpacity(0.1)
              : ThemeColors.getSurfaceColor(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? ThemeColors.getPrimaryColor(context)
                : ThemeColors.getBorderColor(context),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          fontName,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected
                ? ThemeColors.getPrimaryColor(context)
                : ThemeColors.getTextColor(context),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: controller,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: ThemeColors.getTextColor(context),
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: ThemeColors.getSurfaceColor(context),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: ThemeColors.getBorderColor(context),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: color, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    date != null
                        ? DateFormat('dd MMMM yyyy', 'fr_FR').format(date)
                        : 'Sélectionner une date',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: date != null
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: date != null
                          ? ThemeColors.getTextColor(context)
                          : ThemeColors.getSecondaryTextColor(context),
                    ),
                  ),
                ),
                Icon(
                  IconlyLight.calendar,
                  color: date != null
                      ? color
                      : ThemeColors.getSecondaryTextColor(context),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Widget pour afficher l'avatar
  Widget _buildAvatarWidget(String? avatarAsset, String? profileImagePath) {
    if (profileImagePath != null) {
      // Afficher la photo personnelle
      return Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: ThemeColors.getPrimaryColor(context).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipOval(
          child: Image.file(
            File(profileImagePath),
            width: 100,
            height: 100,
            cacheWidth: 100,
            cacheHeight: 100,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ThemeColors.getPrimaryColor(context),
                      ThemeColors.getPrimaryColor(context).withOpacity(0.7),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(IconlyBold.profile, color: Colors.white, size: 50),
              );
            },
          ),
        ),
      );
    } else if (avatarAsset != null) {
      // Afficher l'avatar asset
      return Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: ThemeColors.getPrimaryColor(context).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipOval(
          child: Image.asset(
            AvatarService.getAvatarAssetPath(avatarAsset),
            width: 100,
            height: 100,
            cacheWidth: 100,
            cacheHeight: 100,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ThemeColors.getPrimaryColor(context),
                      ThemeColors.getPrimaryColor(context).withOpacity(0.7),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(IconlyBold.profile, color: Colors.white, size: 50),
              );
            },
          ),
        ),
      );
    } else {
      // Avatar par défaut
      return Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              ThemeColors.getPrimaryColor(context),
              ThemeColors.getPrimaryColor(context).withOpacity(0.7),
            ],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: ThemeColors.getPrimaryColor(context).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(IconlyBold.profile, color: Colors.white, size: 50),
      );
    }
  }
}
