import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/tasks_repository.dart';
import '../domain/task_model.dart';
import '../../../core/constants/app_constants.dart';

final tasksRepositoryProvider = Provider((ref) => TasksRepository());

final allTasksProvider = StreamProvider<List<TaskModel>>((ref) {
  return ref.watch(tasksRepositoryProvider).watchAllTasks();
});

final taskSortProvider = StateProvider<SortType>((ref) => SortType.latest);

final taskSearchQueryProvider = StateProvider<String>((ref) => '');

final filteredTasksProvider = Provider<AsyncValue<List<TaskModel>>>((ref) {
  final tasksAsync = ref.watch(allTasksProvider);
  final sort = ref.watch(taskSortProvider);
  final query = ref.watch(taskSearchQueryProvider).toLowerCase();
  return tasksAsync.whenData((tasks) {
    var filtered = query.isEmpty
        ? tasks
        : tasks.where((t) => t.title.toLowerCase().contains(query)).toList();
    if (sort == SortType.alertTime) {
      filtered = [...filtered]..sort((a, b) {
          if (a.reminderTime == null && b.reminderTime == null) return 0;
          if (a.reminderTime == null) return 1;
          if (b.reminderTime == null) return -1;
          return a.reminderTime!.compareTo(b.reminderTime!);
        });
    }
    return filtered;
  });
});