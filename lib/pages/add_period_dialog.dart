import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';
import '../models/period_model.dart';
import '../providers/user_provider.dart';
import '../providers/periods_provider.dart';
import '../core/theme_colors.dart';

class AddPeriodDialog extends StatefulWidget {
  final PeriodModel? periodToEdit;
  final bool isPastPeriod;

  const AddPeriodDialog({
    super.key,
    this.periodToEdit,
    this.isPastPeriod = false,
  });

  @override
  State<AddPeriodDialog> createState() => _AddPeriodDialogState();
}

class _AddPeriodDialogState extends State<AddPeriodDialog> {
  late DateTime _startDate;
  late DateTime? _endDate;
  late int _duration;

  @override
  void initState() {
    super.initState();
    final userProvider = context.read<UserProvider>();
    final user = userProvider.user;

    if (widget.periodToEdit != null) {
      _startDate = widget.periodToEdit!.startDate;
      _endDate = widget.periodToEdit!.endDate;
      _duration = widget.periodToEdit!.duration;
    } else {
      _startDate = widget.isPastPeriod
          ? DateTime.now().subtract(const Duration(days: 14))
          : DateTime.now();
      _endDate = null;
      _duration = user?.averagePeriodLength ?? 5;
    }
  }

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('fr', 'FR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: ThemeColors.getPrimaryColor(context),
              onPrimary: Colors.white,
              surface: ThemeColors.getCardColor(context),
              onSurface: ThemeColors.getTextColor(context),
            ),
            dialogBackgroundColor: ThemeColors.getBackgroundColor(context),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: ThemeColors.getPrimaryColor(context),
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            dialogTheme: DialogThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      setState(() {
        _startDate = picked;
        if (_endDate != null && _endDate!.isBefore(_startDate)) {
          _endDate = null;
        }
      });
    }
  }

  Future<void> _selectEndDate() async {
    final DateTime initialDate =
        _endDate ?? _startDate.add(Duration(days: _duration - 1));

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: _startDate,
      lastDate: DateTime.now(),
      locale: const Locale('fr', 'FR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: ThemeColors.getPrimaryColor(context),
              onPrimary: Colors.white,
              surface: ThemeColors.getCardColor(context),
              onSurface: ThemeColors.getTextColor(context),
            ),
            dialogBackgroundColor: ThemeColors.getBackgroundColor(context),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: ThemeColors.getPrimaryColor(context),
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            dialogTheme: DialogThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      setState(() {
        _endDate = picked;
        _duration = picked.difference(_startDate).inDays + 1;
      });
    }
  }

  void _updateDuration(int change) {
    setState(() {
      _duration = (_duration + change).clamp(1, 15);
      if (_endDate != null) {
        _endDate = _startDate.add(Duration(days: _duration - 1));
      }
    });
  }

  Future<void> _savePeriod() async {
    final periodsProvider = context.read<PeriodsProvider>();
    final userProvider = context.read<UserProvider>();

    if (userProvider.user == null) return;

    if (widget.periodToEdit != null) {
      // Modifier une période existante
      // Note: Pour l'instant on ne supporte pas la modification
      // On pourrait ajouter une méthode updatePeriod au provider
      // Pour simplifier, on supprime l'ancienne et on en crée une nouvelle
      await periodsProvider.deletePeriod(widget.periodToEdit!.id);
    }

    // Enregistrer la nouvelle période
    await periodsProvider.recordPeriod(_startDate, duration: _duration);

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.periodToEdit != null
                        ? 'Modifier la période'
                        : widget.isPastPeriod
                        ? 'Ajouter une période passée'
                        : 'Nouvelle période',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF212121),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Date de début
              _buildDateField(
                label: 'Date de début',
                date: _startDate,
                onTap: _selectStartDate,
                icon: IconlyBold.calendar,
              ),
              const SizedBox(height: 16),

              // Date de fin (optionnelle)
              _buildDateField(
                label: 'Date de fin (optionnelle)',
                date: _endDate,
                onTap: _selectEndDate,
                icon: IconlyBold.calendar,
                isOptional: true,
              ),
              const SizedBox(height: 16),

              // Durée
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Durée (jours)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF212121),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: _duration > 1
                              ? () => _updateDuration(-1)
                              : null,
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _duration > 1
                                  ? ThemeColors.getPrimaryColor(
                                      context,
                                    ).withOpacity(0.1)
                                  : Colors.grey[200],
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.remove,
                              color: _duration > 1
                                  ? ThemeColors.getPrimaryColor(context)
                                  : Colors.grey,
                              size: 20,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$_duration jour${_duration > 1 ? 's' : ''}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF212121),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: _duration < 15
                              ? () => _updateDuration(1)
                              : null,
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _duration < 15
                                  ? ThemeColors.getPrimaryColor(
                                      context,
                                    ).withOpacity(0.1)
                                  : Colors.grey[200],
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.add,
                              color: _duration < 15
                                  ? ThemeColors.getPrimaryColor(context)
                                  : Colors.grey,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Boutons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Annuler'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _savePeriod,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ThemeColors.getPrimaryColor(context),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Enregistrer',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
    required IconData icon,
    bool isOptional = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: const Color(0xFF4CAF50), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (isOptional) ...[
                          const SizedBox(width: 4),
                          Text(
                            '(optionnel)',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      date != null
                          ? DateFormat('dd MMMM yyyy', 'fr_FR').format(date)
                          : 'Non renseigné',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: date != null
                            ? const Color(0xFF212121)
                            : Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFF757575)),
            ],
          ),
        ),
      ),
    );
  }
}
