// app.dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/home_screen.dart';
import 'l10n/app_localizations.dart';

class DentalClinicApp extends ConsumerWidget {
  const DentalClinicApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'عيادة Dyana Clinic',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        primaryColor: Color(0xFF8e24aa),
        fontFamily: 'Cairo',
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF8e24aa),
          brightness: Brightness.light,
        ).copyWith(
          primary: Color(0xFF8e24aa),
          secondary: Color(0xFFe1bee7),
          onPrimary: Colors.white,
          onSecondary: Color(0xFF5e35b1),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF8e24aa),
          foregroundColor: Colors.white,
          elevation: 2,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF8e24aa),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF8e24aa),
          foregroundColor: Colors.white,
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: Color(0xFF8e24aa),
            side: const BorderSide(color: Color(0xFF8e24aa), width: 2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFF8e24aa), width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFFe1bee7), width: 1.5),
            borderRadius: BorderRadius.circular(12),
          ),
          labelStyle: const TextStyle(color: Color(0xFF8e24aa)),
          floatingLabelStyle: const TextStyle(color: Color(0xFF8e24aa)),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          shadowColor: Color(0xFFe1bee7),
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: Colors.white,
          titleTextStyle: const TextStyle(color: Color(0xFF8e24aa), fontWeight: FontWeight.bold, fontSize: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF8e24aa)),
        textTheme: ThemeData.light().textTheme.copyWith(
          displayLarge: const TextStyle(color: Color(0xFF5e35b1), fontWeight: FontWeight.bold),
          titleLarge: const TextStyle(color: Color(0xFF5e35b1), fontWeight: FontWeight.bold),
          bodyLarge: const TextStyle(color: Color(0xFF8e24aa)),
          bodyMedium: const TextStyle(color: Color(0xFF8e24aa)),
        ),
      ),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
              locale: currentLocale,
        supportedLocales: const [
          Locale('en', ''),
          Locale('ar', ''),
        ],
        home: const HomeScreen(),
    );
  }
} 