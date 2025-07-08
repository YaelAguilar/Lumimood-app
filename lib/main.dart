import 'package:flutter/material.dart';
import 'app/di.dart' as di;
import 'app/navigation.dart';
import 'app/theme.dart';

void main() {
  di.setup();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Lumimood',
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.router,
    );
  }
}