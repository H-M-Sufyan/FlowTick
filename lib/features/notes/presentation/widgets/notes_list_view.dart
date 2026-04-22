import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../domain/note_model.dart';
import '../../providers/notes_provider.dart';

class NotesListView extends ConsumerWidget {
  final Map<int, List<NoteModel>> notesByYear;

  const NotesListView({super.key, required this.notesByYear});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;

    if (notesByYear.isEmpty) {
      return _EmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
      itemCount: notesByYear.keys.length,
      itemBuilder: (ctx, yearIdx) {
        final year = notesByYear.keys.elementAt(yearIdx);
        final notes = notesByYear[year]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          scheme.primary,
                          scheme.tertiary,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$year',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            scheme.primary.withOpacity(0.3),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: Duration(milliseconds: yearIdx * 50)),
            ...notes.asMap().entries.map((entry) {
              final i = entry.key;
              final note = entry.value;
              return _NoteListTile(
                note: note,
                index: yearIdx * 10 + i,
                ref: ref,
              );
            }),
          ],
        );
      },
    );
  }
}

class _NoteListTile extends StatelessWidget {
  final NoteModel note;
  final int index;
  final WidgetRef ref;

  const _NoteListTile(
      {required this.note, required this.index, required this.ref});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final repo = ref.read(notesRepositoryProvider);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          extentRatio: 0.3,
          children: [
            SlidableAction(
              onPressed: (_) => repo.softDeleteNote(note.id),
              backgroundColor: scheme.errorContainer,
              foregroundColor: scheme.error,
              icon: Iconsax.trash,
              borderRadius: BorderRadius.circular(16),
            ),
          ],
        ),
        child: GestureDetector(
          onTap: () => context.push('/note-detail', extra: note),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: scheme.outline.withOpacity(0.08),
              ),
              boxShadow: [
                BoxShadow(
                  color: scheme.primary.withOpacity(0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [scheme.primary, scheme.tertiary],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        note.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('MM/dd/yyyy').format(note.createdAt),
                        style: TextStyle(
                          color: scheme.onSurface.withOpacity(0.4),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (note.imageUrls.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: scheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Iconsax.image,
                        size: 14, color: scheme.primary),
                  ),
                const SizedBox(width: 8),
                Icon(Icons.chevron_right_rounded,
                    color: scheme.onSurface.withOpacity(0.3), size: 20),
              ],
            ),
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: index * 40))
        .fadeIn()
        .slideX(begin: 0.05, curve: Curves.easeOut);
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: scheme.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Iconsax.note_2,
              size: 60,
              color: scheme.primary.withOpacity(0.4),
            ),
          ).animate().scale(delay: 100.ms, curve: Curves.elasticOut),
          const SizedBox(height: 24),
          Text(
            'No notes yet',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: scheme.onSurface.withOpacity(0.6),
            ),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 8),
          Text(
            'Tap + to create your first note',
            style: TextStyle(
              color: scheme.onSurface.withOpacity(0.4),
            ),
          ).animate().fadeIn(delay: 300.ms),
        ],
      ),
    );
  }
}