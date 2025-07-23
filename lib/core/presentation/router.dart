import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../features/authentication/presentation/bloc/auth_bloc.dart';
import '../../features/authentication/presentation/pages/login_page.dart';
import '../../features/authentication/presentation/pages/register_page.dart';
import '../../features/authentication/presentation/pages/forgot_password_page.dart';
import '../../features/diary/presentation/bloc/diary_bloc.dart';
import '../../features/diary/presentation/pages/diary_page.dart';
import '../../features/notes/domain/entities/note.dart';
import '../../features/notes/presentation/pages/create_note_page.dart';
import '../../features/notes/presentation/pages/note_detail_page.dart';
import '../../features/notes/presentation/pages/notes_page.dart';
import '../../features/specialist/presentation/bloc/specialist_bloc.dart';
import '../../features/specialist/presentation/pages/specialist_home_page.dart';
import '../../features/statistics/presentation/pages/statistics_page.dart';
import '../../features/tasks/presentation/pages/tasks_page.dart';
import '../../features/welcome/presentation/pages/welcome_page.dart';
import '../injection_container.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'welcome',
        builder: (context, state) => const WelcomePage(),
      ),
      
      // Authentication routes with shared BlocProvider
      ShellRoute(
        builder: (context, state, child) {
          return BlocProvider(
            create: (context) => getIt<AuthBloc>(),
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: '/login',
            name: 'login',
            builder: (context, state) => const LoginPage(),
          ),
          GoRoute(
            path: '/register',
            name: 'register',
            builder: (context, state) => const RegisterPage(),
          ),
          GoRoute(
            path: '/forgot-password',
            name: 'forgot_password',
            builder: (context, state) => const ForgotPasswordPage(),
          ),
        ],
      ),
      
      // Patient routes
      GoRoute(
        path: '/diary', 
        name: 'diary', 
        builder: (context, state) {
          return BlocProvider(
            create: (context) => getIt<DiaryBloc>(),
            child: const DiaryPage(),
          );
        }
      ),
      GoRoute(
        path: '/statistics', 
        name: 'statistics', 
        builder: (context, state) => const StatisticsPage()
      ),
      GoRoute(
        path: '/tasks', 
        name: 'tasks', 
        builder: (context, state) => const TasksPage()
      ),
      GoRoute(
        path: '/notes', 
        name: 'notes', 
        builder: (context, state) => const NotesPage()
      ),
      GoRoute(
        path: '/create-note', 
        name: 'create-note', 
        builder: (context, state) => const CreateNotePage()
      ),
      GoRoute(
        path: '/note-detail',
        name: 'note_detail',
        builder: (context, state) {
          if (state.extra is Note) {
            return NoteDetailPage(note: state.extra as Note);
          }
          return const NotesPage(); 
        },
      ),

      // Specialist routes
      ShellRoute(
        builder: (context, state, child) {
          return BlocProvider(
            create: (context) => getIt<SpecialistBloc>()..add(LoadSpecialistDashboard()),
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: '/specialist-home',
            name: 'specialist_home',
            builder: (context, state) {
              return const SpecialistHomePage();
            },
          ),
        ],
      ),
    ],
  );
}