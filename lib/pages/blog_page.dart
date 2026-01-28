import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import '../core/theme_colors.dart';
import '../services/theme_service.dart';
import 'package:provider/provider.dart';

class BlogPage extends StatelessWidget {
  const BlogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, _) {
        return Scaffold(
          backgroundColor: ThemeColors.getBackgroundColor(context),
          appBar: AppBar(
            backgroundColor: ThemeColors.getBackgroundColor(context),
            elevation: 0,
            title: Text(
              'Blog & Éducation',
              style: TextStyle(
                color: ThemeColors.getTextColor(context),
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Découvrez nos articles',
                    style: TextStyle(
                      color: ThemeColors.getSecondaryTextColor(context),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildArticleCard(
                    context,
                    themeService,
                    'Comprendre votre cycle menstruel',
                    'Les bases de la santé féminine et comment bien suivre votre cycle',
                    'Santé',
                    const Color(0xFFE91E63),
                    IconlyBold.heart,
                  ),
                  const SizedBox(height: 16),
                  _buildArticleCard(
                    context,
                    themeService,
                    'Nutrition et bien-être pendant les règles',
                    'Les aliments qui aident à réduire les symptômes et améliorer votre bien-être',
                    'Nutrition',
                    const Color(0xFF4CAF50),
                    IconlyBold.document,
                  ),
                  const SizedBox(height: 16),
                  _buildArticleCard(
                    context,
                    themeService,
                    'Briser les tabous autour des règles',
                    'Parler ouvertement de la santé menstruelle et déconstruire les préjugés',
                    'Société',
                    const Color(0xFF9C27B0),
                    IconlyBold.chat,
                  ),
                  const SizedBox(height: 16),
                  _buildArticleCard(
                    context,
                    themeService,
                    'Santé reproductive et contraception',
                    'Informations importantes sur la contraception et la santé reproductive',
                    'Santé',
                    const Color(0xFF2196F3),
                    IconlyBold.add_user,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildArticleCard(
    BuildContext context,
    ThemeService themeService,
    String title,
    String description,
    String category,
    Color color,
    IconData icon,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArticleDetailPage(
              title: title,
              description: description,
              category: category,
              color: color,
              icon: icon,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: ThemeColors.getCardColor(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: ThemeColors.getBorderColor(context),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    category,
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                color: ThemeColors.getTextColor(context),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                color: ThemeColors.getSecondaryTextColor(context),
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  'Lire l\'article',
                  style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(IconlyLight.arrow_right_2, color: color, size: 16),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ArticleDetailPage extends StatelessWidget {
  final String title;
  final String description;
  final String category;
  final Color color;
  final IconData icon;

  const ArticleDetailPage({
    super.key,
    required this.title,
    required this.description,
    required this.category,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.getBackgroundColor(context),
      appBar: AppBar(
        backgroundColor: ThemeColors.getBackgroundColor(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            IconlyLight.arrow_left_2,
            color: ThemeColors.getTextColor(context),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Article',
          style: TextStyle(
            color: ThemeColors.getTextColor(context),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête de l'article
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color.withOpacity(0.1),
                    color.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: color.withOpacity(0.2),
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
                          color: color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(icon, color: color, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          category,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    title,
                    style: TextStyle(
                      color: ThemeColors.getTextColor(context),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    description,
                    style: TextStyle(
                      color: ThemeColors.getSecondaryTextColor(context),
                      fontSize: 16,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            _buildParagraph(
              context,
              'Introduction',
              'La santé menstruelle est un aspect fondamental du bien-être des femmes. Comprendre son cycle menstruel permet de mieux gérer sa santé reproductive et de détecter d\'éventuels problèmes de santé.',
            ),
            _buildParagraph(
              context,
              'Les bases du cycle menstruel',
              'Le cycle menstruel dure généralement 28 jours, mais peut varier entre 21 et 35 jours. Il se compose de plusieurs phases : la phase menstruelle, la phase folliculaire, l\'ovulation et la phase lutéale.',
            ),
            _buildParagraph(
              context,
              'Conseils pratiques',
              'Pour bien suivre votre cycle, notez régulièrement vos symptômes, vos humeurs et vos observations. Cela vous aidera à mieux comprendre votre corps et à anticiper les changements.',
            ),
            _buildParagraph(
              context,
              'Conclusion',
              'Prendre soin de sa santé menstruelle, c\'est prendre soin de soi. N\'hésitez pas à consulter un professionnel de santé si vous avez des questions ou des préoccupations.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParagraph(BuildContext context, String subtitle, String content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            subtitle,
            style: TextStyle(
              color: ThemeColors.getTextColor(context),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              color: ThemeColors.getSecondaryTextColor(context),
              fontSize: 16,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}


