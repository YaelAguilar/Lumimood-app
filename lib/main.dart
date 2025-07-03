import 'package:flutter/material.dart';
import 'ui/welcome/view/welcome_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lumimood',
      theme: ThemeData(
        primarySwatch: Colors.blue, 
        useMaterial3: true,
      ),
      home: const WelcomePage(),
      routes: {
        '/login': (context) => const LoginPagePlaceholder(),
        '/register': (context) => const RegisterPagePlaceholder(), 
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