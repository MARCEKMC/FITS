import 'package:flutter/material.dart';
import 'package:fits/data/models/activity.dart';

class AddActivityModal extends StatefulWidget {
  final List<String> categories;
  final DateTime initialDate;
  final Activity? activity; // NUEVO: para editar

  const AddActivityModal({
    Key? key,
    required this.categories,
    required this.initialDate,
    this.activity,
  }) : super(key: key);

  @override
  State<AddActivityModal> createState() => _AddActivityModalState();
}

class _AddActivityModalState extends State<AddActivityModal> {
  final _formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();

  final dateStartController = TextEditingController();
  final timeStartController = TextEditingController();
  final dateEndController = TextEditingController();
  final timeEndController = TextEditingController();

  TimeOfDay? start;
  TimeOfDay? end;
  DateTime? date;
  String? category;
  String priority = "A";
  bool important = false;
  bool reminder = false;

  static const List<String> priorityList = ["S", "A", "B", "C", "D"];
  bool _didInitControllers = false;

  @override
  void initState() {
    super.initState();
    if (widget.activity != null) {
      // Modo edición: carga datos existentes
      final act = widget.activity!;
      titleController.text = act.title;
      date = act.date;
      start = act.start;
      end = act.end;
      category = act.category;
      priority = act.priority;
      important = act.important;
      // Si tienes 'reminder' en tu modelo, asigna aquí si hace falta
    } else {
      // Modo agregar
      date = widget.initialDate;
      category = widget.categories.isNotEmpty ? widget.categories[0] : null;
      start = TimeOfDay.now();
      end = TimeOfDay(hour: (TimeOfDay.now().hour + 1) % 24, minute: 0);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didInitControllers) {
      _updateControllers();
      _didInitControllers = true;
    }
  }

  void _updateControllers() {
    final dateString = "${date!.day.toString().padLeft(2, '0')}/${date!.month.toString().padLeft(2, '0')}/${date!.year}";
    dateStartController.text = dateString;
    dateEndController.text = dateString;
    timeStartController.text = start?.format(context) ?? '';
    timeEndController.text = end?.format(context) ?? '';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: date!,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() {
      date = picked;
      _updateControllers();
    });
  }

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? (start ?? TimeOfDay.now()) : (end ?? TimeOfDay.now()),
    );
    if (picked != null) setState(() {
      if (isStart) {
        start = picked;
      } else {
        end = picked;
      }
      _updateControllers();
    });
  }

  Widget _minimalTextField({
    required String label,
    TextEditingController? controller,
    VoidCallback? onTap,
    bool readOnly = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AbsorbPointer(
        absorbing: onTap != null,
        child: TextFormField(
          controller: controller,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            filled: true,
            fillColor: Colors.grey[100],
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
            hintStyle: const TextStyle(color: Colors.grey),
          ),
          validator: (controller == titleController)
              ? (v) => (v == null || v.trim().isEmpty) ? "Campo obligatorio" : null
              : null,
          readOnly: readOnly,
        ),
      ),
    );
  }

  Widget _minimalDropdown<T>({
    required String label,
    required T value,
    required List<T> items,
    required void Function(T?) onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        filled: true,
        fillColor: Colors.grey[100],
        contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 18),
      ),
      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: Colors.black),
      items: items.map((p) => DropdownMenuItem(value: p, child: Text(p.toString()))).toList(),
      onChanged: onChanged,
    );
  }

  Widget _minimalSwitch({required String label, required bool value, required void Function(bool) onChanged}) {
    return Row(
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        const Spacer(),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.black,
          inactiveThumbColor: Colors.grey[400],
          inactiveTrackColor: Colors.grey[200],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.vertical(top: Radius.circular(22));
    final isEditing = widget.activity != null;
    return Container(
      padding: EdgeInsets.only(
        left: 18,
        right: 18,
        top: 18,
        bottom: MediaQuery.of(context).viewInsets.bottom + 18,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(
                height: 4,
                width: 44,
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(6),
                ),
              )),
              Center(
                child: Text(
                  isEditing ? "Editar actividad" : "Agregar actividad",
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: 0.1),
                ),
              ),
              const SizedBox(height: 16),
              _minimalTextField(
                label: "Título",
                controller: titleController,
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _minimalTextField(
                      label: "Fecha inicio",
                      controller: dateStartController,
                      onTap: _pickDate,
                      readOnly: true,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _minimalTextField(
                      label: "Hora inicio",
                      controller: timeStartController,
                      onTap: () => _pickTime(true),
                      readOnly: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _minimalTextField(
                      label: "Fecha fin",
                      controller: dateEndController,
                      onTap: _pickDate,
                      readOnly: true,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _minimalTextField(
                      label: "Hora fin",
                      controller: timeEndController,
                      onTap: () => _pickTime(false),
                      readOnly: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _minimalDropdown<String>(
                label: "Prioridad",
                value: priority,
                items: priorityList,
                onChanged: (val) => setState(() => priority = val!),
              ),
              const SizedBox(height: 14),
              _minimalDropdown<String>(
                label: "Categoría",
                value: category!,
                items: widget.categories,
                onChanged: (val) => setState(() => category = val),
              ),
              const SizedBox(height: 10),
              _minimalSwitch(
                label: "Asunto importante",
                value: important,
                onChanged: (v) => setState(() => important = v),
              ),
              _minimalSwitch(
                label: "Recordatorio",
                value: reminder,
                onChanged: (v) => setState(() => reminder = v),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        Navigator.pop(
                          context,
                          Activity(
                            title: titleController.text.trim(),
                            start: start!,
                            end: end!,
                            date: date!,
                            category: category!,
                            priority: priority,
                            important: important,
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}