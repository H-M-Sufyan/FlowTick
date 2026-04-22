import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import '../domain/note_model.dart';
import '../../../core/constants/app_constants.dart';

class NotesRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final _uuid = const Uuid();

  Stream<List<NoteModel>> watchAllNotes() {
    return _firestore
        .collection(AppConstants.notesCollection)
        .where('isDeleted', isEqualTo: false)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => NoteModel.fromMap(d.data())).toList());
  }

  Stream<List<NoteModel>> watchDeletedNotes() {
    return _firestore
        .collection(AppConstants.notesCollection)
        .where('isDeleted', isEqualTo: true)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => NoteModel.fromMap(d.data())).toList());
  }

  Future<void> addNote({
    required String title,
    required String content,
    List<File> images = const [],
  }) async {
    final id = _uuid.v4();
    final imageUrls = await _uploadImages(id, images);
    final note = NoteModel(
      id: id,
      title: title,
      content: content,
      imageUrls: imageUrls,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await _firestore
        .collection(AppConstants.notesCollection)
        .doc(id)
        .set(note.toMap());
  }

  Future<void> updateNote({
    required NoteModel note,
    List<File> newImages = const [],
  }) async {
    final newUrls = await _uploadImages(note.id, newImages);
    final updatedNote = note.copyWith(
      imageUrls: [...note.imageUrls, ...newUrls],
      updatedAt: DateTime.now(),
    );
    await _firestore
        .collection(AppConstants.notesCollection)
        .doc(note.id)
        .update(updatedNote.toMap());
  }

  Future<void> softDeleteNote(String id) async {
    await _firestore
        .collection(AppConstants.notesCollection)
        .doc(id)
        .update({'isDeleted': true, 'updatedAt': Timestamp.now()});
  }

  Future<void> restoreNote(String id) async {
    await _firestore
        .collection(AppConstants.notesCollection)
        .doc(id)
        .update({'isDeleted': false, 'updatedAt': Timestamp.now()});
  }

  Future<void> permanentlyDeleteNote(String id) async {
    await _firestore
        .collection(AppConstants.notesCollection)
        .doc(id)
        .delete();
  }

  Future<List<String>> _uploadImages(String noteId, List<File> images) async {
    final urls = <String>[];
    for (final img in images) {
      final ref = _storage
          .ref()
          .child(AppConstants.storageNotesFolder)
          .child(noteId)
          .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
      await ref.putFile(img);
      urls.add(await ref.getDownloadURL());
    }
    return urls;
  }
}