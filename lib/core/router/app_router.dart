import 'package:go_router/go_router.dart';
import '../../features/notes/presentation/home_screen.dart';
import '../../features/notes/presentation/add_note_screen.dart';
import '../../features/notes/presentation/note_detail_screen.dart';
import '../../features/notes/domain/note_model.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/add-note',
      builder: (context, state) {
        final note = state.extra as NoteModel?;
        return AddNoteScreen(existingNote: note);
      },
    ),
    GoRoute(
      path: '/note-detail',
      builder: (context, state) {
        final note = state.extra as NoteModel;
        return NoteDetailScreen(note: note);
      },
    ),
  ],
);