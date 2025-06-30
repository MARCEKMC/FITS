import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodel/tasks_viewmodel.dart';
import '../../../data/models/task.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;
  final VoidCallback onToggleComplete;
  final VoidCallback onDelete;

  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
    required this.onToggleComplete,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<TasksViewModel>();
    final priorityColor = viewModel.getPriorityColor(task.priority);
    final priorityIcon = viewModel.getPriorityIcon(task.priority);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: task.isCompleted ? Colors.green[200]! : Colors.grey[200]!,
        ),
      ),
      color: task.isCompleted ? Colors.green[50] : Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with checkbox, title and actions
              Row(
                children: [
                  // Checkbox
                  InkWell(
                    onTap: onToggleComplete,
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: task.isCompleted ? Colors.green : Colors.grey[400]!,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(6),
                        color: task.isCompleted ? Colors.green : Colors.transparent,
                      ),
                      child: task.isCompleted
                          ? const Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Priority indicator
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: priorityColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          priorityIcon,
                          size: 14,
                          color: priorityColor,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          task.priority.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: priorityColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Title
                  Expanded(
                    child: Text(
                      task.title.isEmpty ? 'Sin título' : task.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: task.title.isEmpty ? Colors.grey[500] : Colors.black87,
                        decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                        decorationColor: Colors.grey[400],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  
                  // Actions menu
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, color: Colors.grey[600], size: 20),
                    onSelected: (value) {
                      if (value == 'delete') {
                        onDelete();
                      } else if (value == 'toggle') {
                        onToggleComplete();
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'toggle',
                        child: Row(
                          children: [
                            Icon(
                              task.isCompleted ? Icons.undo : Icons.check_circle_outline,
                              color: task.isCompleted ? Colors.orange : Colors.green,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              task.isCompleted ? 'Marcar pendiente' : 'Marcar completada',
                              style: TextStyle(
                                color: task.isCompleted ? Colors.orange : Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, color: Colors.red, size: 20),
                            SizedBox(width: 8),
                            Text('Eliminar', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              // Description
              if (task.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(left: 36),
                  child: Text(
                    task.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
              
              // Tags
              if (task.tags.isNotEmpty) ...[
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.only(left: 36),
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: task.tags.take(3).map((tag) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        tag,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )).toList(),
                  ),
                ),
              ],
              
              // Footer with dates
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.only(left: 36),
                child: Row(
                  children: [
                    // Due date
                    if (task.dueDate != null) ...[
                      Icon(
                        _isOverdue(task.dueDate!) ? Icons.warning : Icons.schedule,
                        size: 14,
                        color: _isOverdue(task.dueDate!) ? Colors.red : Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDueDate(task.dueDate!),
                        style: TextStyle(
                          fontSize: 12,
                          color: _isOverdue(task.dueDate!) ? Colors.red : Colors.grey[500],
                          fontWeight: _isOverdue(task.dueDate!) ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                    
                    // Updated date
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(task.updatedAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isOverdue(DateTime dueDate) {
    return !task.isCompleted && dueDate.isBefore(DateTime.now());
  }

  String _formatDueDate(DateTime dueDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(dueDate.year, dueDate.month, dueDate.day);
    
    final difference = taskDate.difference(today).inDays;
    
    if (difference == 0) {
      return 'Hoy';
    } else if (difference == 1) {
      return 'Mañana';
    } else if (difference == -1) {
      return 'Ayer';
    } else if (difference < 0) {
      return 'Hace ${-difference} días';
    } else if (difference < 7) {
      return 'En $difference días';
    } else {
      return '${dueDate.day}/${dueDate.month}/${dueDate.year}';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Ahora';
        }
        return 'Hace ${difference.inMinutes}m';
      }
      return 'Hace ${difference.inHours}h';
    } else if (difference.inDays == 1) {
      return 'Ayer';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays}d';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
