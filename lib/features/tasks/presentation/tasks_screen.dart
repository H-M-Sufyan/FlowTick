import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../domain/task_model.dart';
import '../providers/tasks_provider.dart';

class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(filteredTasksProvider);
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Text(
            'Tasks',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: scheme.onBackground,
              letterSpacing: -0.5,
            ),
          ).animate().fadeIn().slideY(begin: -0.1),
        ),
        Expanded(
          child: tasksAsync.when(
            data: (tasks) => tasks.isEmpty
                ? _EmptyTaskState()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                    itemCount: tasks.length,
                    itemBuilder: (ctx, i) =>
                        _TaskTile(task: tasks[i], index: i, ref: ref),
                  ),
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
          ),
        ),
      ],
    );
  }
}

class _TaskTile extends StatelessWidget {
  final TaskModel task;
  final int index;
  final WidgetRef ref;

  const _TaskTile(
      {required this.task, required this.index, required this.ref});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final repo = ref.read(tasksRepositoryProvider);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Dismissible(
        key: Key(task.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: scheme.errorContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(Iconsax.trash, color: scheme.error),
        ),
        onDismissed: (_) => repo.deleteTask(task.id),
        child: Container(
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: task.isCompleted
                  ? scheme.primary.withOpacity(0.2)
                  : scheme.outline.withOpacity(0.08),
            ),
            boxShadow: [
              BoxShadow(
                color: scheme.primary.withOpacity(0.04),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: GestureDetector(
              onTap: () => repo.toggleTask(task.id, !task.isCompleted),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  gradient: task.isCompleted
                      ? LinearGradient(
                          colors: [scheme.primary, scheme.tertiary],
                        )
                      : null,
                  border: Border.all(
                    color: task.isCompleted
                        ? Colors.transparent
                        : scheme.outline.withOpacity(0.4),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: task.isCompleted
                    ? const Icon(Icons.check_rounded,
                        size: 16, color: Colors.white)
                    : null,
              ),
            ),
            title: Text(
              task.title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                decoration: task.isCompleted
                    ? TextDecoration.lineThrough
                    : null,
                color: task.isCompleted
                    ? scheme.onSurface.withOpacity(0.4)
                    : scheme.onSurface,
              ),
            ),
            subtitle: task.reminderTime != null
                ? Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        Icon(
                          Iconsax.clock,
                          size: 12,
                          color: scheme.primary.withOpacity(0.7),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('MMM d, yyyy  hh:mm a')
                              .format(task.reminderTime!),
                          style: TextStyle(
                            fontSize: 12,
                            color: scheme.primary.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  )
                : null,
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: index * 40))
        .fadeIn()
        .slideX(begin: 0.05, curve: Curves.easeOut);
  }
}

class _EmptyTaskState extends StatelessWidget {
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
              Iconsax.task_square,
              size: 60,
              color: scheme.primary.withOpacity(0.4),
            ),
          ).animate().scale(delay: 100.ms, curve: Curves.elasticOut),
          const SizedBox(height: 24),
          Text(
            'No tasks yet',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: scheme.onSurface.withOpacity(0.6),
            ),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 8),
          Text(
            'Tap + to add your first task',
            style: TextStyle(color: scheme.onSurface.withOpacity(0.4)),
          ).animate().fadeIn(delay: 300.ms),
        ],
      ),
    );
  }
}