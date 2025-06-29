import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/health_profile.dart';
import '../../../viewmodel/health_viewmodel.dart';
import '../../../viewmodel/user_viewmodel.dart';
import 'food_main_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HealthSurveyScreen extends StatefulWidget {
  const HealthSurveyScreen({super.key});

  @override
  State<HealthSurveyScreen> createState() => _HealthSurveyScreenState();
}

class _HealthSurveyScreenState extends State<HealthSurveyScreen> {
  String? objetivo;
  double? pesoActual;
  double? alturaActual;
  double? metaPeso;
  List<String> enfermedades = [];

  final _pesoController = TextEditingController();
  final _alturaController = TextEditingController();
  final _metaController = TextEditingController();

  bool _loading = false;

  @override
  void dispose() {
    _pesoController.dispose();
    _alturaController.dispose();
    _metaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userVM = Provider.of<UserViewModel>(context, listen: false);
    final user = FirebaseAuth.instance.currentUser;
    final userProfile = userVM.profile;

    // Calcula edad y género automáticamente
    final genero = userProfile?.gender ?? '';
    final edad = userProfile != null
        ? DateTime.now().year - userProfile.birthDate.year
        : 0;

    return Scaffold(
      appBar: AppBar(title: const Text('Encuesta de Alimentación')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: ListView(
                children: [
                  const Text("¿Cuál es tu objetivo?",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Wrap(
                    spacing: 10,
                    children: [
                      ChoiceChip(
                        label: const Text('Ganar peso'),
                        selected: objetivo == 'ganar',
                        onSelected: (_) => setState(() => objetivo = 'ganar'),
                      ),
                      ChoiceChip(
                        label: const Text('Mantener peso'),
                        selected: objetivo == 'mantener',
                        onSelected: (_) => setState(() => objetivo = 'mantener'),
                      ),
                      ChoiceChip(
                        label: const Text('Perder peso'),
                        selected: objetivo == 'perder',
                        onSelected: (_) => setState(() => objetivo = 'perder'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _pesoController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Peso actual (kg)",
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: _alturaController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Altura actual (cm)",
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: _metaController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Meta de peso (kg)",
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 18),
                  ListTile(
                    title: Text('Género: $genero'),
                    trailing: Icon(Icons.info_outline, color: Colors.grey[600]),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Para cambiar tu género, edita tu perfil.')),
                      );
                    },
                  ),
                  ListTile(
                    title: Text('Edad: $edad'),
                    trailing: Icon(Icons.info_outline, color: Colors.grey[600]),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Para cambiar tu fecha de nacimiento, edita tu perfil.')),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  const Text("¿Tienes enfermedades relevantes?",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Wrap(
                    spacing: 8,
                    children: [
                      FilterChip(
                        label: const Text('Diabetes'),
                        selected: enfermedades.contains('Diabetes'),
                        onSelected: (v) {
                          setState(() {
                            v ? enfermedades.add('Diabetes') : enfermedades.remove('Diabetes');
                          });
                        },
                      ),
                      FilterChip(
                        label: const Text('Hipertensión'),
                        selected: enfermedades.contains('Hipertensión'),
                        onSelected: (v) {
                          setState(() {
                            v ? enfermedades.add('Hipertensión') : enfermedades.remove('Hipertensión');
                          });
                        },
                      ),
                      FilterChip(
                        label: const Text('Ninguna'),
                        selected: enfermedades.isEmpty,
                        onSelected: (v) {
                          setState(() {
                            if (v) enfermedades.clear();
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () async {
                      setState(() => _loading = true);

                      if (objetivo == null ||
                          _pesoController.text.isEmpty ||
                          _alturaController.text.isEmpty ||
                          _metaController.text.isEmpty) {
                        setState(() => _loading = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Por favor, completa todos los campos')),
                        );
                        return;
                      }

                      final peso = double.tryParse(_pesoController.text);
                      final altura = double.tryParse(_alturaController.text);
                      final meta = double.tryParse(_metaController.text);

                      if (peso == null || altura == null || meta == null) {
                        setState(() => _loading = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Valores numéricos inválidos')),
                        );
                        return;
                      }

                      final double kcalObjetivo = 24 * peso * (objetivo == 'ganar'
                          ? 1.2
                          : objetivo == 'mantener'
                              ? 1.0
                              : 0.8);

                      final profile = HealthProfile(
                        uid: user?.uid ?? '',
                        objetivo: objetivo!,
                        pesoActual: peso,
                        alturaActual: altura,
                        metaPeso: meta,
                        enfermedades: List<String>.from(enfermedades),
                        edad: edad,
                        genero: genero,
                        kcalObjetivo: kcalObjetivo,
                      );

                      await Provider.of<HealthViewModel>(context, listen: false)
                          .saveProfile(profile);

                      setState(() => _loading = false);
                      if (mounted) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const FoodMainScreen()),
                        );
                      }
                    },
                    child: const Text("Guardar"),
                  ),
                ],
              ),
            ),
    );
  }
}