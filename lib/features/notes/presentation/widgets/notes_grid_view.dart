import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../domain/note_model.dart';

class NotesGridView extends StatelessWidget {
  final Map<int, List<NoteModel>> notesByYear;

  const NotesGridView({super.key, required this.notesByYear});

  @override
  Widget build(BuildContext context) {
    final allNotes = notesByYear.values.expand((n) => n).toList();
    if (allNotes.isEmpty) {
      return const Center(child: Text('No notes yet'));
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: allNotes.length,
      itemBuilder: (ctx, i) => _GridNote(note: allNotes[i], index: i),
    );
  }
}

class _GridNote extends StatelessWidget {
  final NoteModel note;
  final int index;

  const _GridNote({required this.note, required this.index});

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final scheme = Theme.of(context).colorScheme;
    final gradients = [
      [const Color(0xFF667EEA), const Color(0xFF764BA2)],
      [const Color(0xFF43CBFF), const Color(0xFF9708CC)],
      [const Color(0xFFFF6B6B), const Color(0xFFFFE66D)],
      [const Color(0xFF11998E), const Color(0xFF38EF7D)],
      [const Color(0xFFFC5C7D), const Color(0xFF6A82FB)],
      [const Color(0xFFF7971E), const Color(0xFFFFD200)],
    ];
    final grad = gradients[index % gradients.length];

    return GestureDetector(
      onTap: () => context.push('/note-detail', extra: note),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: grad,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: grad[0].withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    note.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  if (note.content.isNotEmpty)
                    Text(
                      note.content,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        height: 1.4,
                      ),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              DateFormat('MM/dd/yyyy').format(note.createdAt),
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: index * 50))
        .scale(begin: const Offset(0.9, 0.9), curve: Curves.easeOut)
        .fadeIn();
  }
}