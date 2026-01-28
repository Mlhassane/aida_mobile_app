// import 'package:aida/page/BarredeNavigation.dart';
// import 'package:aida/page/HomePage.dart';
// import 'package:aida/page/journalintime.dart';
// import 'package:aida/page/onboarding.dart';
// import 'package:aida/page/calendar.dart';
// import 'package:aida/page/history.dart';
// import 'package:flutter/material.dart';
// import 'package:iconly/iconly.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:ui';
// import 'providers/notification_provider.dart';
// import 'widgets/notification_sheets.dart';
// import 'widgets/notification_template_manager.dart';
// // import 'page/notification_test_page.dart'; // Fichier supprimé

// // Couleurs de thème adaptées pour Aida
// const List<Color> aidaThemeColors = [
//   Color(0xFFE91E63), // Pink principal
//   Color(0xFF9C27B0), // Purple
//   Color(0xFF2196F3), // Blue
//   Color(0xFF4CAF50), // Green
//   Color(0xFFFF5722), // Deep Orange
//   Color(0xFF3F51B5), // Indigo
//   Color(0xFF009688), // Teal
//   Color(0xFF795548), // Brown
//   Color(0xFF607D8B), // Blue Grey
//   Color(0xFFFFC107), // Amber
// ];

// class AidaThemeProvider with ChangeNotifier {
//   Color _seedColor = aidaThemeColors[0]; // Pink par défaut
//   ThemeMode _themeMode = ThemeMode.light;

//   Color get seedColor => _seedColor;
//   ThemeMode get themeMode => _themeMode;

//   AidaThemeProvider() {
//     _loadPreferences();
//   }

//   Future<void> _loadPreferences() async {
//     final prefs = await SharedPreferences.getInstance();
//     final savedColor = prefs.getInt('aidaThemeColor');
//     final savedMode = prefs.getString('aidaThemeMode');
//     if (savedColor != null) {
//       _seedColor = Color(savedColor);
//     }
//     if (savedMode != null) {
//       _themeMode = ThemeMode.values.firstWhere(
//         (e) => e.toString() == savedMode,
//         orElse: () => ThemeMode.light,
//       );
//     }
//     notifyListeners();
//   }

//   Future<void> setSeedColor(Color color) async {
//     _seedColor = color;
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setInt('aidaThemeColor', color.value);
//     notifyListeners();
//   }

//   Future<void> setThemeMode(ThemeMode mode) async {
//     _themeMode = mode;
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('aidaThemeMode', mode.toString());
//     notifyListeners();
//   }
// }

// @override
// Widget build(BuildContext context) {
//   return Consumer<AidaThemeProvider>(
//     builder: (context, themeProvider, child) {
//       return Scaffold(
//         backgroundColor: Colors.white,
//         body: SafeArea(
//           child: Padding(
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               children: [
//                 // Header
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       'Profil',
//                       style: TextStyle(
//                         color: Colors.grey.shade800,
//                         fontSize: 28,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     Container(
//                       padding: EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         color: Colors.purple.shade50,
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Icon(
//                         IconlyLight.profile,
//                         color: Colors.purple.shade600,
//                         size: 24,
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 30),

//                 // Profil utilisateur
//                 Container(
//                   padding: EdgeInsets.all(20),
//                   decoration: BoxDecoration(
//                     color: Colors.grey.shade50,
//                     borderRadius: BorderRadius.circular(16),
//                     border: Border.all(color: Colors.grey.shade200),
//                   ),
//                   child: Row(
//                     children: [
//                       CircleAvatar(
//                         radius: 30,
//                         backgroundColor: themeProvider.seedColor,
//                         child: Icon(
//                           IconlyBold.profile,
//                           color: Colors.white,
//                           size: 30,
//                         ),
//                       ),
//                       SizedBox(width: 16),
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Utilisatrice Aida',
//                             style: TextStyle(
//                               color: Colors.grey.shade800,
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           Text(
//                             'Vos données restent privées',
//                             style: TextStyle(
//                               color: Colors.grey.shade600,
//                               fontSize: 14,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//                 SizedBox(height: 30),

//                 // Options de paramètres
//                 Expanded(
//                   child: ListView(
//                     children: [
//                       _buildProfileOption(
//                         IconlyLight.lock,
//                         'Confidentialité',
//                         'Vos données sont sécurisées',
//                       ),
//                       _buildProfileOption(
//                         IconlyLight.setting,
//                         'Paramètres',
//                         'Personnalisez votre expérience',
//                       ),
//                       _buildProfileOption(
//                         IconlyLight.play,
//                         'Thème',
//                         'Changer la couleur de l\'application',
//                         onTap: () => _showThemeSelector(context, themeProvider),
//                       ),
//                       _buildProfileOption(
//                         IconlyLight.info_circle,
//                         'À propos d\'Aida',
//                         'Notre mission pour les femmes africaines',
//                       ),
//                       _buildProfileOption(
//                         IconlyLight.logout,
//                         'Déconnexion',
//                         'Se déconnecter en toute sécurité',
//                         isLogout: true,
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       );
//     },
//   );
// }

// Widget _buildProfileOption(
//   IconData icon,
//   String title,
//   String subtitle, {
//   bool isLogout = false,
//   VoidCallback? onTap,
// }) {
//   return Container(
//     margin: EdgeInsets.only(bottom: 12),
//     padding: EdgeInsets.all(16),
//     decoration: BoxDecoration(
//       color: Colors.grey.shade50,
//       borderRadius: BorderRadius.circular(12),
//       border: Border.all(color: Colors.grey.shade200),
//     ),
//     child: InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(12),
//       child: Row(
//         children: [
//           Icon(
//             icon,
//             color: isLogout ? Colors.red : Colors.grey.shade600,
//             size: 24,
//           ),
//           SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: TextStyle(
//                     color: isLogout ? Colors.red : Colors.grey.shade800,
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 Text(
//                   subtitle,
//                   style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
//                 ),
//               ],
//             ),
//           ),
//           Icon(
//             IconlyLight.arrow_right_2,
//             color: Colors.grey.shade400,
//             size: 20,
//           ),
//         ],
//       ),
//     ),
//   );
// }

// void _showThemeSelector(BuildContext context, AidaThemeProvider themeProvider) {
//   showModalBottomSheet(
//     context: context,
//     shape: RoundedRectangleBorder(
//       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//     ),
//     builder: (context) => Container(
//       padding: EdgeInsets.all(20),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Choisir une couleur',
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//               color: Colors.grey.shade800,
//             ),
//           ),
//           SizedBox(height: 20),
//           GridView.builder(
//             shrinkWrap: true,
//             gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 5,
//               crossAxisSpacing: 10,
//               mainAxisSpacing: 10,
//             ),
//             itemCount: aidaThemeColors.length,
//             itemBuilder: (context, index) {
//               final color = aidaThemeColors[index];
//               final isSelected = themeProvider.seedColor == color;

//               return GestureDetector(
//                 onTap: () {
//                   themeProvider.setSeedColor(color);
//                   Navigator.pop(context);
//                 },
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: color,
//                     shape: BoxShape.circle,
//                     border: isSelected
//                         ? Border.all(color: Colors.white, width: 3)
//                         : null,
//                     boxShadow: isSelected
//                         ? [
//                             BoxShadow(
//                               color: color.withOpacity(0.5),
//                               blurRadius: 10,
//                               spreadRadius: 2,
//                             ),
//                           ]
//                         : null,
//                   ),
//                   child: isSelected
//                       ? Icon(Icons.check, color: Colors.white, size: 20)
//                       : null,
//                 ),
//               );
//             },
//           ),
//           SizedBox(height: 20),
//         ],
//       ),
//     ),
//   );
// }

// class AidaApp extends StatelessWidget {
//   const AidaApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => AidaThemeProvider()),
//         ChangeNotifierProvider(create: (_) => NotificationProvider()),
//       ],
//       child: Consumer<AidaThemeProvider>(
//         builder: (context, themeProvider, child) {
//           return MaterialApp(
//             title: 'Aida - Suivi Menstruel',
//             debugShowCheckedModeBanner: false,
//             theme: ThemeData(
//               primarySwatch: Colors.blue,
//               scaffoldBackgroundColor: Colors.white,
//               colorScheme: ColorScheme.fromSeed(
//                 seedColor: themeProvider.seedColor,
//                 brightness: Brightness.light,
//               ),
//               useMaterial3: true,
//             ),
//             home: const AppEntryPoint(),
//             routes: {
//               '/main': (context) => HomePage(),
//               '/onboarding': (context) =>  OnboardingPage(),
//               '/calendar': (context) => const CalendarPage(),
//               '/journal': (context) => const JournalApp(),
//               '/history': (context) => const HistoryPage(),
//               // '/tracking': (context) => const CycleTrackingPage(),
//             },
//           );
//         },
//       ),
//     );
//   }
// }

// class AppEntryPoint extends StatefulWidget {
//   const AppEntryPoint({super.key});

//   @override
//   State<AppEntryPoint> createState() => _AppEntryPointState();
// }

// class _AppEntryPointState extends State<AppEntryPoint> {
//   bool _isLoading = true;
//   bool _hasCompletedOnboarding = false;
//   bool _hasInitialized = false;

//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     // Initialiser l'app après que le widget soit monté et que les dépendances soient disponibles
//     if (!_hasInitialized && _isLoading) {
//       _hasInitialized = true;
//       _initializeApp();
//     }
//   }

//   Future<void> _initializeApp() async {
//     // Initialiser le service de notifications
//     // Utiliser didChangeDependencies garantit que Provider est disponible
//     final notificationProvider = Provider.of<NotificationProvider>(
//       context,
//       listen: false,
//     );
//     await notificationProvider.initialize();

//     // Vérifier le statut d'onboarding
//     await _checkOnboardingStatus();
//   }

//   Future<void> _checkOnboardingStatus() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final completed = prefs.getBool('onboarding_completed') ?? false;

//       setState(() {
//         _hasCompletedOnboarding = completed;
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _hasCompletedOnboarding = false;
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) {
//       return const Scaffold(body: Center(child: CircularProgressIndicator()));
//     }

//     if (_hasCompletedOnboarding) {
//       return Navbar();
//     } else {
//       return OnboardingPage();
//     }
//   }
// }

// // Page Blog - Articles et éducation
// class BlogPage extends StatelessWidget {
//   const BlogPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<AidaThemeProvider>(
//       builder: (context, themeProvider, child) {
//         return Scaffold(
//           backgroundColor: Colors.white,
//           body: SafeArea(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.all(20),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Header
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Blog & Éducation',
//                             style: TextStyle(
//                               color: Colors.grey.shade800,
//                               fontSize: 28,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           Text(
//                             'Découvrez nos articles',
//                             style: TextStyle(
//                               color: Colors.grey.shade600,
//                               fontSize: 16,
//                             ),
//                           ),
//                         ],
//                       ),
//                       Container(
//                         padding: EdgeInsets.all(12),
//                         decoration: BoxDecoration(
//                           color: themeProvider.seedColor.withOpacity(0.1),
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Icon(
//                           IconlyBold.document,
//                           color: themeProvider.seedColor,
//                           size: 24,
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 30),

//                   // Articles
//                   _buildArticleCard(
//                     context,
//                     'Comprendre votre cycle menstruel',
//                     'Les bases de la santé féminine et comment bien suivre votre cycle',
//                     'Santé',
//                     Colors.pink,
//                     IconlyBold.heart,
//                   ),
//                   _buildArticleCard(
//                     context,
//                     'Nutrition et bien-être pendant les règles',
//                     'Les aliments qui aident à réduire les symptômes et améliorer votre bien-être',
//                     'Nutrition',
//                     Colors.green,
//                     IconlyBold.document,
//                   ),
//                   _buildArticleCard(
//                     context,
//                     'Briser les tabous autour des règles',
//                     'Parler ouvertement de la santé menstruelle et déconstruire les préjugés',
//                     'Société',
//                     Colors.purple,
//                     IconlyBold.chat,
//                   ),
//                   _buildArticleCard(
//                     context,
//                     'Santé reproductive et contraception',
//                     'Informations importantes sur la contraception et la santé reproductive',
//                     'Santé',
//                     Colors.blue,
//                     IconlyBold.add_user,
//                   ),
//                   SizedBox(height: 75),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildArticleCard(
//     BuildContext context,
//     String title,
//     String description,
//     String category,
//     Color color,
//     IconData icon,
//   ) {
//     return GestureDetector(
//       onTap: () =>
//           _openArticle(context, title, description, category, color, icon),
//       child: Container(
//         margin: EdgeInsets.only(bottom: 16),
//         padding: EdgeInsets.all(20),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(color: Colors.grey.shade200, width: 1),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 10,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Container(
//                   padding: EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: color.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Icon(icon, color: color, size: 20),
//                 ),
//                 SizedBox(width: 12),
//                 Container(
//                   padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                   decoration: BoxDecoration(
//                     color: color.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Text(
//                     category,
//                     style: TextStyle(
//                       color: color,
//                       fontSize: 12,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 12),
//             Text(
//               title,
//               style: TextStyle(
//                 color: Colors.grey.shade800,
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             SizedBox(height: 8),
//             Text(
//               description,
//               style: TextStyle(
//                 color: Colors.grey.shade600,
//                 fontSize: 14,
//                 height: 1.5,
//               ),
//             ),
//             SizedBox(height: 12),
//             Row(
//               children: [
//                 Text(
//                   'Lire l\'article',
//                   style: TextStyle(
//                     color: color,
//                     fontSize: 14,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 SizedBox(width: 8),
//                 Icon(IconlyLight.arrow_right_2, color: color, size: 16),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _openArticle(
//     BuildContext context,
//     String title,
//     String description,
//     String category,
//     Color color,
//     IconData icon,
//   ) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => ArticleDetailPage(
//           title: title,
//           description: description,
//           category: category,
//           color: color,
//           icon: icon,
//         ),
//       ),
//     );
//   }
// }

// // Page de détail des articles
// class ArticleDetailPage extends StatelessWidget {
//   final String title;
//   final String description;
//   final String category;
//   final Color color;
//   final IconData icon;

//   const ArticleDetailPage({
//     super.key,
//     required this.title,
//     required this.description,
//     required this.category,
//     required this.color,
//     required this.icon,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Column(
//           children: [
//             // Header avec bouton retour
//             Container(
//               padding: EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 border: Border(
//                   bottom: BorderSide(color: Colors.grey.shade200, width: 1),
//                 ),
//               ),
//               child: Row(
//                 children: [
//                   GestureDetector(
//                     onTap: () => Navigator.pop(context),
//                     child: Container(
//                       padding: EdgeInsets.all(8),
//                       decoration: BoxDecoration(
//                         color: Colors.grey.shade100,
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Icon(
//                         IconlyLight.arrow_left_2,
//                         color: Colors.grey.shade600,
//                         size: 20,
//                       ),
//                     ),
//                   ),
//                   SizedBox(width: 16),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Article',
//                           style: TextStyle(
//                             color: Colors.grey.shade600,
//                             fontSize: 14,
//                           ),
//                         ),
//                         Text(
//                           'Blog & Éducation',
//                           style: TextStyle(
//                             color: Colors.grey.shade800,
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Container(
//                     padding: EdgeInsets.all(8),
//                     decoration: BoxDecoration(
//                       color: color.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Icon(IconlyBold.bookmark, color: color, size: 20),
//                   ),
//                 ],
//               ),
//             ),

//             // Contenu de l'article
//             Expanded(
//               child: SingleChildScrollView(
//                 padding: EdgeInsets.all(20),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // En-tête de l'article
//                     Container(
//                       padding: EdgeInsets.all(24),
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           begin: Alignment.topLeft,
//                           end: Alignment.bottomRight,
//                           colors: [
//                             color.withOpacity(0.1),
//                             color.withOpacity(0.05),
//                           ],
//                         ),
//                         borderRadius: BorderRadius.circular(20),
//                         border: Border.all(
//                           color: color.withOpacity(0.2),
//                           width: 1,
//                         ),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             children: [
//                               Container(
//                                 padding: EdgeInsets.all(12),
//                                 decoration: BoxDecoration(
//                                   color: color.withOpacity(0.2),
//                                   borderRadius: BorderRadius.circular(12),
//                                 ),
//                                 child: Icon(icon, color: color, size: 24),
//                               ),
//                               SizedBox(width: 16),
//                               Container(
//                                 padding: EdgeInsets.symmetric(
//                                   horizontal: 12,
//                                   vertical: 6,
//                                 ),
//                                 decoration: BoxDecoration(
//                                   color: color,
//                                   borderRadius: BorderRadius.circular(16),
//                                 ),
//                                 child: Text(
//                                   category,
//                                   style: TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 12,
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           SizedBox(height: 20),
//                           Text(
//                             title,
//                             style: TextStyle(
//                               color: Colors.grey.shade800,
//                               fontSize: 24,
//                               fontWeight: FontWeight.bold,
//                               height: 1.3,
//                             ),
//                           ),
//                           SizedBox(height: 12),
//                           Text(
//                             description,
//                             style: TextStyle(
//                               color: Colors.grey.shade600,
//                               fontSize: 16,
//                               height: 1.6,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),

//                     SizedBox(height: 30),

//                     // Contenu de l'article
//                     _buildArticleContent(),

//                     SizedBox(height: 30),

//                     // Section "Articles similaires"
//                     _buildSimilarArticles(),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildArticleContent() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Contenu de l\'article',
//           style: TextStyle(
//             color: Colors.grey.shade800,
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         SizedBox(height: 16),

//         // Paragraphes de l'article
//         _buildParagraph(
//           'Introduction',
//           'La santé menstruelle est un aspect fondamental du bien-être des femmes. Comprendre son cycle menstruel permet de mieux gérer sa santé reproductive et de détecter d\'éventuels problèmes de santé.',
//         ),

//         _buildParagraph(
//           'Les bases du cycle menstruel',
//           'Le cycle menstruel dure généralement 28 jours, mais peut varier entre 21 et 35 jours. Il se compose de plusieurs phases : la phase menstruelle, la phase folliculaire, l\'ovulation et la phase lutéale.',
//         ),

//         _buildParagraph(
//           'Conseils pratiques',
//           'Pour bien suivre votre cycle, notez régulièrement vos symptômes, vos humeurs et vos observations. Cela vous aidera à mieux comprendre votre corps et à anticiper les changements.',
//         ),

//         _buildParagraph(
//           'Conclusion',
//           'Prendre soin de sa santé menstruelle, c\'est prendre soin de soi. N\'hésitez pas à consulter un professionnel de santé si vous avez des questions ou des préoccupations.',
//         ),
//       ],
//     );
//   }

//   Widget _buildParagraph(String subtitle, String content) {
//     return Container(
//       margin: EdgeInsets.only(bottom: 24),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             subtitle,
//             style: TextStyle(
//               color: Colors.grey.shade800,
//               fontSize: 18,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           SizedBox(height: 8),
//           Text(
//             content,
//             style: TextStyle(
//               color: Colors.grey.shade700,
//               fontSize: 16,
//               height: 1.6,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSimilarArticles() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Articles similaires',
//           style: TextStyle(
//             color: Colors.grey.shade800,
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         SizedBox(height: 16),

//         Container(
//           padding: EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             color: Colors.grey.shade50,
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(color: Colors.grey.shade200, width: 1),
//           ),
//           child: Column(
//             children: [
//               _buildSimilarArticleItem(
//                 'Nutrition et cycle menstruel',
//                 'Découvrez les aliments qui soutiennent votre bien-être',
//                 Colors.green,
//               ),
//               SizedBox(height: 12),
//               _buildSimilarArticleItem(
//                 'Gestion du stress et règles',
//                 'Techniques pour réduire le stress pendant vos règles',
//                 Colors.blue,
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildSimilarArticleItem(
//     String title,
//     String description,
//     Color color,
//   ) {
//     return Container(
//       padding: EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey.shade200, width: 1),
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 8,
//             height: 8,
//             decoration: BoxDecoration(color: color, shape: BoxShape.circle),
//           ),
//           SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: TextStyle(
//                     color: Colors.grey.shade800,
//                     fontSize: 14,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 SizedBox(height: 4),
//                 Text(
//                   description,
//                   style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
//                 ),
//               ],
//             ),
//           ),
//           Icon(
//             IconlyLight.arrow_right_2,
//             color: Colors.grey.shade400,
//             size: 16,
//           ),
//         ],
//       ),
//     );
//   }
// }

// // Page Chat - Conversation avec l'IA
// class ChatPage extends StatefulWidget {
//   const ChatPage({super.key});

//   @override
//   State<ChatPage> createState() => _ChatPageState();
// }

// class _ChatPageState extends State<ChatPage> {
//   final TextEditingController _messageController = TextEditingController();
//   final List<ChatMessage> _messages = [
//     ChatMessage(
//       text:
//           "Bonjour ! Je suis Aida, votre assistante IA pour la santé menstruelle. Comment puis-je vous aider aujourd'hui ?",
//       isUser: false,
//       timestamp: DateTime.now(),
//     ),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<AidaThemeProvider>(
//       builder: (context, themeProvider, child) {
//         return Scaffold(
//           backgroundColor: Colors.white,
//           body: SafeArea(
//             child: Column(
//               children: [
//                 // Header
//                 Container(
//                   padding: EdgeInsets.all(20),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     border: Border(
//                       bottom: BorderSide(color: Colors.grey.shade200, width: 1),
//                     ),
//                   ),
//                   child: Row(
//                     children: [
//                       Container(
//                         padding: EdgeInsets.all(12),
//                         decoration: BoxDecoration(
//                           gradient: LinearGradient(
//                             begin: Alignment.topLeft,
//                             end: Alignment.bottomRight,
//                             colors: [
//                               themeProvider.seedColor,
//                               themeProvider.seedColor.withOpacity(0.8),
//                             ],
//                           ),
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Icon(
//                           IconlyBold.chat,
//                           color: Colors.white,
//                           size: 24,
//                         ),
//                       ),
//                       SizedBox(width: 16),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'Aida IA',
//                               style: TextStyle(
//                                 color: Colors.grey.shade800,
//                                 fontSize: 20,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             Text(
//                               'En ligne',
//                               style: TextStyle(
//                                 color: Colors.green.shade600,
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 // Messages
//                 Expanded(
//                   child: ListView.builder(
//                     padding: EdgeInsets.all(20),
//                     itemCount: _messages.length,
//                     itemBuilder: (context, index) {
//                       final message = _messages[index];
//                       return _buildMessageBubble(message, themeProvider);
//                     },
//                   ),
//                 ),

//                 // Input
//                 Container(
//                   padding: EdgeInsets.all(20),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     border: Border(
//                       top: BorderSide(color: Colors.grey.shade200, width: 1),
//                     ),
//                   ),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: Container(
//                           padding: EdgeInsets.symmetric(
//                             horizontal: 16,
//                             vertical: 12,
//                           ),
//                           decoration: BoxDecoration(
//                             color: Colors.grey.shade50,
//                             borderRadius: BorderRadius.circular(25),
//                             border: Border.all(
//                               color: Colors.grey.shade200,
//                               width: 1,
//                             ),
//                           ),
//                           child: TextField(
//                             controller: _messageController,
//                             decoration: InputDecoration(
//                               hintText: 'Tapez votre message...',
//                               hintStyle: TextStyle(color: Colors.grey.shade500),
//                               border: InputBorder.none,
//                             ),
//                             maxLines: null,
//                           ),
//                         ),
//                       ),
//                       SizedBox(width: 12),
//                       GestureDetector(
//                         onTap: _sendMessage,
//                         child: Container(
//                           padding: EdgeInsets.all(12),
//                           decoration: BoxDecoration(
//                             gradient: LinearGradient(
//                               begin: Alignment.topLeft,
//                               end: Alignment.bottomRight,
//                               colors: [
//                                 themeProvider.seedColor,
//                                 themeProvider.seedColor.withOpacity(0.8),
//                               ],
//                             ),
//                             borderRadius: BorderRadius.circular(25),
//                           ),
//                           child: Icon(
//                             IconlyBold.send,
//                             color: Colors.white,
//                             size: 20,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 SizedBox(height: 75),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildMessageBubble(
//     ChatMessage message,
//     AidaThemeProvider themeProvider,
//   ) {
//     return Container(
//       margin: EdgeInsets.only(bottom: 16),
//       child: Row(
//         mainAxisAlignment: message.isUser
//             ? MainAxisAlignment.end
//             : MainAxisAlignment.start,
//         children: [
//           if (!message.isUser) ...[
//             Container(
//               width: 32,
//               height: 32,
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                   colors: [
//                     themeProvider.seedColor,
//                     themeProvider.seedColor.withOpacity(0.8),
//                   ],
//                 ),
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               child: Icon(IconlyBold.chat, color: Colors.white, size: 16),
//             ),
//             SizedBox(width: 8),
//           ],
//           Flexible(
//             child: Container(
//               padding: EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: message.isUser
//                     ? themeProvider.seedColor
//                     : Colors.grey.shade100,
//                 borderRadius: BorderRadius.circular(20),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.05),
//                     blurRadius: 8,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: Text(
//                 message.text,
//                 style: TextStyle(
//                   color: message.isUser ? Colors.white : Colors.grey.shade800,
//                   fontSize: 16,
//                 ),
//               ),
//             ),
//           ),
//           if (message.isUser) ...[
//             SizedBox(width: 8),
//             Container(
//               width: 32,
//               height: 32,
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade300,
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               child: Icon(
//                 IconlyBold.profile,
//                 color: Colors.grey.shade600,
//                 size: 16,
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }

//   void _sendMessage() {
//     if (_messageController.text.trim().isEmpty) return;

//     setState(() {
//       _messages.add(
//         ChatMessage(
//           text: _messageController.text.trim(),
//           isUser: true,
//           timestamp: DateTime.now(),
//         ),
//       );
//     });

//     _messageController.clear();

//     // Simuler une réponse de l'IA
//     Future.delayed(Duration(seconds: 1), () {
//       setState(() {
//         _messages.add(
//           ChatMessage(
//             text:
//                 "Merci pour votre message ! Je suis là pour vous aider avec vos questions sur la santé menstruelle. Pouvez-vous me donner plus de détails ?",
//             isUser: false,
//             timestamp: DateTime.now(),
//           ),
//         );
//       });
//     });
//   }
// }

// class ChatMessage {
//   final String text;
//   final bool isUser;
//   final DateTime timestamp;

//   ChatMessage({
//     required this.text,
//     required this.isUser,
//     required this.timestamp,
//   });
// }

// // Page Paramètres
// class SettingsPage extends StatelessWidget {
//   const SettingsPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<AidaThemeProvider>(
//       builder: (context, themeProvider, child) {
//         return Scaffold(
//           backgroundColor: Colors.white,
//           body: SafeArea(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.all(20),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Header
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Paramètres',
//                             style: TextStyle(
//                               color: Colors.grey.shade800,
//                               fontSize: 28,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           Text(
//                             'Personnalisez votre expérience',
//                             style: TextStyle(
//                               color: Colors.grey.shade600,
//                               fontSize: 16,
//                             ),
//                           ),
//                         ],
//                       ),
//                       Container(
//                         padding: EdgeInsets.all(12),
//                         decoration: BoxDecoration(
//                           color: themeProvider.seedColor.withOpacity(0.1),
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Icon(
//                           IconlyBold.setting,
//                           color: themeProvider.seedColor,
//                           size: 24,
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 30),

//                   // Section Profil
//                   _buildSectionTitle('Profil'),
//                   _buildSettingCard(
//                     IconlyBold.profile,
//                     'Mon Profil',
//                     'Gérez vos informations personnelles',
//                     Colors.blue,
//                     () {},
//                   ),
//                   _buildSettingCard(
//                     IconlyBold.lock,
//                     'Confidentialité',
//                     'Contrôlez vos données et votre vie privée',
//                     Colors.green,
//                     () {},
//                   ),

//                   SizedBox(height: 20),

//                   // Section Apparence
//                   _buildSectionTitle('Apparence'),
//                   _buildSettingCard(
//                     IconlyBold.play,
//                     'Thème',
//                     'Changer la couleur de l\'application',
//                     themeProvider.seedColor,
//                     () => _showThemeSelector(context, themeProvider),
//                   ),
//                   _buildSettingCard(
//                     Icons.dark_mode,
//                     'Mode Sombre',
//                     'Activer le mode sombre',
//                     Colors.purple,
//                     () {},
//                   ),

//                   SizedBox(height: 20),

//                   // Section Notifications
//                   _buildSectionTitle('Notifications'),
//                   _buildNotificationToggleCard(),
//                   _buildSettingCard(
//                     IconlyBold.notification,
//                     'Rappels de Cycle',
//                     'Gérer les notifications de cycle menstruel',
//                     Colors.orange,
//                     () => _showNotificationSettings(context),
//                   ),
//                   _buildSettingCard(
//                     IconlyBold.time_circle,
//                     'Rappels Personnalisés',
//                     'Créer vos propres rappels',
//                     Colors.teal,
//                     () => _showCustomReminders(context),
//                   ),
//                   _buildSettingCard(
//                     IconlyBold.setting,
//                     'Modèles de Notifications',
//                     'Gérer vos modèles de notifications',
//                     Colors.purple,
//                     () => _showNotificationTemplates(context),
//                   ),
//                   _buildSettingCard(
//                     IconlyBold.notification,
//                     'Test des Notifications',
//                     'Tester toutes les fonctionnalités de notification',
//                     Colors.orange,
//                     () => _showNotificationTest(context),
//                   ),

//                   SizedBox(height: 20),

//                   // Section Support
//                   _buildSectionTitle('Support'),
//                   _buildSettingCard(
//                     IconlyBold.info_circle,
//                     'À propos d\'Aida',
//                     'Notre mission pour les femmes africaines',
//                     Colors.indigo,
//                     () {},
//                   ),
//                   _buildSettingCard(
//                     IconlyBold.chat,
//                     'Support Client',
//                     'Contactez notre équipe',
//                     Colors.pink,
//                     () {},
//                   ),
//                   _buildSettingCard(
//                     IconlyBold.logout,
//                     'Déconnexion',
//                     'Se déconnecter en toute sécurité',
//                     Colors.red,
//                     () {},
//                   ),
//                   SizedBox(height: 75),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildSectionTitle(String title) {
//     return Padding(
//       padding: EdgeInsets.only(bottom: 16),
//       child: Text(
//         title,
//         style: TextStyle(
//           color: Colors.grey.shade800,
//           fontSize: 20,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     );
//   }

//   Widget _buildSettingCard(
//     IconData icon,
//     String title,
//     String subtitle,
//     Color color,
//     VoidCallback onTap,
//   ) {
//     return Container(
//       margin: EdgeInsets.only(bottom: 12),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           onTap: onTap,
//           borderRadius: BorderRadius.circular(16),
//           child: Container(
//             padding: EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(16),
//               border: Border.all(color: Colors.grey.shade200, width: 1),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.05),
//                   blurRadius: 10,
//                   offset: const Offset(0, 4),
//                 ),
//               ],
//             ),
//             child: Row(
//               children: [
//                 Container(
//                   padding: EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: color.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Icon(icon, color: color, size: 24),
//                 ),
//                 SizedBox(width: 16),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         title,
//                         style: TextStyle(
//                           color: Colors.grey.shade800,
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       SizedBox(height: 4),
//                       Text(
//                         subtitle,
//                         style: TextStyle(
//                           color: Colors.grey.shade600,
//                           fontSize: 14,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Icon(
//                   IconlyLight.arrow_right_2,
//                   color: Colors.grey.shade400,
//                   size: 20,
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   void _showThemeSelector(
//     BuildContext context,
//     AidaThemeProvider themeProvider,
//   ) {
//     showModalBottomSheet(
//       context: context,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) => Container(
//         padding: EdgeInsets.all(20),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Choisir une couleur',
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.grey.shade800,
//               ),
//             ),
//             SizedBox(height: 20),
//             GridView.builder(
//               shrinkWrap: true,
//               gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 5,
//                 crossAxisSpacing: 10,
//                 mainAxisSpacing: 10,
//               ),
//               itemCount: aidaThemeColors.length,
//               itemBuilder: (context, index) {
//                 final color = aidaThemeColors[index];
//                 final isSelected = themeProvider.seedColor == color;

//                 return GestureDetector(
//                   onTap: () {
//                     themeProvider.setSeedColor(color);
//                     Navigator.pop(context);
//                   },
//                   child: Container(
//                     decoration: BoxDecoration(
//                       color: color,
//                       shape: BoxShape.circle,
//                       border: isSelected
//                           ? Border.all(color: Colors.white, width: 3)
//                           : null,
//                       boxShadow: isSelected
//                           ? [
//                               BoxShadow(
//                                 color: color.withOpacity(0.5),
//                                 blurRadius: 10,
//                                 spreadRadius: 2,
//                               ),
//                             ]
//                           : null,
//                     ),
//                     child: isSelected
//                         ? Icon(Icons.check, color: Colors.white, size: 20)
//                         : null,
//                   ),
//                 );
//               },
//             ),
//             SizedBox(height: 20),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildNotificationToggleCard() {
//     return Consumer<NotificationProvider>(
//       builder: (context, notificationProvider, child) {
//         return Container(
//           margin: EdgeInsets.only(bottom: 12),
//           child: Material(
//             color: Colors.transparent,
//             child: InkWell(
//               onTap: () async {
//                 final success = await notificationProvider
//                     .toggleNotifications();
//                 if (!success) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text(
//                         'Impossible d\'activer les notifications. Vérifiez les permissions.',
//                       ),
//                       backgroundColor: Colors.red,
//                     ),
//                   );
//                 }
//               },
//               borderRadius: BorderRadius.circular(16),
//               child: Container(
//                 padding: EdgeInsets.all(20),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(16),
//                   border: Border.all(color: Colors.grey.shade200, width: 1),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.05),
//                       blurRadius: 10,
//                       offset: const Offset(0, 4),
//                     ),
//                   ],
//                 ),
//                 child: Row(
//                   children: [
//                     Container(
//                       padding: EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         color: notificationProvider.notificationsEnabled
//                             ? Colors.green.withOpacity(0.1)
//                             : Colors.grey.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Icon(
//                         IconlyBold.notification,
//                         color: notificationProvider.notificationsEnabled
//                             ? Colors.green
//                             : Colors.grey,
//                         size: 24,
//                       ),
//                     ),
//                     SizedBox(width: 16),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Notifications',
//                             style: TextStyle(
//                               color: Colors.grey.shade800,
//                               fontSize: 16,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                           SizedBox(height: 4),
//                           Text(
//                             notificationProvider.notificationsEnabled
//                                 ? 'Activées'
//                                 : 'Désactivées',
//                             style: TextStyle(
//                               color: notificationProvider.notificationsEnabled
//                                   ? Colors.green.shade600
//                                   : Colors.grey.shade600,
//                               fontSize: 14,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Switch(
//                       value: notificationProvider.notificationsEnabled,
//                       onChanged: (value) async {
//                         final success = await notificationProvider
//                             .toggleNotifications();
//                         if (!success) {
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             SnackBar(
//                               content: Text(
//                                 'Impossible d\'activer les notifications. Vérifiez les permissions.',
//                               ),
//                               backgroundColor: Colors.red,
//                             ),
//                           );
//                         }
//                       },
//                       activeThumbColor: Colors.green,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   void _showNotificationSettings(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) => NotificationSettingsSheet(),
//     );
//   }

//   void _showCustomReminders(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) => CustomRemindersSheet(),
//     );
//   }

//   void _showNotificationTemplates(BuildContext context) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => const NotificationTemplateManager(),
//       ),
//     );
//   }

//   void _showNotificationTest(BuildContext context) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => const Scaffold(
//         // appBar: AppBar(title: Text('Notifications')),
//         body: Center(child: Text('Page de notifications - À implémenter')),
//       )),
//     );
//   }
// }

// // Page Journal Intime - Espace Privé
// // class JournalPage extends StatefulWidget {
// //   const JournalPage({Key? key}) : super(key: key);

// //   @override
// //   State<JournalPage> createState() => _JournalPageState();
// // }

// // class _JournalPageState extends State<JournalPage> {
// //   final TextEditingController _noteController = TextEditingController();
// //   final List<JournalEntry> _entries = [];

// //   @override
// //   Widget build(BuildContext context) {
// //     return Consumer<AidaThemeProvider>(
// //       builder: (context, themeProvider, child) {
// //         return Scaffold(
// //           backgroundColor: Colors.white,
// //           body: SafeArea(
// //             child: Column(
// //               children: [
// //                 // Header avec verrouillage
// //                 Container(
// //                   padding: EdgeInsets.all(20),
// //                   decoration: BoxDecoration(
// //                     color: Colors.white,
// //                     border: Border(
// //                       bottom: BorderSide(color: Colors.grey.shade200, width: 1),
// //                     ),
// //                   ),
// //                   child: Row(
// //                     children: [
// //                       Container(
// //                         padding: EdgeInsets.all(12),
// //                         decoration: BoxDecoration(
// //                           gradient: LinearGradient(
// //                             begin: Alignment.topLeft,
// //                             end: Alignment.bottomRight,
// //                             colors: [
// //                               Colors.purple.shade400,
// //                               Colors.purple.shade600,
// //                             ],
// //                           ),
// //                           borderRadius: BorderRadius.circular(12),
// //                         ),
// //                         child: Icon(
// //                           IconlyBold.lock,
// //                           color: Colors.white,
// //                           size: 24,
// //                         ),
// //                       ),
// //                       SizedBox(width: 16),
// //                       Expanded(
// //                         child: Column(
// //                           crossAxisAlignment: CrossAxisAlignment.start,
// //                           children: [
// //                             Text(
// //                               'Mon Journal Privé',
// //                               style: TextStyle(
// //                                 color: Colors.grey.shade800,
// //                                 fontSize: 20,
// //                                 fontWeight: FontWeight.bold,
// //                               ),
// //                             ),
// //                             Text(
// //                               'Espace sécurisé et confidentiel',
// //                               style: TextStyle(
// //                                 color: Colors.grey.shade600,
// //                                 fontSize: 14,
// //                               ),
// //                             ),
// //                           ],
// //                         ),
// //                       ),
// //                       Container(
// //                         padding: EdgeInsets.all(8),
// //                         decoration: BoxDecoration(
// //                           color: Colors.green.shade50,
// //                           borderRadius: BorderRadius.circular(8),
// //                         ),
// //                         child: Icon(
// //                           IconlyBold.lock,
// //                           color: Colors.green.shade600,
// //                           size: 20,
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ),

// //                 // Contenu principal
// //                 Expanded(
// //                   child: _entries.isEmpty
// //                       ? _buildEmptyState(themeProvider)
// //                       : _buildEntriesList(themeProvider),
// //                 ),

// //                 // Zone d'ajout de note
// //                 Container(
// //                   padding: EdgeInsets.all(20),
// //                   decoration: BoxDecoration(
// //                     color: Colors.white,
// //                     border: Border(
// //                       top: BorderSide(color: Colors.grey.shade200, width: 1),
// //                     ),
// //                   ),
// //                   child: Row(
// //                     children: [
// //                       Expanded(
// //                         child: Container(
// //                           padding: EdgeInsets.symmetric(
// //                             horizontal: 16,
// //                             vertical: 12,
// //                           ),
// //                           decoration: BoxDecoration(
// //                             color: Colors.grey.shade50,
// //                             borderRadius: BorderRadius.circular(25),
// //                             border: Border.all(
// //                               color: Colors.grey.shade200,
// //                               width: 1,
// //                             ),
// //                           ),
// //                           child: TextField(
// //                             controller: _noteController,
// //                             decoration: InputDecoration(
// //                               hintText: 'Écrivez votre pensée...',
// //                               hintStyle: TextStyle(color: Colors.grey.shade500),
// //                               border: InputBorder.none,
// //                             ),
// //                             maxLines: null,
// //                           ),
// //                         ),
// //                       ),
// //                       SizedBox(width: 12),
// //                       GestureDetector(
// //                         onTap: _addEntry,
// //                         child: Container(
// //                           padding: EdgeInsets.all(12),
// //                           decoration: BoxDecoration(
// //                             gradient: LinearGradient(
// //                               begin: Alignment.topLeft,
// //                               end: Alignment.bottomRight,
// //                               colors: [
// //                                 themeProvider.seedColor,
// //                                 themeProvider.seedColor.withOpacity(0.8),
// //                               ],
// //                             ),
// //                             borderRadius: BorderRadius.circular(25),
// //                           ),
// //                           child: Icon(
// //                             IconlyBold.send,
// //                             color: Colors.white,
// //                             size: 20,
// //                           ),
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         );
// //       },
// //     );
// //   }

// //   Widget _buildEmptyState(AidaThemeProvider themeProvider) {
// //     return Center(
// //       child: Column(
// //         mainAxisAlignment: MainAxisAlignment.center,
// //         children: [
// //           Container(
// //             width: 120,
// //             height: 120,
// //             decoration: BoxDecoration(
// //               gradient: LinearGradient(
// //                 begin: Alignment.topLeft,
// //                 end: Alignment.bottomRight,
// //                 colors: [
// //                   themeProvider.seedColor.withOpacity(0.1),
// //                   themeProvider.seedColor.withOpacity(0.05),
// //                 ],
// //               ),
// //               borderRadius: BorderRadius.circular(60),
// //             ),
// //             child: Icon(
// //               IconlyBold.document,
// //               size: 60,
// //               color: themeProvider.seedColor.withOpacity(0.6),
// //             ),
// //           ),
// //           SizedBox(height: 24),
// //           Text(
// //             'Votre journal privé',
// //             style: TextStyle(
// //               fontSize: 24,
// //               fontWeight: FontWeight.bold,
// //               color: Colors.grey.shade800,
// //             ),
// //           ),
// //           SizedBox(height: 12),
// //           Text(
// //             'Écrivez vos pensées, vos notes\net gardez vos souvenirs en sécurité',
// //             textAlign: TextAlign.center,
// //             style: TextStyle(
// //               fontSize: 16,
// //               color: Colors.grey.shade600,
// //               height: 1.5,
// //             ),
// //           ),
// //           SizedBox(height: 32),
// //           Container(
// //             padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
// //             decoration: BoxDecoration(
// //               gradient: LinearGradient(
// //                 begin: Alignment.topLeft,
// //                 end: Alignment.bottomRight,
// //                 colors: [
// //                   themeProvider.seedColor,
// //                   themeProvider.seedColor.withOpacity(0.8),
// //                 ],
// //               ),
// //               borderRadius: BorderRadius.circular(25),
// //             ),
// //             child: Row(
// //               mainAxisSize: MainAxisSize.min,
// //               children: [
// //                 Icon(IconlyBold.edit, color: Colors.white, size: 20),
// //                 SizedBox(width: 8),
// //                 Text(
// //                   'Commencer à écrire',
// //                   style: TextStyle(
// //                     color: Colors.white,
// //                     fontSize: 16,
// //                     fontWeight: FontWeight.w600,
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildEntriesList(AidaThemeProvider themeProvider) {
// //     return ListView.builder(
// //       padding: EdgeInsets.all(20),
// //       itemCount: _entries.length,
// //       itemBuilder: (context, index) {
// //         final entry = _entries[index];
// //         return _buildEntryCard(entry, themeProvider);
// //       },
// //     );
// //   }

// //   Widget _buildEntryCard(JournalEntry entry, AidaThemeProvider themeProvider) {
// //     return Container(
// //       margin: EdgeInsets.only(bottom: 16),
// //       padding: EdgeInsets.all(20),
// //       decoration: BoxDecoration(
// //         color: Colors.white,
// //         borderRadius: BorderRadius.circular(16),
// //         border: Border.all(color: Colors.grey.shade200, width: 1),
// //         boxShadow: [
// //           BoxShadow(
// //             color: Colors.black.withOpacity(0.05),
// //             blurRadius: 10,
// //             offset: const Offset(0, 4),
// //           ),
// //         ],
// //       ),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           Row(
// //             children: [
// //               Container(
// //                 padding: EdgeInsets.all(8),
// //                 decoration: BoxDecoration(
// //                   color: themeProvider.seedColor.withOpacity(0.1),
// //                   borderRadius: BorderRadius.circular(8),
// //                 ),
// //                 child: Icon(
// //                   IconlyBold.document,
// //                   color: themeProvider.seedColor,
// //                   size: 16,
// //                 ),
// //               ),
// //               SizedBox(width: 12),
// //               Expanded(
// //                 child: Text(
// //                   _formatDate(entry.timestamp),
// //                   style: TextStyle(
// //                     color: Colors.grey.shade600,
// //                     fontSize: 14,
// //                     fontWeight: FontWeight.w500,
// //                   ),
// //                 ),
// //               ),
// //               Icon(IconlyBold.lock, color: Colors.grey.shade400, size: 16),
// //             ],
// //           ),
// //           SizedBox(height: 12),
// //           Text(
// //             entry.text,
// //             style: TextStyle(
// //               color: Colors.grey.shade800,
// //               fontSize: 16,
// //               height: 1.5,
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   void _addEntry() {
// //     if (_noteController.text.trim().isEmpty) return;

// //     setState(() {
// //       _entries.insert(
// //         0,
// //         JournalEntry(
// //           text: _noteController.text.trim(),
// //           timestamp: DateTime.now(),
// //         ),
// //       );
// //     });

// //     _noteController.clear();
// //   }

// //   String _formatDate(DateTime date) {
// //     final now = DateTime.now();
// //     final difference = now.difference(date);

// //     if (difference.inDays == 0) {
// //       return 'Aujourd\'hui à ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
// //     } else if (difference.inDays == 1) {
// //       return 'Hier à ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
// //     } else {
// //       return '${date.day}/${date.month}/${date.year}';
// //     }
// //   }
// // }

// // class JournalEntry {
// //   final String text;
// //   final DateTime timestamp;

// //   JournalEntry({required this.text, required this.timestamp});
// // }

// class CycleTrackingScreen extends StatelessWidget {
//   const CycleTrackingScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<AidaThemeProvider>(
//       builder: (context, themeProvider, child) {
//         return Scaffold(
//           backgroundColor: Colors.white,
//           body: SafeArea(
//             child: Padding(
//               padding: const EdgeInsets.all(20),
//               child: Column(
//                 children: [
//                   // Header
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         'Suivi du cycle',
//                         style: TextStyle(
//                           color: Colors.grey.shade800,
//                           fontSize: 28,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       Container(
//                         padding: EdgeInsets.all(12),
//                         decoration: BoxDecoration(
//                           color: themeProvider.seedColor.withOpacity(0.1),
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Icon(
//                           IconlyLight.calendar,
//                           color: themeProvider.seedColor,
//                           size: 24,
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 30),

//                   // Calendrier placeholder
//                   Expanded(
//                     child: Container(
//                       width: double.infinity,
//                       padding: EdgeInsets.all(20),
//                       decoration: BoxDecoration(
//                         color: Colors.grey.shade50,
//                         borderRadius: BorderRadius.circular(16),
//                         border: Border.all(color: Colors.grey.shade200),
//                       ),
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(
//                             IconlyBold.calendar,
//                             size: 60,
//                             color: themeProvider.seedColor,
//                           ),
//                           SizedBox(height: 16),
//                           Text(
//                             'Calendrier menstruel',
//                             style: TextStyle(
//                               color: Colors.grey.shade800,
//                               fontSize: 18,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                           SizedBox(height: 8),
//                           Text(
//                             'Marquez vos règles et symptômes',
//                             style: TextStyle(
//                               color: Colors.grey.shade600,
//                               fontSize: 14,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

// class CommunityScreen extends StatelessWidget {
//   const CommunityScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<AidaThemeProvider>(
//       builder: (context, themeProvider, child) {
//         return Scaffold(
//           backgroundColor: Colors.white,
//           body: SafeArea(
//             child: Padding(
//               padding: const EdgeInsets.all(20),
//               child: Column(
//                 children: [
//                   // Header
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         'Communauté',
//                         style: TextStyle(
//                           color: Colors.grey.shade800,
//                           fontSize: 28,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       Container(
//                         padding: EdgeInsets.all(12),
//                         decoration: BoxDecoration(
//                           color: Colors.green.shade50,
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Icon(
//                           IconlyLight.chat,
//                           color: Colors.green.shade600,
//                           size: 24,
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 30),

//                   // Contenu communauté
//                   Expanded(
//                     child: Center(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(
//                             IconlyBold.chat,
//                             size: 80,
//                             color: Colors.green.shade400,
//                           ),
//                           SizedBox(height: 20),
//                           Text(
//                             'Espace de partage sécurisé',
//                             style: TextStyle(
//                               color: Colors.grey.shade800,
//                               fontSize: 20,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                           SizedBox(height: 8),
//                           Text(
//                             'Connectez-vous avec d\'autres femmes\npour partager vos expériences',
//                             textAlign: TextAlign.center,
//                             style: TextStyle(
//                               color: Colors.grey.shade600,
//                               fontSize: 16,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
