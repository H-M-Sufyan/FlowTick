import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/notes_repository.dart';
import '../domain/note_model.dart';
import '../../../core/constants/app_constants.dart';

final notesRepositoryProvider = Provider((ref) => NotesRepository());

final allNotesProvider = StreamProvider<List<NoteModel>>((ref) {
  return ref.watch(notesRepositoryProvider).watchAllNotes();
});

final deletedNotesProvider = StreamProvider<List<NoteModel>>((ref) {
  return ref.watch(notesRepositoryProvider).watchDeletedNotes();
});

final viewTypeProvider = StateProvider<ViewType>((ref) => ViewType.list);
final appTabProvider = StateProvider<AppTab>((ref) => AppTab.notes);

final noteSearchQueryProvider = StateProvider<String>((ref) => '');

final filteredNotesProvider = Provider<AsyncValue<List<NoteModel>>>((ref) {
  final notesAsync = ref.watch(allNotesProvider);
  final query = ref.watch(noteSearchQueryProvider).toLowerCase();
  return notesAsync.whenData((notes) {
    if (query.isEmpty) return notes;
    return notes
        .where((n) =>
            n.title.toLowerCase().contains(query) ||
            n.content.toLowerCase().contains(query))
        .toList();
  });
});

// Group notes by year
final notesByYearProvider =
    Provider<AsyncValue<Map<int, List<NoteModel>>>>((ref) {
  return ref.watch(filteredNotesProvider).whenData((notes) {
    final map = <int, List<NoteModel>>{};
    for (final note in notes) {
      final year = note.createdAt.year;
      map.putIfAbsent(year, () => []).add(note);
    }
    return Map.fromEntries(
        map.entries.toList()..sort((a, b) => b.key.compareTo(a.key)));
  });
});