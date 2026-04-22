import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../domain/task_model.dart';
import '../../../core/constants/app_constants.dart';

class TasksRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  Stream<List<TaskModel>> watchAllTasks() {
    return _firestore
        .collection(AppConstants.tasksCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => TaskModel.fromMap(d.data())).toList());
  }

  Future<void> addTask({
    required String title,
    DateTime? reminderTime,
  }) async {
    final id = _uuid.v4();
    final task = TaskModel(
      id: id,
      title: title,
      reminderTime: reminderTime,
      createdAt: DateTime.now(),
    );
    await _firestore
        .collection(AppConstants.tasksCollection)
        .doc(id)
        .set(task.toMap());
  }

  Future<void> toggleTask(String id, bool isCompleted) async {
    await _firestore
        .collection(AppConstants.tasksCollection)
        .doc(id)
        .update({'isCompleted': isCompleted});
  }

  Future<void> deleteTask(String id) async {
    await _firestore
        .collection(AppConstants.tasksCollection)
        .doc(id)
        .delete();
  }
}