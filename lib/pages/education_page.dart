import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme_colors.dart';
import '../services/blog_service.dart';

class EducationPage extends StatefulWidget {
  const EducationPage({super.key});

  @override
  State<EducationPage> createState() => _EducationPageState();
}

class _EducationPageState extends State<EducationPage> {
  List<Map<String, dynamic>> _articles = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAndRefreshBlog();
  }

  Future<void> _loadAndRefreshBlog() async {
    // Charger ce qu'on a déjà
    setState(() {
      _articles = BlogService.getAllArticles();
    });

    // Vérifier si on doit générer un nouveau blog
    if (await BlogService.shouldGenerateNewBlog()) {
      setState(() => _isLoading = true);
      await BlogService.generateDailyBlog();
      if (mounted) {
        setState(() {
          _articles = BlogService.getAllArticles();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.getBackgroundColor(context),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              title: Text(
                'Éducation & Blog',
                style: TextStyle(
                  color: ThemeColors.getTextColor(context),
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(
                    'Le Blog d\'AIDA',
                    'Ton conseil personnalisé du jour',
                  ),
                  const SizedBox(height: 16),

                  if (_isLoading && _articles.isEmpty)
                    _buildLoadingCard()
                  else if (_articles.isNotEmpty)
                    _buildFeaturedBlogCard(_articles.first)
                  else
                    const SizedBox.shrink(),

                  const SizedBox(height: 32),
                  _buildSectionHeader(
                    'Guides Essentiels',
                    'Tout savoir sur ta santé',
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildGuideCard(
                  icon: IconlyBold.heart,
                  title: 'Comprendre ton cycle',
                  color: ThemeColors.getPeriodColor(context),
                  content: _getCycleContent(),
                ),
                const SizedBox(height: 16),
                _buildGuideCard(
                  icon: IconlyBold.activity,
                  title: 'Les phases du cycle',
                  color: ThemeColors.getSecondaryActionColor(context),
                  content: _getPhasesContent(),
                ),
                const SizedBox(height: 16),
                _buildGuideCard(
                  icon: IconlyBold.chart,
                  title: 'Fertilité & Ovulation',
                  color: ThemeColors.getFertilityColor(context),
                  content: _getFertilityContent(),
                ).animate().fade().slideX(),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: ThemeColors.getTextColor(context),
          ),
        ),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: ThemeColors.getSecondaryTextColor(context),
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedBlogCard(Map<String, dynamic> article) {
    return GestureDetector(
      onTap: () => _showArticleDetail(article),
      child:
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ThemeColors.getPrimaryColor(context),
                  ThemeColors.getPrimaryColor(context).withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: ThemeColors.getPrimaryColor(context).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'ARTICLE DU JOUR',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  article['title'] ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  article['summary'] ?? '',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Text(
                      'Lire l\'article',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      IconlyLight.arrow_right,
                      color: Colors.white,
                      size: 16,
                    ),
                  ],
                ),
              ],
            ),
          ).animate().scale(
            delay: 200.ms,
            duration: 400.ms,
            curve: Curves.easeOutBack,
          ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: ThemeColors.getCardColor(context),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'AIDA prépare ton blog...',
              style: TextStyle(
                color: ThemeColors.getSecondaryTextColor(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuideCard({
    required IconData icon,
    required String title,
    required Color color,
    required String content,
  }) {
    return GestureDetector(
      onTap: () => _showGuideDetail(title, content),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: ThemeColors.getCardColor(context),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: ThemeColors.getBorderColor(context).withOpacity(0.5),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: ThemeColors.getTextColor(context),
                ),
              ),
            ),
            const Icon(IconlyLight.arrow_right_2, color: Colors.grey, size: 18),
          ],
        ),
      ),
    );
  }

  void _showArticleDetail(Map<String, dynamic> article) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: ThemeColors.getBackgroundColor(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(30),
                children: [
                  Text(
                    article['title'] ?? '',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: ThemeColors.getTextColor(context),
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: ThemeColors.getPrimaryColor(context),
                        child: const Icon(
                          IconlyBold.discovery,
                          size: 12,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Par AIDA Coach',
                        style: TextStyle(
                          color: ThemeColors.getSecondaryTextColor(context),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  _buildRichContent(article['content'] ?? ''),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Parser pour mettre en évidence les mots-clés (entre **)
  Widget _buildRichContent(String text) {
    final List<TextSpan> spans = [];
    final RegExp regExp = RegExp(r'\*\*(.*?)\*\*');
    int lastMatchEnd = 0;

    for (final Match match in regExp.allMatches(text)) {
      if (match.start > lastMatchEnd) {
        spans.add(
          TextSpan(
            text: text.substring(lastMatchEnd, match.start),
            style: TextStyle(
              color: ThemeColors.getTextColor(context),
              fontSize: 17,
              height: 1.6,
            ),
          ),
        );
      }
      spans.add(
        TextSpan(
          text: match.group(1),
          style: TextStyle(
            color: ThemeColors.getPrimaryColor(context),
            fontSize: 18,
            fontWeight: FontWeight.w900,
            backgroundColor: ThemeColors.getPrimaryColor(
              context,
            ).withOpacity(0.1),
          ),
        ),
      );
      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < text.length) {
      spans.add(
        TextSpan(
          text: text.substring(lastMatchEnd),
          style: TextStyle(
            color: ThemeColors.getTextColor(context),
            fontSize: 17,
            height: 1.6,
          ),
        ),
      );
    }

    return RichText(text: TextSpan(children: spans));
  }

  void _showGuideDetail(String title, String content) {
    // Réutilisation du design modal existant
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: ThemeColors.getBackgroundColor(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    content,
                    style: const TextStyle(fontSize: 16, height: 1.6),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Contenus statiques pour les guides (conservés de l'ancienne version)
  String _getCycleContent() =>
      'Le cycle menstruel dure généralement entre 21 et 35 jours...';
  String _getPhasesContent() => '1. Menstruation, 2. Phase folliculaire...';
  String _getFertilityContent() =>
      "L'ovulation se produit généralement 14 jours avant...";
}
