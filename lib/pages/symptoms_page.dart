import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:intl/intl.dart';
import '../core/theme_colors.dart';
import '../services/symptom_service.dart';
import '../models/symptom_model.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/hive_service.dart';

class SymptomsPage extends StatefulWidget {
  const SymptomsPage({super.key});

  @override
  State<SymptomsPage> createState() => _SymptomsPageState();
}

class _SymptomsPageState extends State<SymptomsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDate = DateTime.now();

  final Map<String, List<Map<String, dynamic>>> _symptomCategoriesData = {
    'Physique': [
      {'id': 'Crampes', 'icon': Icons.fitness_center, 'color': Color(0xFFFF7043)},
      {'id': 'Maux de tête', 'icon': Icons.psychology, 'color': Color(0xFFFF7043)},
      {'id': 'Fatigue', 'icon': Icons.battery_alert, 'color': Color(0xFFFF7043)},
      {'id': 'Ballonnements', 'icon': Icons.waves, 'color': Color(0xFFFF7043)},
      {'id': 'Nausées', 'icon': Icons.sick, 'color': Color(0xFFFF7043)},
      {'id': 'Douleurs dorsales', 'icon': Icons.accessibility, 'color': Color(0xFFFF7043)},
    ],
    'Émotionnel': [
      {'id': 'Anxiété', 'icon': Icons.psychology_alt, 'color': Color(0xFF9181F4)},
      {'id': 'Irritabilité', 'icon': Icons.priority_high, 'color': Color(0xFF9181F4)},
      {'id': 'Tristesse', 'icon': Icons.sentiment_dissatisfied, 'color': Color(0xFF9181F4)},
      {'id': 'Stress', 'icon': Icons.bolt, 'color': Color(0xFF9181F4)},
      {'id': 'Sautes d\'humeur', 'icon': Icons.compare_arrows, 'color': Color(0xFF9181F4)},
    ],
    'Peau': [
      {'id': 'Acné', 'icon': Icons.face, 'color': Color(0xFF4ECDC4)},
      {'id': 'Peau grasse', 'icon': Icons.opacity, 'color': Color(0xFF4ECDC4)},
      {'id': 'Peau sèche', 'icon': Icons.texture, 'color': Color(0xFF4ECDC4)},
      {'id': 'Rougeurs', 'icon': Icons.flare, 'color': Color(0xFF4ECDC4)},
    ],
    'Autre': [
      {'id': 'Insomnie', 'icon': Icons.bedtime, 'color': Color(0xFFFF4D6D)},
      {'id': 'Fringales', 'icon': Icons.restaurant, 'color': Color(0xFFFF4D6D)},
      {'id': 'Sensibilité seins', 'icon': Icons.favorite_border, 'color': Color(0xFFFF4D6D)},
      {'id': 'Libido', 'icon': Icons.favorite, 'color': Color(0xFFFF4D6D)},
    ],
  };

  final Set<String> _selectedSymptoms = {};
  String? _selectedMood;
  String _notes = '';
  final TextEditingController _notesController = TextEditingController();
  final PageController _moodPageController = PageController(viewportFraction: 0.35, initialPage: 0);

  final List<Map<String, dynamic>> _moodsList = [
    {'id': 'loving', 'label': 'Aimante', 'icon': Icons.favorite, 'color': const Color(0xFFFF4D6D)},
    {'id': 'energetic', 'label': 'Énergique', 'icon': Icons.bolt, 'color': const Color(0xFFFFD166)},
    {'id': 'calm', 'label': 'Calme', 'icon': Icons.cloud, 'color': const Color(0xFF4ECDC4)},
    {'id': 'happy', 'label': 'Heureuse', 'icon': Icons.sentiment_very_satisfied, 'color': const Color(0xFF9181F4)},
    {'id': 'sad', 'label': 'Triste', 'icon': Icons.sentiment_very_dissatisfied, 'color': const Color(0xFF457B9D)},
    {'id': 'anxious', 'label': 'Anxieuse', 'icon': Icons.waves, 'color': const Color(0xFFA8DADC)},
    {'id': 'irritated', 'label': 'Irritée', 'icon': Icons.fireplace, 'color': const Color(0xFFE63946)},
  ];

  final Map<String, PageController> _categoryControllers = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Initialiser un controller pour chaque catégorie
    for (var key in _symptomCategoriesData.keys) {
      _categoryControllers[key] = PageController(viewportFraction: 0.3, initialPage: 0);
    }
    
    _loadSymptomsForDate(_selectedDate);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _notesController.dispose();
    _moodPageController.dispose();
    _categoryControllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  void _loadSymptomsForDate(DateTime date) {
    final existingSymptom = SymptomService.getSymptomForDate(date);
    setState(() {
      _selectedSymptoms.clear();
      if (existingSymptom != null) {
        _selectedSymptoms.addAll(existingSymptom.symptoms);
        _selectedMood = existingSymptom.mood;
        _notes = existingSymptom.notes ?? '';
        _notesController.text = _notes;
        
        // Aligner le sélecteur d'humeur
        if (_selectedMood != null) {
          final index = _moodsList.indexWhere((m) => m['id'] == _selectedMood);
          if (index != -1 && _moodPageController.hasClients) {
            _moodPageController.jumpToPage(index);
          }
        }
      } else {
        _selectedMood = null;
        _notes = '';
        _notesController.text = '';
      }
    });
  }

  void _saveSymptoms() async {
    final symptom = SymptomModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: _selectedDate,
      mood: _selectedMood,
      symptoms: _selectedSymptoms.toList(),
      notes: _notes,
      createdAt: DateTime.now(),
    );

    await SymptomService.saveSymptom(symptom);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Text('${_selectedSymptoms.length} symptômes enregistrés'),
            ],
          ),
          backgroundColor: ThemeColors.getPrimaryColor(context),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      // Ne pas fermer la page, juste confirmer
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.getBackgroundColor(context),
      extendBodyBehindAppBar: true,
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
          'Symptômes',
          style: TextStyle(
            color: ThemeColors.getTextColor(context),
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: ThemeColors.getPrimaryColor(context),
          unselectedLabelColor: Colors.grey,
          indicatorColor: ThemeColors.getPrimaryColor(context),
          tabs: const [
            Tab(text: 'Saisie'),
            Tab(text: 'Historique'),
          ],
        ),
        actions: [
          if (_tabController.index == 0)
            TextButton(
              onPressed: _saveSymptoms,
              child: Text(
                'Enregistrer',
                style: TextStyle(
                  color: ThemeColors.getPrimaryColor(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          // Background Gradient doux
          AnimatedContainer(
            duration: 800.ms,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFFFB7B2).withOpacity(0.3),
                  ThemeColors.getBackgroundColor(context),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
            child: TabBarView(
              controller: _tabController,
              children: [_buildEntryTab(), _buildHistoryTab()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEntryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date Selector
          _buildDateSelector(),
          const SizedBox(height: 24),

          // Symptom Categories
          Text(
            'Comment te sens-tu ?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: ThemeColors.getTextColor(context),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 20),
          
          _buildMoodCarousel(),
          
          const SizedBox(height: 32),

          ..._symptomCategoriesData.entries.map(
            (entry) => _buildPremiumSymptomCategory(entry.key, entry.value),
          ),

          const SizedBox(height: 24),

          // Notes Section
          Text(
            'Notes personnelles',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: ThemeColors.getTextColor(context),
            ),
          ),
          const SizedBox(height: 12),
          _buildNotesField(),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    return ValueListenableBuilder(
      valueListenable: HiveService.symptomsBox.listenable(),
      builder: (context, box, _) {
        final symptoms =
            SymptomService.getAllSymptoms(); // Déjà trié par date DESC

        if (symptoms.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(IconlyLight.activity, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  'Aucun symptôme enregistré',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: symptoms.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final symptom = symptoms[index];
            return _buildHistoryCard(symptom);
          },
        );
      },
    );
  }

  Widget _buildHistoryCard(SymptomModel symptom) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                toBeginningOfSentenceCase(
                      DateFormat('EEEE dd MMMM', 'fr_FR').format(symptom.date),
                    ) ??
                    '',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: ThemeColors.getTextColor(context),
                ),
              ),
              if (symptom.mood != null)
                Text(symptom.mood!, style: const TextStyle(fontSize: 20)),
            ],
          ),
          if (symptom.symptoms.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: symptom.symptoms
                  .map(
                    (s) => Chip(
                      label: Text(s, style: const TextStyle(fontSize: 12)),
                      backgroundColor: ThemeColors.getPrimaryColor(
                        context,
                      ).withOpacity(0.1),
                      labelStyle: TextStyle(
                        color: ThemeColors.getPrimaryColor(context),
                        fontWeight: FontWeight.w600,
                      ),
                      padding: EdgeInsets.zero,
                      labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                      side: BorderSide.none,
                    ),
                  )
                  .toList(),
            ),
          ],
          if (symptom.notes != null && symptom.notes!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                symptom.notes!,
                style: TextStyle(
                  fontSize: 13,
                  color: ThemeColors.getSecondaryTextColor(context),
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
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
        if (date != null) {
          setState(() => _selectedDate = date);
          _loadSymptomsForDate(date);
        }
      },
      borderRadius: BorderRadius.circular(24),
      child: Container(
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
                color: ThemeColors.getPrimaryColor(context).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                IconlyBold.calendar,
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
                    'Date sélectionnée',
                    style: TextStyle(
                      fontSize: 12,
                      color: ThemeColors.getSecondaryTextColor(context),
                    ),
                  ),
                  Text(
                    DateFormat(
                      'EEEE dd MMMM yyyy',
                      'fr_FR',
                    ).format(_selectedDate),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: ThemeColors.getTextColor(context),
                    ),
                  ),
                ],
              ),
            ),
            Icon(IconlyLight.edit, color: ThemeColors.getPrimaryColor(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumSymptomCategory(String category, List<Map<String, dynamic>> symptoms) {
    final controller = _categoryControllers[category]!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 24, bottom: 8),
          child: Text(
            category,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: ThemeColors.getTextColor(context),
            ),
          ),
        ),
        SizedBox(
          height: 160,
          child: PageView.builder(
            controller: controller,
            itemCount: symptoms.length,
            padEnds: false,
            itemBuilder: (context, index) {
              final symptom = symptoms[index];
              final color = symptom['color'] as Color;

              return AnimatedBuilder(
                animation: controller,
                builder: (context, child) {
                  double value = 1.0;
                  if (controller.position.haveDimensions) {
                    value = controller.page! - index;
                    value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
                  } else {
                    value = (index == 0) ? 1.0 : 0.7;
                  }

                  final isSelected = _selectedSymptoms.contains(symptom['id']);

                  return Center(
                    child: Transform.scale(
                      scale: Curves.easeOut.transform(value),
                      child: Opacity(
                        opacity: Curves.easeOut.transform(value).clamp(0.5, 1.0),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                _selectedSymptoms.remove(symptom['id']);
                              } else {
                                _selectedSymptoms.add(symptom['id']);
                              }
                            });
                          },
                          child: Container(
                            width: 100,
                            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? color : Colors.white,
                              borderRadius: BorderRadius.circular(50),
                              boxShadow: [
                                BoxShadow(
                                  color: (isSelected ? color : Colors.black).withOpacity(0.1),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                              border: Border.all(
                                color: isSelected ? color : Colors.white,
                                width: 2,
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: isSelected ? Colors.white.withOpacity(0.2) : color.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    symptom['icon'],
                                    color: isSelected ? Colors.white : color,
                                    size: 24,
                                  ),
                                ),
                                if (value > 0.8) ...[
                                  const SizedBox(height: 10),
                                  Text(
                                    symptom['id'],
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: isSelected ? Colors.white : ThemeColors.getTextColor(context).withOpacity(0.7),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNotesField() {
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
      child: TextField(
        controller: _notesController,
        maxLines: 5,
        decoration: InputDecoration(
          hintText: 'Ajoute des notes sur ton état général...',
          hintStyle: TextStyle(
            color: ThemeColors.getSecondaryTextColor(context),
          ),
          border: InputBorder.none,
        ),
        style: TextStyle(color: ThemeColors.getTextColor(context)),
        onChanged: (value) => _notes = value,
      ),
    );
  }

  Widget _buildMoodCarousel() {
    return SizedBox(
      height: 160,
      child: PageView.builder(
        controller: _moodPageController,
        itemCount: _moodsList.length,
        onPageChanged: (index) {
          setState(() {
            _selectedMood = _moodsList[index]['id'];
          });
        },
        itemBuilder: (context, index) {
          final mood = _moodsList[index];
          return AnimatedBuilder(
            animation: _moodPageController,
            builder: (context, child) {
              double value = 1.0;
              if (_moodPageController.position.haveDimensions) {
                value = _moodPageController.page! - index;
                value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
              } else {
                if (_selectedMood == mood['id']) value = 1.0;
                else value = 0.7;
              }

              return Center(
                child: Transform.scale(
                  scale: Curves.easeOut.transform(value),
                  child: Opacity(
                    opacity: Curves.easeOut.transform(value),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(50),
                            boxShadow: [
                              BoxShadow(
                                color: mood['color'].withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [mood['color'], mood['color'].withOpacity(0.7)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  mood['icon'],
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              if (value > 0.9) ...[
                                const SizedBox(height: 12),
                                Text(
                                  mood['label'],
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: ThemeColors.getTextColor(context).withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}