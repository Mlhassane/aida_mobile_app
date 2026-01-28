import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:iconly/iconly.dart';
import '../models/journal_model.dart';
import '../services/journal_service.dart';
import '../core/theme_colors.dart';
import '../core/logger.dart';

class JournalWritePage extends StatefulWidget {
  final JournalModel? entry;

  const JournalWritePage({super.key, this.entry});

  @override
  State<JournalWritePage> createState() => _JournalWritePageState();
}

class _JournalWritePageState extends State<JournalWritePage> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _tagsController;
  String? _selectedMood;
  bool _isAutoSaving = false;
  bool _hasUnsavedChanges = false;
  late DateTime _selectedDate;
  Timer? _autoSaveTimer;
  String? _tempEntryId; // ID temporaire pour l'auto-save

  // Constantes statiques pour éviter la recréation
  static const List<String> moods = [
    'happy',
    'sad',
    'anxious',
    'calm',
    'irritated',
    'energetic',
    'tired',
    'grateful',
    'confused',
    'peaceful',
  ];

  static const Map<String, String> moodLabels = {
    'happy': '😊 Heureuse',
    'sad': '😢 Triste',
    'anxious': '😰 Anxieuse',
    'calm': '😌 Calme',
    'irritated': '😠 Irritée',
    'energetic': '⚡ Énergique',
    'tired': '😴 Fatiguée',
    'grateful': '🙏 Reconnaissante',
    'confused': '😕 Confuse',
    'peaceful': '☮️ Paisible',
  };

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.entry?.title ?? '');
    _contentController = TextEditingController(
      text: widget.entry?.content ?? '',
    );
    _tagsController = TextEditingController(
      text: widget.entry?.tags.join(', ') ?? '',
    );
    _selectedMood = widget.entry?.mood;
    _selectedDate = widget.entry?.date ?? DateTime.now();
    _tempEntryId = widget.entry?.id;

    // Écouter les changements pour l'auto-save
    _titleController.addListener(_onTextChanged);
    _contentController.addListener(_onTextChanged);
    _tagsController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    if (_contentController.text.trim().isNotEmpty) {
      _hasUnsavedChanges = true;
      _scheduleAutoSave();
    }
  }

  void _scheduleAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(const Duration(seconds: 2), () {
      _autoSave();
    });
  }

  Future<void> _autoSave() async {
    if (!_hasUnsavedChanges || _contentController.text.trim().isEmpty) {
      return;
    }

    if (mounted) {
      setState(() {
        _isAutoSaving = true;
      });
    }

    try {
      final tags = _tagsController.text
          .split(',')
          .map((t) => t.trim())
          .where((t) => t.isNotEmpty)
          .toList();

      if (_tempEntryId == null) {
        // Créer une nouvelle entrée temporaire
        final entry = await JournalService.createEntry(
          date: _selectedDate,
          title: _titleController.text.trim().isEmpty
              ? null
              : _titleController.text.trim(),
          content: _contentController.text.trim(),
          mood: _selectedMood,
          tags: tags,
        );
        _tempEntryId = entry.id;
      } else {
        // Mettre à jour l'entrée existante
        final entries = JournalService.getAllEntries();
        final existingEntry = entries.firstWhere(
          (e) => e.id == _tempEntryId,
          orElse: () => widget.entry!,
        );

        final updated = existingEntry.copyWith(
          date: _selectedDate,
          title: _titleController.text.trim().isEmpty
              ? null
              : _titleController.text.trim(),
          content: _contentController.text.trim(),
          mood: _selectedMood,
          tags: tags,
        );
        await JournalService.updateEntry(updated);
      }

      _hasUnsavedChanges = false;
    } catch (e, st) {
      // Erreur silencieuse pour l'auto-save
      logger.warning('Auto-save error: $e', e, st);
    } finally {
      if (mounted) {
        setState(() {
          _isAutoSaving = false;
        });
      }
    }
  }

  @override
  void dispose() {
    // Sauvegarder immédiatement avant de quitter si il y a des changements
    if (_hasUnsavedChanges && _contentController.text.trim().isNotEmpty) {
      _autoSaveTimer?.cancel();
      // Sauvegarde synchrone avant de quitter
      _saveBeforeExit();
    } else {
      _autoSaveTimer?.cancel();
    }

    _titleController.removeListener(_onTextChanged);
    _contentController.removeListener(_onTextChanged);
    _tagsController.removeListener(_onTextChanged);
    _titleController.dispose();
    _contentController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  // Sauvegarde synchrone avant de quitter
  void _saveBeforeExit() {
    if (_contentController.text.trim().isEmpty) return;

    try {
      final tags = _tagsController.text
          .split(',')
          .map((t) => t.trim())
          .where((t) => t.isNotEmpty)
          .toList();

      if (_tempEntryId == null) {
        // Créer une nouvelle entrée
        JournalService.createEntry(
          date: _selectedDate,
          title: _titleController.text.trim().isEmpty
              ? null
              : _titleController.text.trim(),
          content: _contentController.text.trim(),
          mood: _selectedMood,
          tags: tags,
        ).then((entry) {
          _tempEntryId = entry.id;
        });
      } else {
        // Mettre à jour l'entrée existante
        final entries = JournalService.getAllEntries();
        final existingEntry = entries.firstWhere(
          (e) => e.id == _tempEntryId,
          orElse: () => widget.entry!,
        );

        final updated = existingEntry.copyWith(
          date: _selectedDate,
          title: _titleController.text.trim().isEmpty
              ? null
              : _titleController.text.trim(),
          content: _contentController.text.trim(),
          mood: _selectedMood,
          tags: tags,
        );
        JournalService.updateEntry(updated);
      }
    } catch (e, st) {
      logger.severe('Save before exit error: $e', e, st);
    }
  }

  Future<void> _deleteEntry() async {
    if (widget.entry == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Supprimer l\'entrée'),
        content: const Text(
          'Es-tu sûre de vouloir supprimer cette entrée ? Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeColors.getErrorColor(context),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Supprimer',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await JournalService.deleteEntry(widget.entry!.id);
      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Entrée supprimée'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
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

    if (picked != null) {
      if (mounted) {
        setState(() {
          _selectedDate = picked;
          _hasUnsavedChanges = true;
        });
      }
      _scheduleAutoSave(); // Trigger save on date change
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Sauvegarder avant de quitter
        if (_hasUnsavedChanges && _contentController.text.trim().isNotEmpty) {
          _autoSaveTimer?.cancel();
          await _autoSave();
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: ThemeColors.getBackgroundColor(context),
        appBar: AppBar(
          backgroundColor: ThemeColors.getBackgroundColor(context),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(IconlyLight.arrow_left_2),
            onPressed: () async {
              // Sauvegarder avant de quitter
              if (_hasUnsavedChanges &&
                  _contentController.text.trim().isNotEmpty) {
                _autoSaveTimer?.cancel();
                await _autoSave();
              }
              if (context.mounted) {
                Navigator.pop(context, true);
              }
            },
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.entry == null ? 'Nouvelle entrée' : 'Modifier l\'entrée',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: ThemeColors.getTextColor(context),
                ),
              ),
              if (_isAutoSaving)
                Text(
                  'Enregistrement automatique...',
                  style: TextStyle(
                    fontSize: 11,
                    color: ThemeColors.getPrimaryColor(context),
                    fontWeight: FontWeight.w500,
                  ),
                )
              else if (_hasUnsavedChanges)
                Text(
                  'Modifications non enregistrées',
                  style: TextStyle(
                    fontSize: 11,
                    color: ThemeColors.getSecondaryTextColor(context),
                  ),
                ),
            ],
          ),
          actions: [
            // Sélecteur de date optionnel
            InkWell(
              onTap: _selectDate,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: ThemeColors.getCardColor(context),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: ThemeColors.getBorderColor(context).withOpacity(0.5),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      IconlyBold.calendar,
                      color: ThemeColors.getPrimaryColor(context),
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      DateFormat('dd MMM', 'fr_FR').format(_selectedDate),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: ThemeColors.getTextColor(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (widget.entry != null)
              IconButton(
                icon: Icon(
                  IconlyLight.delete,
                  color: ThemeColors.getErrorColor(context),
                ),
                onPressed: _deleteEntry,
              ),
            // Bouton d'enregistrement explicite (seulement pour la première fois)
            if (_tempEntryId == null && !_isAutoSaving)
              IconButton(
                onPressed: () async {
                  FocusScope.of(context).unfocus();
                  await _autoSave();
                },
                icon: Icon(
                  IconlyBold.tick_square,
                  color: ThemeColors.getPrimaryColor(context),
                ),
                tooltip: 'Enregistrer',
              ),

            // Indicateur de sauvegarde automatique (si déjà enregistré une fois)
            if (_tempEntryId != null)
              if (_isAutoSaving)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: ThemeColors.getPrimaryColor(context),
                    ),
                  ),
                )
              else if (_hasUnsavedChanges)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Icon(
                    Icons.cloud_upload_outlined,
                    size: 20,
                    color: Colors.grey,
                  ),
                ),
          ],
        ),
        body: Container(
          color: ThemeColors.getBackgroundColor(context),
          child: SingleChildScrollView(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Titre (optionnel) - Sans padding ni margin, couleur unifiée
                Container(
                  color: ThemeColors.getBackgroundColor(context),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: TextField(
                    controller: _titleController,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: ThemeColors.getTextColor(context),
                      letterSpacing: -0.5,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Donne un titre à cette entrée...',
                      hintStyle: TextStyle(
                        color: ThemeColors.getSecondaryTextColor(
                          context,
                        ).withOpacity(0.6),
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      filled: true,
                      fillColor: ThemeColors.getBackgroundColor(context),
                    ),
                  ),
                ),

                // Contenu - Zone d'écriture libre sans padding ni margin, couleur unifiée
                Container(
                  color: ThemeColors.getBackgroundColor(context),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    controller: _contentController,
                    maxLines: null,
                    minLines: 20,
                    style: TextStyle(
                      fontSize: 17,
                      height: 1.9,
                      color: ThemeColors.getTextColor(context),
                      letterSpacing: 0.2,
                    ),
                    decoration: InputDecoration(
                      hintText:
                          'Exprime-toi librement...\n\nCet espace est à toi. Écris sans filtre ni jugement. Laisse tes pensées couler naturellement.\n\nTout ce que tu écris est automatiquement sauvegardé.',
                      hintStyle: TextStyle(
                        fontSize: 17,
                        height: 1.9,
                        color: ThemeColors.getSecondaryTextColor(
                          context,
                        ).withOpacity(0.7),
                        letterSpacing: 0.2,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      filled: true,
                      fillColor: ThemeColors.getBackgroundColor(context),
                    ),
                    textInputAction: TextInputAction.newline,
                  ),
                ),
                const SizedBox(height: 32),

                // Section Humeur - Design en onglets
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: ThemeColors.getCardColor(context),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: ThemeColors.getBorderColor(
                        context,
                      ).withOpacity(0.5),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            IconlyBold.heart,
                            color: ThemeColors.getPrimaryColor(context),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Comment te sens-tu aujourd\'hui ?',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: ThemeColors.getTextColor(context),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Onglets horizontaux
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: moods.map((mood) {
                            final isSelected = _selectedMood == mood;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedMood = isSelected ? null : mood;
                                });
                                _scheduleAutoSave();
                              },
                              child: Container(
                                margin: const EdgeInsets.only(right: 12),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  gradient: isSelected
                                      ? LinearGradient(
                                          colors: [
                                            ThemeColors.getPrimaryColor(
                                              context,
                                            ),
                                            ThemeColors.getPrimaryColor(
                                              context,
                                            ).withOpacity(0.8),
                                          ],
                                        )
                                      : null,
                                  color: isSelected
                                      ? null
                                      : ThemeColors.getBackgroundColor(context),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected
                                        ? ThemeColors.getPrimaryColor(context)
                                        : ThemeColors.getBorderColor(context),
                                    width: isSelected ? 0 : 1.5,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: ThemeColors.getPrimaryColor(
                                              context,
                                            ).withOpacity(0.3),
                                            blurRadius: 12,
                                            offset: const Offset(0, 4),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      moodLabels[mood]!.split(' ')[0], // Emoji
                                      style: const TextStyle(fontSize: 24),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      moodLabels[mood]!.split(' ')[1], // Texte
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: isSelected
                                            ? Colors.white
                                            : ThemeColors.getTextColor(context),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Section Tags - Design amélioré
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: ThemeColors.getCardColor(context),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: ThemeColors.getBorderColor(
                        context,
                      ).withOpacity(0.5),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            IconlyBold.category,
                            color: ThemeColors.getPrimaryColor(context),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Tags (optionnel)',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: ThemeColors.getTextColor(context),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _tagsController,
                        onChanged: (_) => _scheduleAutoSave(),
                        decoration: InputDecoration(
                          hintText:
                              'Séparés par des virgules (ex: famille, travail, réflexion)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: ThemeColors.getBorderColor(context),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: ThemeColors.getBorderColor(context),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: ThemeColors.getPrimaryColor(context),
                              width: 2,
                            ),
                          ),
                          prefixIcon: Icon(
                            IconlyLight.category,
                            color: ThemeColors.getSecondaryTextColor(context),
                          ),
                          filled: true,
                          fillColor: ThemeColors.getBackgroundColor(context),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
