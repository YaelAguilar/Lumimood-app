import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/injection_container.dart';
import '../../features/authentication/presentation/bloc/auth_bloc.dart';
import '../../features/authentication/presentation/pages/forgot_password.dart';
import '../../features/authentication/presentation/pages/login_page.dart';
import '../../features/authentication/presentation/pages/register_page.dart';
import '../../features/diary/presentation/pages/diary_page.dart';
import '../../features/notes/domain/entities/note.dart';
import '../../features/notes/presentation/pages/create_note_page.dart';
import '../../features/notes/presentation/pages/note_detail_page.dart';
import '../../features/notes/presentation/pages/notes_page.dart';
import '../../features/specialist/presentation/pages/specialist_home_page.dart';
import '../../features/statistics/presentation/pages/statistics_page.dart';
import '../../features/tasks/presentation/pages/tasks_page.dart';
import '../../features/welcome/presentation/pages/welcome_page.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'welcome',
        builder: (context, state) => const WelcomePage(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) {
          // Proveemos el AuthBloc aquí para que esté disponible en LoginPage
          // y sus hijos, asegurando que la instancia no se reinicie.
          return BlocProvider(
            create: (context) => getIt<AuthBloc>(),
            child: const LoginPage(),
          );
        },
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) {
          // Hacemos lo mismo para la página de registro
          return BlocProvider(
            create: (context) => getIt<AuthBloc>(),
            child: const RegisterPage(),
          );
        },
      ),
      GoRoute(
        path: '/diary',
        name: 'diary',
        builder: (context, state) => const DiaryPage(),
      ),
      GoRoute(
        path: '/statistics',
        name: 'statistics',
        builder: (context, state) => const StatisticsPage(),
      ),
      GoRoute(
        path: '/tasks',
        name: 'tasks',
        builder: (context, state) => const TasksPage(),
      ),
      GoRoute(
        path: '/notes',
        name: 'notes',
        builder: (context, state) => const NotesPage(),
      ),
      GoRoute(
        path: '/create-note',
        name: 'create_note',
        builder: (context, state) => const CreateNotePage(),
      ),
      GoRoute(
        path: '/note-detail',
        name: 'note_detail',
        builder: (context, state) {
          if (state.extra is Note) {
            return NoteDetailPage(note: state.extra as Note);
          }
          // Redirige a la página de notas si no se pasan los datos correctos.
          return const NotesPage(); 
        },
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot_password',
        builder: (context, state) {
          // ForgotPassword también podría necesitar su propio AuthBloc
          return BlocProvider(
            create: (context) => getIt<AuthBloc>(),
            child: const ForgotPasswordPage(),
          );
        },
      ),
      GoRoute(
        path: '/specialist-home',
        name: 'specialist_home',
        builder: (context, state) => const SpecialistHomePage(),
      ),
    ],
  );
}