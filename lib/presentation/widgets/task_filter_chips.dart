import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../providers/task_provider.dart';

/// Widget for filtering tasks with animated chips
class TaskFilterChips extends StatelessWidget {
  const TaskFilterChips({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        return Row(
          children: [
            _buildFilterChip(
              context,
              TaskFilter.all,
              'All',
              taskProvider.totalTasks,
              taskProvider.currentFilter == TaskFilter.all,
              taskProvider.setFilter,
            ),
            const SizedBox(width: 6),
            _buildFilterChip(
              context,
              TaskFilter.active,
              'Todo',
              taskProvider.activeTasks,
              taskProvider.currentFilter == TaskFilter.active,
              taskProvider.setFilter,
            ),
            const SizedBox(width: 6),
            _buildFilterChip(
              context,
              TaskFilter.completed,
              'Completed',
              taskProvider.completedTasks,
              taskProvider.currentFilter == TaskFilter.completed,
              taskProvider.setFilter,
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    TaskFilter filter,
    String label,
    int count,
    bool isSelected,
    Function(TaskFilter) onSelected,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: () => onSelected(filter),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primaryColor
                : AppColors.backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? AppColors.primaryColor
                  : AppColors.borderMedium,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? AppColors.textOnPrimary
                      : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 12,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(width: 3),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.textOnPrimary.withOpacity(0.2)
                      : AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    color: isSelected
                        ? AppColors.textOnPrimary
                        : AppColors.primaryColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
