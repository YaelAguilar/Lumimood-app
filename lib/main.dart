import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:lumimood/core/api/api_config.dart';
import 'core/injection_container.dart' as di;
import 'core/presentation/router.dart';
import 'core/presentation/theme.dart';
import 'core/session/session_cubit.dart';

void main() async {
  // Asegura que los bindings de Flutter estén inicializados
  WidgetsFlutterBinding.ensureInitialized();
  
  ApiConfig.printConfiguration();
  // Inicializa los formatos de fecha para español
  await initializeDateFormatting('es_ES', null); 
  
  // Inicializa la inyección de dependencias
  await di.init();

  // Corre la aplicación
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.getIt<SessionCubit>(),
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