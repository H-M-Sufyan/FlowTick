import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../providers/notes_provider.dart';
import '../../tasks/providers/tasks_provider.dart';
import '../../../core/constants/app_constants.dart';
import 'drawer/app_drawer.dart';
import 'widgets/notes_list_view.dart';
import 'widgets/notes_card_view.dart';
import 'widgets/notes_grid_view.dart';
import '../../tasks/presentation/tasks_screen.dart';
import '../../../shared/widgets/animated_fab.dart';
import '../../tasks/presentation/widgets/add_task_bottom_sheet.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTab = ref.watch(appTabProvider);
    final viewType = ref.watch(viewTypeProvider);
    final scheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: scheme.background,
        drawer: const AppDrawer(),
        appBar: _buildAppBar(context, ref, currentTab, viewType, scheme),
        body: Column(
          children: [
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.03, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                ),
                child: currentTab == AppTab.notes
                    ? _NotesBody(key: const ValueKey('notes'))
                    : const TasksScreen(key: ValueKey('tasks')),
              ),
            ),
            _BottomBar(currentTab: currentTab),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    WidgetRef ref,
    AppTab currentTab,
    ViewType viewType,
    ColorScheme scheme,
  ) {
    return AppBar(
      leading: Builder(
        builder: (ctx) => IconButton(
          onPressed: () => Scaffold.of(ctx).openDrawer(),
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: scheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Iconsax.menu_1, size: 20, color: scheme.primary),
          ),
        ),
      ),
      title: _TabSwitcher(currentTab: currentTab, ref: ref),
      centerTitle: true,
      actions: [
        currentTab == AppTab.notes
            ? _ViewDropdown(viewType: viewType, ref: ref, scheme: scheme)
            : _SortDropdown(ref: ref, scheme: scheme),
        const SizedBox(width: 8),
      ],
    );
  }
}

class _TabSwitcher extends StatelessWidget {
  final AppTab currentTab;
  final WidgetRef ref;

  const _TabSwitcher({required this.currentTab, required this.ref});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      height: 38,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outline.withOpacity(0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _TabButton(
            label: 'Notes',
            isSelected: currentTab == AppTab.notes,
            onTap: () => ref.read(appTabProvider.notifier).state = AppTab.notes,
          ),
          _TabButton(
            label: 'Tasks',
            isSelected: currentTab == AppTab.tasks,
            onTap: () => ref.read(appTabProvider.notifier).state = AppTab.tasks,
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton(
      {required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [scheme.primary, scheme.tertiary],
                )
              : null,
          borderRadius: BorderRadius.circular(17),
        ),
        child: Text(
          label,
          style: TextStyle(
            color:
                isSelected ? Colors.white : scheme.onSurface.withOpacity(0.5),
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _ViewDropdown extends StatelessWidget {
  final ViewType viewType;
  final WidgetRef ref;
  final ColorScheme scheme;

  const _ViewDropdown(
      {required this.viewType, required this.ref, required this.scheme});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<ViewType>(
      initialValue: viewType,
      onSelected: (v) => ref.read(viewTypeProvider.notifier).state = v,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: scheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          viewType == ViewType.list
              ? Iconsax.row_vertical
              : viewType == ViewType.card
                  ? Iconsax.card
                  : Iconsax.grid_3,
          size: 20,
          color: scheme.primary,
        ),
      ),
      itemBuilder: (_) => [
        _menuItem(ViewType.list, Iconsax.row_vertical, 'List View'),
        _menuItem(ViewType.card, Iconsax.card, 'Card View'),
        _menuItem(ViewType.grid, Iconsax.grid_3, 'Grid View'),
      ],
    );
  }

  PopupMenuItem<ViewType> _menuItem(
      ViewType value, IconData icon, String label) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 18, color: scheme.primary),
          const SizedBox(width: 10),
          Text(label),
          if (viewType == value) ...[
            const Spacer(),
            Icon(Icons.check_rounded, size: 16, color: scheme.primary),
          ],
        ],
      ),
    );
  }
}

class _SortDropdown extends StatelessWidget {
  final WidgetRef ref;
  final ColorScheme scheme;

  const _SortDropdown({required this.ref, required this.scheme});

  @override
  Widget build(BuildContext context) {
    final sort = ref.watch(taskSortProvider);
    return PopupMenuButton<SortType>(
      initialValue: sort,
      onSelected: (v) => ref.read(taskSortProvider.notifier).state = v,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: scheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(Iconsax.sort, size: 20, color: scheme.primary),
      ),
      itemBuilder: (_) => [
        PopupMenuItem(
          value: SortType.latest,
          child: Row(
            children: [
              Icon(Iconsax.clock, size: 18, color: scheme.primary),
              const SizedBox(width: 10),
              const Text('Sort by latest'),
              if (sort == SortType.latest) ...[
                const Spacer(),
                Icon(Icons.check_rounded, size: 16, color: scheme.primary),
              ],
            ],
          ),
        ),
        PopupMenuItem(
          value: SortType.alertTime,
          child: Row(
            children: [
              Icon(Iconsax.alarm, size: 18, color: scheme.primary),
              const SizedBox(width: 10),
              const Text('Sort by alert time'),
              if (sort == SortType.alertTime) ...[
                const Spacer(),
                Icon(Icons.check_rounded, size: 16, color: scheme.primary),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _NotesBody extends ConsumerWidget {
  const _NotesBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewType = ref.watch(viewTypeProvider);
    final notesByYear = ref.watch(notesByYearProvider);

    return notesByYear.when(
      data: (byYear) {
        return switch (viewType) {
          ViewType.list => NotesListView(notesByYear: byYear),
          ViewType.card => NotesCardView(notesByYear: byYear),
          ViewType.grid => NotesGridView(notesByYear: byYear),
        };
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

class _BottomBar extends ConsumerStatefulWidget {
  final AppTab currentTab;
  const _BottomBar({required this.currentTab});

  @override
  ConsumerState<_BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends ConsumerState<_BottomBar> with RouteAware {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _searchCtrl = TextEditingController();

  static final RouteObserver<ModalRoute<void>> routeObserver =
      RouteObserver<ModalRoute<void>>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void didPopNext() {
    _focusNode.unfocus();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _focusNode.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _clearAndUnfocus() {
    _searchCtrl.clear();
    _focusNode.unfocus();
    ref.read(noteSearchQueryProvider.notifier).state = '';
    ref.read(taskSearchQueryProvider.notifier).state = '';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isNotes = widget.currentTab == AppTab.notes;

    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        10,
        16,
        MediaQuery.of(context).padding.bottom + 10,
      ),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: scheme.surfaceVariant.withOpacity(0.5),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: scheme.outline.withOpacity(0.3),
                  width: 0.5,
                ),
              ),
              child: TextField(
                controller: _searchCtrl,
                focusNode: _focusNode,
                onChanged: (v) {
                  if (isNotes) {
                    ref.read(noteSearchQueryProvider.notifier).state = v;
                  } else {
                    ref.read(taskSearchQueryProvider.notifier).state = v;
                  }
                },
                decoration: InputDecoration(
                  hintText: isNotes ? 'Search notes...' : 'Search tasks...',
                  hintStyle: TextStyle(
                    color: scheme.onSurface.withOpacity(0.4),
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(
                    Iconsax.search_normal,
                    size: 18,
                    color: scheme.onSurface.withOpacity(0.4),
                  ),
                  suffixIcon: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _searchCtrl,
                    builder: (_, value, __) => value.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.close_rounded,
                              size: 16,
                              color: scheme.onSurface.withOpacity(0.4),
                            ),
                            onPressed: _clearAndUnfocus,
                          )
                        : const SizedBox.shrink(),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          AnimatedFab(
            onTap: () {
              _focusNode.unfocus();
              Future.delayed(const Duration(milliseconds: 100), () {
                if (!mounted) return;
                if (isNotes) {
                  context.push('/add-note');
                } else {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => const AddTaskBottomSheet(),
                  );
                }
              });
            },
          ),
        ],
      ),
    );
  }
}
