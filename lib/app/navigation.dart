import 'package:go_router/go_router.dart';
import '../features/authentication/presentation/pages/forgot_password_page.dart';
import '../features/authentication/presentation/pages/login_page.dart';
import '../features/authentication/presentation/pages/register_page.dart';
import '../features/diary/presentation/pages/diary_page.dart';
import '../features/statistics/presentation/pages/statistics_page.dart';
import '../features/welcome/presentation/pages/welcome_page.dart';
import '../features/tasks/presentation/pages/tasks_page.dart';
import '../features/notes/presentation/pages/notes_page.dart';

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
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterPage(),
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
        path: '/forgot-password',
        name: 'forgot_password',
        builder: (context, state) => const ForgotPasswordPage(),
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
    ],
  );
}