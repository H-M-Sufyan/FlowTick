import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../providers/tasks_provider.dart';
import '../../../../core/utils/notification_service.dart';

class AddTaskBottomSheet extends ConsumerStatefulWidget {
  const AddTaskBottomSheet({super.key});

  @override
  ConsumerState<AddTaskBottomSheet> createState() =>
      _AddTaskBottomSheetState();
}

class _AddTaskBottomSheetState extends ConsumerState<AddTaskBottomSheet> {
  final _ctrl = TextEditingController();
  DateTime? _reminderTime;
  bool _isSaving = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _pickReminder() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(hours: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;
    setState(() {
      _reminderTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _save() async {
    if (_ctrl.text.trim().isEmpty) return;
    setState(() => _isSaving = true);
    final repo = ref.read(tasksRepositoryProvider);
    try {
      await repo.addTask(
        title: _ctrl.text.trim(),
        reminderTime: _reminderTime,
      );
      if (_reminderTime != null) {
        await NotificationService.instance.scheduleTaskNotification(
          id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          title: _ctrl.text.trim(),
          scheduledTime: _reminderTime!,
        );
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, bottom + 20),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: scheme.onSurface.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'New Task',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
            ),
          ).animate().fadeIn().slideY(begin: -0.1),
          const SizedBox(height: 16),
          TextField(
            controller: _ctrl,
            autofocus: true,
            style: const TextStyle(fontSize: 16),
            decoration: InputDecoration(
              hintText: 'What needs to be done?',
              prefixIcon:
                  Icon(Iconsax.task_square, color: scheme.primary, size: 20),
            ),
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _pickReminder,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: _reminderTime != null
                    ? scheme.primary.withOpacity(0.1)
                    : scheme.surfaceVariant.withOpacity(0.4),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _reminderTime != null
                      ? scheme.primary.withOpacity(0.3)
                      : Colors.transparent,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Iconsax.alarm,
                    size: 18,
                    color: _reminderTime != null
                        ? scheme.primary
                        : scheme.onSurface.withOpacity(0.4),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _reminderTime == null
                        ? 'Add reminder'
                        : DateFormat('MMM d, yyyy  hh:mm a')
                            .format(_reminderTime!),
                    style: TextStyle(
                      color: _reminderTime != null
                          ? scheme.primary
                          : scheme.onSurface.withOpacity(0.5),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (_reminderTime != null) ...[
                    const Spacer(),
                    GestureDetector(
                      onTap: () => setState(() => _reminderTime = null),
                      child: Icon(Icons.close_rounded,
                          size: 16,
                          color: scheme.onSurface.withOpacity(0.4)),
                    ),
                  ],
                ],
              ),
            ),
          ).animate().fadeIn(delay: 150.ms),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [scheme.primary, scheme.tertiary],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  alignment: Alignment.center,
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child:
                              CircularProgressIndicator(color: Colors.white),
                        )
                      : const Text(
                          'Add Task',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
            ),
          ).animate().fadeIn(delay: 200.ms),
        ],
      ),
    );
  }
}