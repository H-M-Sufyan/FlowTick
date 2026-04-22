import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/notes_provider.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allNotes = ref.watch(allNotesProvider);
    final deletedNotes = ref.watch(deletedNotesProvider);
    final scheme = Theme.of(context).colorScheme;

    return Drawer(
      backgroundColor: scheme.surface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'FlowTick',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: scheme.primary,
                  letterSpacing: -0.5,
                ),
              ),
            ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.2),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Your notes & tasks',
                style: TextStyle(
                  color: scheme.onSurface.withOpacity(0.5),
                  fontSize: 13,
                ),
              ),
            ).animate().fadeIn(delay: 150.ms),
            const SizedBox(height: 32),
            _DrawerItem(
              icon: Iconsax.note_215,
              label: 'All Notes',
              count: allNotes.valueOrNull?.length ?? 0,
              delay: 200,
              onTap: () => Navigator.of(context).pop(),
            ),
            const SizedBox(height: 8),
            _DrawerItem(
              icon: Iconsax.trash,
              label: 'Recently Deleted',
              count: deletedNotes.valueOrNull?.length ?? 0,
              delay: 250,
              isDestructive: true,
              onTap: () {
                Navigator.of(context).pop();
                _showDeletedNotesSheet(context, ref);
              },
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'v1.0.0',
                style: TextStyle(
                  color: scheme.onSurface.withOpacity(0.3),
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeletedNotesSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DeletedNotesSheet(ref: ref),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final int delay;
  final bool isDestructive;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.count,
    required this.delay,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = isDestructive ? scheme.error : scheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: color.withOpacity(0.07),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 18, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: scheme.onSurface,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.chevron_right_rounded,
                    size: 18, color: color.withOpacity(0.5)),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: delay)).slideX(begin: -0.1);
  }
}

class _DeletedNotesSheet extends ConsumerWidget {
  final WidgetRef ref;
  const _DeletedNotesSheet({required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deletedNotes = ref.watch(deletedNotesProvider);
    final scheme = Theme.of(context).colorScheme;
    final repo = ref.read(notesRepositoryProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: scheme.onSurface.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Icon(Icons.delete_outline_rounded,
                    color: scheme.error, size: 22),
                const SizedBox(width: 10),
                Text(
                  'Recently Deleted',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: deletedNotes.when(
              data: (notes) => notes.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.delete_sweep_outlined,
                              size: 60,
                              color: scheme.onSurface.withOpacity(0.2)),
                          const SizedBox(height: 12),
                          Text(
                            'No deleted notes',
                            style: TextStyle(
                              color: scheme.onSurface.withOpacity(0.4),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: notes.length,
                      itemBuilder: (ctx, i) => ListTile(
                        title: Text(notes[i].title,
                            style:
                                const TextStyle(fontWeight: FontWeight.w600)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextButton(
                              onPressed: () => repo.restoreNote(notes[i].id),
                              child: const Text('Restore'),
                            ),
                            TextButton(
                              onPressed: () =>
                                  repo.permanentlyDeleteNote(notes[i].id),
                              style: TextButton.styleFrom(
                                  foregroundColor: scheme.error),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      ),
                    ),
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }
}