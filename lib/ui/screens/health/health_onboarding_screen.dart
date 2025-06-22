import 'package:flutter/material.dart';
import '../../../data/models/health_profile.dart';
import 'package:provider/provider.dart';
import '../../../viewmodel/health_viewmodel.dart';

class HealthOnboardingScreen extends StatefulWidget {
  const HealthOnboardingScreen({super.key});

  @override
  State<HealthOnboardingScreen> createState() => _HealthOnboardingScreenState();
}

class _HealthOnboardingScreenState extends State<HealthOnboardingScreen> {
  final _weightCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _targetWeightCtrl = TextEditingController();
  GoalType? _goal;
  String _gender = "male";
  int _age = 25;

  final List<GoalType> _goalOptions = [GoalType.lose, GoalType.maintain, GoalType.gain];

  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _weightCtrl.dispose();
    _heightCtrl.dispose();
    _targetWeightCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    setState(() {
      _error = null;
      _loading = true;
    });
    final weight = double.tryParse(_weightCtrl.text);
    final height = double.tryParse(_heightCtrl.text);
    final targetWeight = double.tryParse(_targetWeightCtrl.text);
    if (weight == null || height == null || targetWeight == null || _goal == null || _age <= 0) {
      setState(() {
        _error = "Completa todos los campos correctamente.";
        _loading = false;
      });
      return;
    }
    final profile = HealthProfile.calculate(
      weight: weight,
      height: height,
      targetWeight: targetWeight,
      goal: _goal!,
      age: _age,
      gender: _gender,
    );
    Provider.of<HealthViewModel>(context, listen: false).profile = profile;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tu objetivo de Salud"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "¿Qué quieres lograr?",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ToggleButtons(
                    isSelected: _goalOptions.map((g) => _goal == g).toList(),
                    onPressed: (i) {
                      setState(() {
                        _goal = _goalOptions[i];
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    selectedColor: Colors.white,
                    fillColor: Colors.black,
                    color: Colors.black,
                    textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    children: const [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 18),
                        child: Text("Perder peso", textAlign: TextAlign.center),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 18),
                        child: Text("Mantener peso", textAlign: TextAlign.center),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 18),
                        child: Text("Ganar peso", textAlign: TextAlign.center),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _weightCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Peso actual (kg)"),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _heightCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Altura (cm)"),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _targetWeightCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Meta de peso (kg)"),
                ),
                const SizedBox(height: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Text("Género:"),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButton<String>(
                            value: _gender,
                            isExpanded: true,
                            items: const [
                              DropdownMenuItem(value: "male", child: Text("Masculino")),
                              DropdownMenuItem(value: "female", child: Text("Femenino")),
                            ],
                            onChanged: (val) {
                              setState(() {
                                if (val != null) _gender = val;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "Edad"),
                      onChanged: (val) {
                        final v = int.tryParse(val);
                        if (v != null && v > 0) setState(() => _age = v);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                if (_error != null)
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 6),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    child: _loading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text("Continuar"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}