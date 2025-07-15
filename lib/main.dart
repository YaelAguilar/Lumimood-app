import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:developer';
import 'core/injection_container.dart' as di;
import 'core/presentation/router.dart';
import 'core/presentation/theme.dart';
import 'core/session/session_cubit.dart';

void main() async {
  // Asegura que los bindings de Flutter estén inicializados
  WidgetsFlutterBinding.ensureInitialized();
  
  log('🚀 APP: Starting Lumimood application...');
  
  // Inicializa los formatos de fecha para español
  await initializeDateFormatting('es_ES', null); 
  
  // Inicializa la inyección de dependencias
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

        // Define la lista de idiomas que la aplicación soporta.
        supportedLocales: const [
          Locale('en', ''), // Inglés, como idioma por defecto
          Locale('es', ''), // Español
        ],
      ),
    );
  }
}