import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:developer';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/injection_container.dart' as di;
import 'core/presentation/router.dart';
import 'core/presentation/theme.dart';
import 'core/session/session_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load();

  log('🚀 APP: Starting Lumimood application...');

  // Inicializa los formatos de fecha para español
  await initializeDateFormatting('es_ES', null);

  // Inyección de dependencias
  log('🔧 APP: Initializing dependency injection...');
  await di.init();
  log('✅ APP: Dependency injection completed');

  // Corre la aplicación
  log('📱 APP: Running app...');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    log('🏗️ APP: Building MyApp widget');
    
    return BlocProvider(
      create: (_) {
        log('🔧 APP: Creating SessionCubit...');
        return di.getIt<SessionCubit>();
      },
      child: MaterialApp.router(
        title: 'Lumimood',
        theme: AppTheme.lightTheme,
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,

        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],

        // Lista de idiomas que la aplicación soporta.
        supportedLocales: const [
          Locale('en', ''), // Inglés, como idioma por defecto
          Locale('es', ''), // Español
        ],
      ),
    );
  }
}