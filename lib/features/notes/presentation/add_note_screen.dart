import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import '../domain/note_model.dart';
import '../providers/notes_provider.dart';

class AddNoteScreen extends ConsumerStatefulWidget {
  final NoteModel? existingNote;

  const AddNoteScreen({super.key, this.existingNote});

  @override
  ConsumerState<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends ConsumerState<AddNoteScreen> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _contentCtrl;
  final List<File> _newImages = [];
  List<String> _existingImageUrls = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleCtrl =
        TextEditingController(text: widget.existingNote?.title ?? '');
    _contentCtrl =
        TextEditingController(text: widget.existingNote?.content ?? '');
    _existingImageUrls =
        List.from(widget.existingNote?.imageUrls ?? []);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 75);
    if (picked != null) {
      setState(() => _newImages.add(File(picked.path)));
    }
  }

  Future<void> _save() async {
    if (_titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a title')),
      );
      return;
    }
    setState(() => _isSaving = true);
    final repo = ref.read(notesRepositoryProvider);
    try {
      if (widget.existingNote == null) {
        await repo.addNote(
          title: _titleCtrl.text.trim(),
          content: _contentCtrl.text.trim(),
          images: _newImages,
        );
      } else {
        await repo.updateNote(
          note: widget.existingNote!.copyWith(
            title: _titleCtrl.text.trim(),
            content: _contentCtrl.text.trim(),
            imageUrls: _existingImageUrls,
          ),
          newImages: _newImages,
        );
      }
      if (mounted) context.pop();
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isEdit = widget.existingNote != null;

    return Scaffold(
      backgroundColor: scheme.background,
      appBar: AppBar(
        title: Text(
          isEdit ? 'Edit Note' : 'New Note',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          _isSaving
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : IconButton(
                  onPressed: _save,
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [scheme.primary, scheme.tertiary],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.check_rounded,
                        color: Colors.white, size: 20),
                  ),
                ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _titleCtrl,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Title',
                      border: InputBorder.none,
                      hintStyle: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey,
                      ),
                    ),
                    maxLines: null,
                  ).animate().fadeIn().slideY(begin: -0.1),
                  const Divider(height: 24),
                  TextField(
                    controller: _contentCtrl,
                    style: const TextStyle(fontSize: 16, height: 1.7),
                    decoration: const InputDecoration(
                      hintText: 'Start writing your note...',
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                    maxLines: null,
                    minLines: 10,
                  ).animate().fadeIn(delay: 100.ms),
                  if (_existingImageUrls.isNotEmpty ||
                      _newImages.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _ImageGrid(
                      existingUrls: _existingImageUrls,
                      newFiles: _newImages,
                      onRemoveExisting: (url) =>
                          setState(() => _existingImageUrls.remove(url)),
                      onRemoveNew: (file) =>
                          setState(() => _newImages.remove(file)),
                    ),
                  ],
                ],
              ),
            ),
          ),
          _BottomActionBar(onPickImage: _pickImage, onSave: _save),
        ],
      ),
    );
  }
}

class _ImageGrid extends StatelessWidget {
  final List<String> existingUrls;
  final List<File> newFiles;
  final ValueChanged<String> onRemoveExisting;
  final ValueChanged<File> onRemoveNew;

  const _ImageGrid({
    required this.existingUrls,
    required this.newFiles,
    required this.onRemoveExisting,
    required this.onRemoveNew,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ...existingUrls.map((url) => _ImageTile(
              child: Image.network(url, fit: BoxFit.cover),
              onRemove: () => onRemoveExisting(url),
            )),
        ...newFiles.map((f) => _ImageTile(
              child: Image.file(f, fit: BoxFit.cover),
              onRemove: () => onRemoveNew(f),
            )),
      ],
    );
  }
}

class _ImageTile extends StatelessWidget {
  final Widget child;
  final VoidCallback onRemove;

  const _ImageTile({required this.child, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(width: 100, height: 100, child: child),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

class _BottomActionBar extends StatelessWidget {
  final VoidCallback onPickImage;
  final VoidCallback onSave;

  const _BottomActionBar(
      {required this.onPickImage, required this.onSave});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 12, 20, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          _ActionBtn(
            icon: Iconsax.camera,
            label: 'Photo',
            onTap: onPickImage,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: onSave,
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [scheme.primary, scheme.tertiary],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: scheme.primary.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_rounded, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Save Note',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionBtn(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: scheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: scheme.primary),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: scheme.primary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}