import 'package:aida/app/page/home/notifcations.dart';
import 'package:aida/app/page/onboarding/onboarding.dart';
import 'package:aida/core/app_theme.dart';
import 'package:aida/pages/chat_list_page.dart';
import 'package:aida/pages/aidatab.dart';
import 'package:aida/pages/avatar_selection_page.dart';
import 'package:aida/pages/calendar_page.dart';
import 'package:aida/pages/education_page.dart';
import 'package:aida/pages/history_page.dart';
import 'package:aida/pages/yoga_fitness_page.dart';
import 'package:aida/pages/home_page.dart';
import 'package:aida/pages/journal_page.dart';
import 'package:aida/pages/settings_page.dart';
import 'package:aida/pages/statistics_page.dart';
import 'package:aida/pages/symptoms_page.dart';
import 'package:aida/providers/journal_provider.dart';
import 'package:aida/providers/periods_provider.dart';
import 'package:aida/providers/symptoms_provider.dart';
import 'package:aida/providers/user_provider.dart';
import 'package:aida/services/theme_service.dart';
import 'package:aida/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AidaApp extends StatelessWidget {
  const AidaApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeService()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => PeriodsProvider()),
        ChangeNotifierProvider(create: (_) => SymptomsProvider()),
        ChangeNotifierProvider(create: (_) => JournalProvider()),
      ],
      child: Consumer<ThemeService>(
        builder: (context, themeService, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'AIDA',
            theme: AppTheme.lightTheme(
              themeService.seedColor,
              themeService.fontFamily,
            ),
            darkTheme: AppTheme.darkTheme(
              themeService.seedColor,
              themeService.fontFamily,
            ),

            themeMode: themeService.getEffectiveThemeMode(context),
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('fr', 'FR'), Locale('en', 'US')],
            locale: const Locale('fr', 'FR'),
            home: UserService.hasUser()
                ? const AidaTab()
                : const OnboardingPage(),
            routes: {
              '/onboarding': (context) => const OnboardingPage(),
              '/entry': (context) => const AidaTab(),
              '/home': (context) => const AidaTab(),
              '/ai-coach': (context) => const ChatListPage(),
              '/calendar': (context) => const CalendarPage(),
              '/symptoms': (context) => const SymptomsPage(),
              '/history': (context) => const HistoryPage(),
              '/journal': (context) => const JournalPage(),
              '/notifications': (context) => const NotificationsPage(),
              '/settings': (context) => const SettingsPage(),
              '/statistics': (context) => const StatisticsPage(),
              '/avatar-selection': (context) => const AvatarSelectionPage(),
              '/education': (context) => const EducationPage(),
              '/yoga-fitness': (context) => const YogaFitnessPage(),
            },
          );
        },
      ),
    );
  }
}
