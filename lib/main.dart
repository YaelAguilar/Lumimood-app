import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'features/diary/view/diary_page.dart';
import 'ui/welcome/view/welcome_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseTheme = ThemeData(
      useMaterial3: true,
      primaryColor: const Color(0xFF63DA5C),
      scaffoldBackgroundColor: const Color(0xFFF5FBFB),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF63DA5C),
        primary: const Color(0xFF63DA5C),
        secondary: Colors.grey[300]!,
        surface: Colors.grey[50]!,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.notoSans(fontSize: 32, fontWeight: FontWeight.bold, color: const Color(0xFF101518)),
        displaySmall: GoogleFonts.interTight(fontSize: 24, fontWeight: FontWeight.w600, color: const Color(0xFF101518)),
        headlineMedium: GoogleFonts.readexPro(fontSize: 28, fontWeight: FontWeight.w600, color: const Color(0xFF101518)),
        titleSmall: GoogleFonts.interTight(fontSize: 18, fontWeight: FontWeight.w600, color: const Color(0xFF101518)),
        bodyMedium: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF101518)),
        labelMedium: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.normal, color: const Color(0xFF101518)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF5FBFB),
        hintStyle: GoogleFonts.inter(color: Colors.grey[600], fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFDFEDEC), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFDFEDEC), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF06D5CD), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFC4454D), width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFC4454D), width: 2),
        ),
      ),
    );

    return MaterialApp(
      title: 'Lumimood',
      theme: baseTheme,
      home: const WelcomePage(),
      routes: {
        '/login': (context) => const LoginPagePlaceholder(),
        '/register': (context) => const RegisterPagePlaceholder(),
        '/diary': (context) => const DiaryPage(),
      },
    );
  }
}

class LoginPagePlaceholder extends StatelessWidget {
  const LoginPagePlaceholder({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: const Center(child: Text('Página de Inicio de Sesión')),
    );
  }
}

class RegisterPagePlaceholder extends StatelessWidget {
  const RegisterPagePlaceholder({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro')),
      body: const Center(child: Text('Página de Registro')),
    );
  }
}