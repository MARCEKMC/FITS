import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/notes_viewmodel.dart';
import '../../../data/models/note.dart';
import '../../../shared/widgets/elegant_confirm_dialog.dart';
import '../../../shared/widgets/elegant_save_dialog.dart';

class NoteEditorScreen extends StatefulWidget {
  final Note? note;

  const NoteEditorScreen({super.key, this.note});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _tagsController;
  
  late Note _currentNote;
  bool _hasChanges = false;
  List<String> _selectedTags = [];
  String _selectedColor = '#FFFFFF';
  bool _isPinned = false;

  final List<String> _availableColors = [
    '#FFFFFF', // White
    '#FFF3E0', // Orange 50
    '#E8F5E8', // Green 50
    '#E3F2FD', // Blue 50
    '#FCE4EC', // Pink 50
    '#F3E5F5', // Purple 50
    '#FFF8E1', // Yellow 50
  ];

  @override
  void initState() {
    super.initState();
    
    _currentNote = widget.note ?? context.read<NotesViewModel>().createNewNote();
    _titleController = TextEditingController(text: _currentNote.title);
    _contentController = TextEditingController(text: _currentNote.content);
    _tagsController = TextEditingController();
    
    _selectedTags = List.from(_currentNote.tags);
    _selectedColor = _currentNote.color;
    _isPinned = _currentNote.isPinned;
    
    _titleController.addListener(_onTextChanged);
    _contentController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
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
        backgroundColor: _getBackgroundColor(),
        appBar: AppBar(
          backgroundColor: _getBackgroundColor(),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => _handleBack(),
          ),
          actions: [
            // Pin toggle
            IconButton(
              icon: Icon(
                _isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                color: _isPinned ? Colors.orange[600] : Colors.grey[600],
              ),
              onPressed: () {
                setState(() {
                  _isPinned = !_isPinned;
                  _hasChanges = true;
                });
              },
            ),
            
            // Color picker
            PopupMenuButton<String>(
              icon: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: _getBackgroundColor(),
                  border: Border.all(color: Colors.grey[400]!),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              onSelected: (color) {
                setState(() {
                  _selectedColor = color;
                  _hasChanges = true;
                });
              },
              itemBuilder: (context) => _availableColors.map((color) => 
                PopupMenuItem(
                  value: color,
                  child: Container(
                    width: double.infinity,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Color(int.parse(color.replaceFirst('#', '0xFF'))),
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ).toList(),
            ),
            
            // Save button
            IconButton(
              icon: const Icon(Icons.check, color: Colors.black87),
              onPressed: _saveNote,
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Title field
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'Título de la nota...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                maxLines: 2,
              ),
              
              const SizedBox(height: 16),
              
              // Content field
              Expanded(
                child: TextField(
                  controller: _contentController,
                  decoration: const InputDecoration(
                    hintText: 'Escribe tu nota aquí...',
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                ),
              ),
              
              // Tags section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Etiquetas',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.add, size: 20),
                          onPressed: _addTag,
                        ),
                      ],
                    ),
                    
                    // Tags input
                    TextField(
                      controller: _tagsController,
                      decoration: const InputDecoration(
                        hintText: 'Agregar etiqueta...',
                        border: InputBorder.none,
                        hintStyle: TextStyle(fontSize: 14),
                      ),
                      style: const TextStyle(fontSize: 14),
                      onSubmitted: (_) => _addTag(),
                    ),
                    
                    // Selected tags
                    if (_selectedTags.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _selectedTags.map((tag) => Chip(
                          label: Text(
                            tag,
                            style: const TextStyle(fontSize: 12),
                          ),
                          onDeleted: () => _removeTag(tag),
                          deleteIcon: const Icon(Icons.close, size: 16),
                          backgroundColor: Colors.grey[100],
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        )).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    try {
      return Color(int.parse(_selectedColor.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.white;
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
      await _saveNote();
    }

    return true;
  }

  Future<void> _saveNote() async {
    final updatedNote = _currentNote.copyWith(
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      updatedAt: DateTime.now(),
      tags: _selectedTags,
      color: _selectedColor,
      isPinned: _isPinned,
    );

    print('NoteEditor: Saving note with title: "${updatedNote.title}" and content length: ${updatedNote.content.length}');

    await context.read<NotesViewModel>().saveNote(updatedNote);
    
    if (mounted) {
      print('NoteEditor: Returning to previous screen');
      Navigator.pop(context);
    }
  }
}
