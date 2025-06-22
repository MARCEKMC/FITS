import 'package:flutter/material.dart';
import 'package:fits/data/models/note_entry.dart';

class AddNoteModal extends StatefulWidget {
  final DateTime initialDate;
  final NoteEntry? note;

  const AddNoteModal({
    Key? key,
    required this.initialDate,
    this.note,
  }) : super(key: key);

  @override
  State<AddNoteModal> createState() => _AddNoteModalState();
}

class _AddNoteModalState extends State<AddNoteModal> {
  NoteType noteType = NoteType.nota;
  DateTime noteDate = DateTime.now();
  final TextEditingController contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      noteType = widget.note!.type;
      noteDate = widget.note!.date;
      contentController.text = widget.note!.content;
    } else {
      noteDate = widget.initialDate;
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: noteDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => noteDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.note != null;
    return Container(
      padding: EdgeInsets.only(
        left: 18, right: 18, top: 18,
        bottom: MediaQuery.of(context).viewInsets.bottom + 18,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                height: 4,
                width: 44,
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
            Text(
              isEditing ? "Editar nota o tarea" : "Agregar nota o tarea",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: 0.1),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<NoteType>(
                    value: noteType,
                    items: const [
                      DropdownMenuItem(
                        value: NoteType.nota,
                        child: Text('Nota'),
                      ),
                      DropdownMenuItem(
                        value: NoteType.tarea,
                        child: Text('Tarea'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => noteType = val);
                    },
                    decoration: InputDecoration(
                      labelText: "Tipo",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 18),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: _pickDate,
                    child: AbsorbPointer(
                      child: TextFormField(
                        controller: TextEditingController(
                          text: "${noteDate.day.toString().padLeft(2, '0')}/${noteDate.month.toString().padLeft(2, '0')}/${noteDate.year}",
                        ),
                        decoration: InputDecoration(
                          labelText: "Fecha",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          filled: true,
                          fillColor: Colors.grey[100],
                          contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 18),
                        ),
                        readOnly: true,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: contentController,
              maxLines: 3,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                labelText: "Contenido",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
                hintStyle: const TextStyle(color: Colors.grey),
              ),
              autofocus: true,
              validator: (v) => (v == null || v.trim().isEmpty) ? "Campo obligatorio" : null,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                onPressed: () {
                  if (contentController.text.trim().isNotEmpty) {
                    Navigator.pop(
                      context,
                      NoteEntry(
                        id: widget.note?.id,
                        type: noteType,
                        content: contentController.text.trim(),
                        date: noteDate,
                        completed: widget.note?.completed ?? false,
                        addedAt: widget.note?.addedAt,
                      ),
                    );
                  }
                },
                child: Text(
                  isEditing ? "Guardar cambios" : "Agregar",
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}