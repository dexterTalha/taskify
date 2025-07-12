import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/entities/task.dart';
import '../providers/task_provider.dart';
import '../widgets/task_tile.dart';
import '../widgets/add_task_dialog.dart';
import '../widgets/task_filter_chips.dart';
import '../widgets/task_stats_card.dart';
import '../widgets/empty_state_widget.dart';

/// Main screen for displaying and managing tasks
class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _searchController.addListener(_onSearchChanged);
  }

  void _setupAnimations() {
    _animationController = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));

    _animationController.forward();
  }

  void _onSearchChanged() {
    final query = _searchController.text;
    context.read<TaskProvider>().setSearchQuery(query);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(position: _slideAnimation, child: _buildBody()),
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          return taskProvider.isSearching ? _buildSearchField() : const Text('Taskify');
        },
      ),
      actions: [
        Consumer<TaskProvider>(
          builder: (context, taskProvider, child) {
            return IconButton(
              icon: Icon(taskProvider.isSearching ? Icons.close : Icons.search),
              onPressed: () {
                if (taskProvider.isSearching) {
                  _searchController.clear();
                  taskProvider.clearSearch();
                } else {
                  taskProvider.setSearching(true);
                }
              },
            );
          },
        ),
        PopupMenuButton<String>(
          onSelected: _handleMenuAction,
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'clear_completed', child: Text('Clear Completed')),
            const PopupMenuItem(value: 'clear_all', child: Text('Clear All')),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      autofocus: true,
      decoration: const InputDecoration(
        hintText: 'Search tasks...',
        border: InputBorder.none,
        hintStyle: TextStyle(color: AppColors.textLight),
      ),
      style: const TextStyle(color: AppColors.textPrimary),
    );
  }

  Widget _buildBody() {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        if (taskProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            // Stats Card
            if (taskProvider.totalTasks > 0) Padding(padding: const EdgeInsets.all(16), child: TaskStatsCard()),

            // Filter Chips with Toggle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(child: TaskFilterChips()),
                  IconButton(
                    onPressed: () => taskProvider.toggleTaskDetailsCollapsed(),
                    icon: AnimatedRotation(
                      turns: taskProvider.isTaskDetailsCollapsed ? 0.5 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: Icon(taskProvider.isTaskDetailsCollapsed ? Icons.view_list : Icons.view_agenda, color: AppColors.textSecondary),
                    ),
                    tooltip: taskProvider.isTaskDetailsCollapsed ? 'Show Details' : 'Hide Details',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Task List
            Expanded(child: _buildTaskList(taskProvider)),
          ],
        );
      },
    );
  }

  Widget _buildTaskList(TaskProvider taskProvider) {
    final tasks = taskProvider.filteredTasks;

    if (tasks.isEmpty) {
      return EmptyStateWidget(filter: taskProvider.currentFilter, hasSearch: taskProvider.searchQuery.isNotEmpty);
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: TaskTile(
            key: ValueKey(task.id),
            task: task,
            isCollapsed: taskProvider.isTaskDetailsCollapsed,
            onTap: () => _showTaskDetails(task),
            onToggle: () => _toggleTask(task.id),
            onDelete: () => _deleteTask(task.id),
            onEdit: () => _editTask(task),
          ),
        );
      },
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton(onPressed: _addTask, child: const Icon(Icons.add));
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'clear_completed':
        _clearCompletedTasks();
        break;
      case 'clear_all':
        _clearAllTasks();
        break;
    }
  }

  void _addTask() {
    showDialog(context: context, builder: (context) => const AddTaskDialog());
  }

  void _editTask(Task task) {
    showDialog(
      context: context,
      builder: (context) => AddTaskDialog(task: task),
    );
  }

  void _toggleTask(String taskId) {
    context.read<TaskProvider>().toggleTaskCompletion(taskId);

    // Show feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Task updated'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _deleteTask(String taskId) {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<TaskProvider>().deleteTask(taskId);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Task deleted'),
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showTaskDetails(Task task) {
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (context) => _buildTaskDetailsSheet(task));
  }

  Widget _buildTaskDetailsSheet(Task task) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: AppColors.surfaceColor, borderRadius: BorderRadius.circular(16)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: AppColors.borderMedium, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 24),

          // Task title
          Text(task.title, style: Theme.of(context).textTheme.titleLarge?.copyWith(decoration: task.isCompleted ? TextDecoration.lineThrough : TextDecoration.none)),
          const SizedBox(height: 16),

          // Task description
          if (task.description.isNotEmpty) ...[
            Text(task.description, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 16),
          ],

          // Task details
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: AppColors.getPriorityColorWithOpacity(task.priority, 0.1), borderRadius: BorderRadius.circular(16)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.flag, size: 16, color: AppColors.getPriorityColor(task.priority)),
                    const SizedBox(width: 4),
                    Text(
                      _getPriorityText(task.priority),
                      style: TextStyle(fontSize: 12, color: AppColors.getPriorityColor(task.priority), fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: task.isCompleted ? AppColors.success.withOpacity(0.1) : AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  task.isCompleted ? 'Completed' : 'Pending',
                  style: TextStyle(fontSize: 12, color: task.isCompleted ? AppColors.success : AppColors.warning, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Created date
          Text('Created: ${_formatDate(task.createdAt)}', style: Theme.of(context).textTheme.bodySmall),
          if (task.updatedAt != task.createdAt) ...[const SizedBox(height: 4), Text('Updated: ${_formatDate(task.updatedAt)}', style: Theme.of(context).textTheme.bodySmall)],
        ],
      ),
    );
  }

  void _clearCompletedTasks() {
    final taskProvider = context.read<TaskProvider>();
    final completedTasks = taskProvider.allTasks.where((task) => task.isCompleted).toList();

    if (completedTasks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No completed tasks to clear')));
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Completed Tasks'),
        content: Text('Are you sure you want to delete ${completedTasks.length} completed tasks?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              for (final task in completedTasks) {
                taskProvider.deleteTask(task.id);
              }
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${completedTasks.length} completed tasks deleted')));
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _clearAllTasks() {
    final taskProvider = context.read<TaskProvider>();

    if (taskProvider.totalTasks == 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No tasks to clear')));
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Tasks'),
        content: Text('Are you sure you want to delete all ${taskProvider.totalTasks} tasks?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              taskProvider.deleteAllTasks();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All tasks deleted')));
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  String _getPriorityText(int priority) {
    switch (priority) {
      case 1:
        return 'Low';
      case 2:
        return 'Medium';
      case 3:
        return 'High';
      default:
        return 'Low';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
