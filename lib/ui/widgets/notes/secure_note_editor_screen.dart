import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodel/secure_notes_viewmodel.dart';
import '../../../data/models/secure_note.dart';

class SecureNoteEditorScreen extends StatefulWidget {
  final SecureNote? note;

  const SecureNoteEditorScreen({super.key, this.note});

  @override
  State<SecureNoteEditorScreen> createState() => _SecureNoteEditorScreenState();
}

class _SecureNoteEditorScreenState extends State<SecureNoteEditorScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  
  late SecureNote _currentNote;
  bool _hasChanges = false;
  String _selectedColor = '#FFFFFF';

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
    
    _currentNote = widget.note ?? context.read<SecureNotesViewModel>().createNewSecureNote();
    
    final viewModel = context.read<SecureNotesViewModel>();
    final decryptedContent = widget.note != null 
        ? viewModel.decryptNoteContent(widget.note!)
        : '';
    
    _titleController = TextEditingController(text: _currentNote.title);
    _contentController = TextEditingController(text: decryptedContent ?? '');
    
    _selectedColor = _currentNote.color;
    
    _titleController.addListener(_onTextChanged);
    _contentController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
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
          title: Row(
            children: [
              Icon(
                Icons.lock,
                size: 20,
                color: Colors.green[600],
              ),
              const SizedBox(width: 8),
              const Text(
                'Nota Segura',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          actions: [
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
              // Security notice
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.security,
                      size: 16,
                      color: Colors.green[600],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Esta nota está protegida y encriptada',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Title field
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'Título de la nota segura...',
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
                    hintText: 'Escribe tu contenido seguro aquí...',
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

  Future<bool> _onWillPop() async {
    return await _handleBack();
  }

  Future<bool> _handleBack() async {
    if (!_hasChanges) {
      return true;
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Guardar cambios'),
        content: const Text('¿Quieres guardar los cambios antes de salir?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Descartar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (result == true) {
      await _saveNote();
    }

    return true;
  }

  Future<void> _saveNote() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    
    if (title.isEmpty && content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La nota no puede estar vacía'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final success = await context.read<SecureNotesViewModel>().saveSecureNote(
      title.isEmpty ? 'Sin título' : title,
      content,
      id: widget.note?.id,
      color: _selectedColor,
    );

    if (success) {
      if (mounted) {
        Navigator.pop(context);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al guardar la nota'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
