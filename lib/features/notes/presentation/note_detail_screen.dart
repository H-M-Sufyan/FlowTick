import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../domain/note_model.dart';

class NoteDetailScreen extends StatelessWidget {
  final NoteModel note;

  const NoteDetailScreen({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            pinned: true,
            backgroundColor: scheme.background,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: scheme.surface.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
              ),
              onPressed: () => context.pop(),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [scheme.primary, scheme.tertiary],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Iconsax.edit_2,
                      color: Colors.white, size: 16),
                ),
                onPressed: () => context.push('/add-note', extra: note),
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(72, 0, 60, 16),
              title: Text(
                note.title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Iconsax.calendar_14,
                          size: 14,
                          color: scheme.onSurface.withOpacity(0.4)),
                      const SizedBox(width: 6),
                      Text(
                        DateFormat('MMMM d, yyyy').format(note.createdAt),
                        style: TextStyle(
                          color: scheme.onSurface.withOpacity(0.4),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 100.ms),
                  const SizedBox(height: 20),
                  if (note.imageUrls.isNotEmpty) ...[
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: note.imageUrls.length,
                        itemBuilder: (ctx, i) => Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: CachedNetworkImage(
                              imageUrl: note.imageUrls[i],
                              width: 280,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ).animate().fadeIn(delay: 150.ms).slideX(begin: 0.05),
                    const SizedBox(height: 20),
                  ],
                  Text(
                    note.content,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.8,
                    ),
                  ).animate().fadeIn(delay: 200.ms),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}