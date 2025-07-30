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
import 'core/api/api_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Cargar variables de entorno
    await dotenv.load(fileName: ".env");
    log('✅ Environment variables loaded successfully');
  } catch (e) {
    log('❌ ERROR loading .env file: $e');
    log('❌ Make sure .env file exists in the root directory');
  }

  log('🚀 APP: Starting Lumimood application...');

  // Verificar configuración de API
  log('🔍 DEBUG: Verificando configuración de API...');
  ApiConfig.printConfiguration();
  
  // Validar que las URLs estén configuradas
  if (!ApiConfig.isConfigured()) {
    log('⚠️ WARNING: API configuration is incomplete or invalid!');
    log('⚠️ Please check your .env file and ensure all URLs are properly set');
    
    // Mostrar las URLs que faltan
    if (ApiConfig.patientBaseUrl.isEmpty) {
      log('❌ MISSING: PATIENT_BASE_URL');
    }
    if (ApiConfig.professionalBaseUrl.isEmpty) {
      log('❌ MISSING: PROFESSIONAL_BASE_URL');
    }
    if (ApiConfig.identityBaseUrl.isEmpty) {
      log('❌ MISSING: IDENTITY_BASE_URL');
    }
    if (ApiConfig.diaryBaseUrl.isEmpty) {
      log('❌ MISSING: DIARY_BASE_URL');
    }
    if (ApiConfig.appointmentBaseUrl.isEmpty) {
      log('❌ MISSING: APPOINTMENT_BASE_URL');
    }
  } else {
    log('✅ API configuration is valid');
  }

  // Inicializa los formatos de fecha para español
  await initializeDateFormatting('es_ES', null);
  log('✅ Date formatting initialized for Spanish');

  // Inyección de dependencias
  log('🔧 APP: Initializing dependency injection...');
  try {
    await di.init();
    log('✅ APP: Dependency injection completed successfully');
  } catch (e) {
    log('❌ ERROR during dependency injection: $e');
  }

  // Configurar manejo global de errores
  FlutterError.onError = (FlutterErrorDetails details) {
    log('❌ Flutter Error: ${details.exception}');
    log('Stack trace: ${details.stack}');
  };

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
          Locale('es', ''), // Español como idioma principal
          Locale('en', ''), // Inglés como respaldo
        ],
        
        // Configurar el locale por defecto
        locale: const Locale('es', ''),
        
        builder: (context, child) {
          // Wrapper para manejo de errores en UI
          ErrorWidget.builder = (FlutterErrorDetails details) {
            return Material(
              child: Container(
                color: Colors.red.shade50,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 60,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Oops! Algo salió mal',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          details.exception.toString(),
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          };
          
          return child ?? const SizedBox.shrink();
        },
      ),
    );
  }
}