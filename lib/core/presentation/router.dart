import 'package:go_router/go_router.dart';
import '../../features/authentication/presentation/pages/forgot_password.dart';
import '../../features/authentication/presentation/pages/login_page.dart';
import '../../features/authentication/presentation/pages/register_page.dart';
import '../../features/diary/presentation/pages/diary_page.dart';
import '../../features/notes/domain/entities/note.dart';
import '../../features/notes/presentation/pages/create_note_page.dart';
import '../../features/notes/presentation/pages/note_detail_page.dart';
import '../../features/notes/presentation/pages/notes_page.dart';
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
          return const NotesPage();
        },
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot_password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
    ],
  );
}