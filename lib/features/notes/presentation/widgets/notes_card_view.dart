import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/note_model.dart';

const _cardColors = [
  Color(0xFFE8F4FD),
  Color(0xFFF0E8FD),
  Color(0xFFFDE8F0),
  Color(0xFFE8FDF0),
  Color(0xFFFDF4E8),
  Color(0xFFE8FDFD),
];

const _cardColorsDark = [
  Color(0xFF1A2A38),
  Color(0xFF2A1A38),
  Color(0xFF381A2A),
  Color(0xFF1A3828),
  Color(0xFF38321A),
  Color(0xFF1A3838),
];

class NotesCardView extends ConsumerWidget {
  final Map<int, List<NoteModel>> notesByYear;

  const NotesCardView({super.key, required this.notesByYear});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final allNotes = notesByYear.values.expand((n) => n).toList();

    if (allNotes.isEmpty) {
      return const Center(child: Text('No notes yet'));
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
      itemCount: allNotes.length,
      itemBuilder: (ctx, i) {
        final note = allNotes[i];
        final bgColor = (isDark ? _cardColorsDark : _cardColors)[i % 6];
        return _NoteCard(note: note, bgColor: bgColor, index: i);
      },
    );
  }
}

class _NoteCard extends StatelessWidget {
  final NoteModel note;
  final Color bgColor;
  final int index;

  const _NoteCard(
      {required this.note, required this.bgColor, required this.index});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () => context.push('/note-detail', extra: note),
        child: Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: scheme.primary.withOpacity(0.1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (note.imageUrls.isNotEmpty)
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24)),
                  child: CachedNetworkImage(
                    imageUrl: note.imageUrls.first,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      note.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (note.content.isNotEmpty)
                      Text(
                        note.content,
                        style: TextStyle(
                          color: scheme.onSurface.withOpacity(0.6),
                          fontSize: 13,
                          height: 1.5,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Iconsax.calendar_14,
                            size: 12,
                            color: scheme.onSurface.withOpacity(0.4)),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('MM/dd/yyyy').format(note.createdAt),
                          style: TextStyle(
                            color: scheme.onSurface.withOpacity(0.4),
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        if (note.imageUrls.isNotEmpty)
                          Row(
                            children: [
                              Icon(Iconsax.image,
                                  size: 12,
                                  color: scheme.primary.withOpacity(0.6)),
                              const SizedBox(width: 4),
                              Text(
                                '${note.imageUrls.length}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: scheme.primary.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: index * 50))
        .fadeIn()
        .slideY(begin: 0.05, curve: Curves.easeOut);
  }
}