import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../providers/task_provider.dart';

/// Widget to display when there are no tasks
class EmptyStateWidget extends StatefulWidget {
  final TaskFilter filter;
  final bool hasSearch;

  const EmptyStateWidget({
    super.key,
    required this.filter,
    this.hasSearch = false,
  });

  @override
  State<EmptyStateWidget> createState() => _EmptyStateWidgetState();
}

class _EmptyStateWidgetState extends State<EmptyStateWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutBack,
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final emptyStateData = _getEmptyStateData();

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Illustration
                Container(
                  width: 120,
                  height: 120,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: emptyStateData.color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    emptyStateData.icon,
                    size: 72,
                    color: emptyStateData.color,
                  ),
                ),

                const SizedBox(height: 24),

                // Title
                Text(
                  emptyStateData.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                // Description
                Text(
                  emptyStateData.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                // Action suggestion
                if (emptyStateData.actionText.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.primaryColor.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: AppColors.primaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          emptyStateData.actionText,
                          style: TextStyle(
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  _EmptyStateData _getEmptyStateData() {
    if (widget.hasSearch) {
      return _EmptyStateData(
        icon: Icons.search_off,
        title: 'No matching tasks',
        description:
            'Try adjusting your search terms\nor check a different filter.',
        actionText: 'Clear search to see all tasks',
        color: AppColors.textSecondary,
      );
    }

    switch (widget.filter) {
      case TaskFilter.all:
        return _EmptyStateData(
          icon: Icons.task_alt,
          title: 'No tasks yet',
          description:
              'Start by adding your first task.\nTap the + button to get started!',
          actionText: 'Tap + to add your first task',
          color: AppColors.primaryColor,
        );

      case TaskFilter.active:
        return _EmptyStateData(
          icon: Icons.check_circle_outline,
          title: 'All caught up!',
          description:
              'You have no active tasks.\nGreat job staying on top of things!',
          actionText: 'Add new tasks to stay productive',
          color: AppColors.success,
        );

      case TaskFilter.completed:
        return _EmptyStateData(
          icon: Icons.pending_actions,
          title: 'No completed tasks',
          description: 'Complete some tasks to see them here.\nYou can do it!',
          actionText: 'Mark tasks as complete to see progress',
          color: AppColors.warning,
        );
    }
  }
}

class _EmptyStateData {
  final IconData icon;
  final String title;
  final String description;
  final String actionText;
  final Color color;

  _EmptyStateData({
    required this.icon,
    required this.title,
    required this.description,
    required this.actionText,
    required this.color,
  });
}
