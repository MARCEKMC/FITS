import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/tasks_viewmodel.dart';
import '../../../data/models/task.dart';
import '../../../shared/widgets/elegant_save_dialog.dart';

class TaskEditorScreen extends StatefulWidget {
  final Task? task;

  const TaskEditorScreen({super.key, this.task});

  @override
  State<TaskEditorScreen> createState() => _TaskEditorScreenState();
}

class _TaskEditorScreenState extends State<TaskEditorScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _tagsController;
  
  late Task _currentTask;
  bool _hasChanges = false;
  List<String> _selectedTags = [];
  String _selectedPriority = 'medium';
  DateTime? _selectedDueDate;

  @override
  void initState() {
    super.initState();
    
    _currentTask = widget.task ?? context.read<TasksViewModel>().createNewTask();
    _titleController = TextEditingController(text: _currentTask.title);
    _descriptionController = TextEditingController(text: _currentTask.description);
    _tagsController = TextEditingController();
    
    _selectedTags = List.from(_currentTask.tags);
    _selectedPriority = _currentTask.priority;
    _selectedDueDate = _currentTask.dueDate;
    
    _titleController.addListener(_onTextChanged);
    _descriptionController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _hasChanges = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => _handleBack(),
          ),
          title: Text(
            widget.task == null ? 'Nueva Tarea' : 'Editar Tarea',
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.check, color: Colors.black87),
              onPressed: _saveTask,
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title field
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Título de la tarea',
                  border: OutlineInputBorder(),
                  hintText: 'Escribe el título de tu tarea...',
                ),
                style: const TextStyle(fontSize: 16),
                maxLines: 2,
              ),
              
              const SizedBox(height: 16),
              
              // Description field
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción (opcional)',
                  border: OutlineInputBorder(),
                  hintText: 'Agrega más detalles sobre la tarea...',
                ),
                style: const TextStyle(fontSize: 16),
                maxLines: 4,
              ),
              
              const SizedBox(height: 16),
              
              // Priority selector
              const Text(
                'Prioridad',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildPriorityChip('high', 'Alta', Colors.red[300]!),
                  const SizedBox(width: 8),
                  _buildPriorityChip('medium', 'Media', Colors.orange[300]!),
                  const SizedBox(width: 8),
                  _buildPriorityChip('low', 'Baja', Colors.green[300]!),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Due date selector
              Row(
                children: [
                  const Text(
                    'Fecha límite',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  if (_selectedDueDate != null)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedDueDate = null;
                          _hasChanges = true;
                        });
                      },
                      child: const Text('Quitar'),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _selectDueDate,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: Colors.grey[600],
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _selectedDueDate == null
                            ? 'Seleccionar fecha límite'
                            : _formatSelectedDate(_selectedDueDate!),
                        style: TextStyle(
                          fontSize: 16,
                          color: _selectedDueDate == null ? Colors.grey[600] : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Tags section
              const Text(
                'Etiquetas',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _tagsController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Agregar etiqueta...',
                      ),
                      onSubmitted: (_) => _addTag(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _addTag,
                  ),
                ],
              ),
              
              // Selected tags
              if (_selectedTags.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _selectedTags.map((tag) => Chip(
                    label: Text(tag),
                    onDeleted: () => _removeTag(tag),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    backgroundColor: Colors.grey[100],
                  )).toList(),
                ),
              ],
              
              const SizedBox(height: 32),
              
              // Status toggle (only for existing tasks)
              if (widget.task != null) ...[
                Row(
                  children: [
                    Icon(
                      _currentTask.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                      color: _currentTask.isCompleted ? Colors.green : Colors.grey,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _currentTask.isCompleted ? 'Tarea completada' : 'Tarea pendiente',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Switch(
                      value: _currentTask.isCompleted,
                      onChanged: (value) {
                        setState(() {
                          _currentTask = _currentTask.copyWith(isCompleted: value);
                          _hasChanges = true;
                        });
                      },
                      activeColor: Colors.green,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityChip(String priority, String label, Color color) {
    final isSelected = _selectedPriority == priority;
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        setState(() {
          _selectedPriority = priority;
          _hasChanges = true;
        });
      },
      backgroundColor: Colors.white,
      selectedColor: color.withOpacity(0.2),
      side: BorderSide(color: isSelected ? color : Colors.grey[300]!),
      labelStyle: TextStyle(
        color: isSelected ? color : Colors.black87,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  void _selectDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (date != null) {
      setState(() {
        _selectedDueDate = date;
        _hasChanges = true;
      });
    }
  }

  String _formatSelectedDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDate = DateTime(date.year, date.month, date.day);
    
    final difference = selectedDate.difference(today).inDays;
    
    if (difference == 0) {
      return 'Hoy';
    } else if (difference == 1) {
      return 'Mañana';
    } else if (difference < 7) {
      return 'En $difference días';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _addTag() {
    final tag = _tagsController.text.trim();
    if (tag.isNotEmpty && !_selectedTags.contains(tag)) {
      setState(() {
        _selectedTags.add(tag);
        _tagsController.clear();
        _hasChanges = true;
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _selectedTags.remove(tag);
      _hasChanges = true;
    });
  }

  Future<bool> _onWillPop() async {
    return await _handleBack();
  }

  Future<bool> _handleBack() async {
    if (!_hasChanges) {
      return true;
    }

    bool shouldSave = false;
    
    await ElegantSaveDialog.show(
      context: context,
      title: 'Guardar cambios',
      content: '¿Quieres guardar los cambios antes de salir?',
      onSave: () {
        shouldSave = true;
      },
      onDiscard: () {
        shouldSave = false;
      },
    );

    if (shouldSave) {
      await _saveTask();
    }

    return true;
  }

  Future<void> _saveTask() async {
    final title = _titleController.text.trim();
    
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El título de la tarea no puede estar vacío'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final updatedTask = _currentTask.copyWith(
      title: title,
      description: _descriptionController.text.trim(),
      updatedAt: DateTime.now(),
      dueDate: _selectedDueDate,
      priority: _selectedPriority,
      tags: _selectedTags,
    );

    print('TaskEditor: Saving task with title: "${updatedTask.title}"');

    await context.read<TasksViewModel>().saveTask(updatedTask);
    
    if (mounted) {
      print('TaskEditor: Returning to previous screen');
      Navigator.pop(context);
    }
  }
}
