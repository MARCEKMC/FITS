import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodel/user_viewmodel.dart';
import '../../data/models/user_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _usernameController = TextEditingController();
  final _realNameController = TextEditingController();
  String? _gender;
  DateTime? _birthDate;
  String? _profileType;
  String _region = '';
  String _language = '';

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadExistingProfile();
  }

  void _loadExistingProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userViewModel = Provider.of<UserViewModel>(context, listen: false);
      await userViewModel.loadProfile(user.uid);
      final profile = userViewModel.profile;
      if (profile != null) {
        setState(() {
          _usernameController.text = profile.username;
          _realNameController.text = profile.realName;
          _gender = profile.gender.isNotEmpty ? profile.gender : null;
          _birthDate = profile.birthDate;
          _profileType = profile.profileType.isNotEmpty ? profile.profileType : null;
          _region = profile.region;
          _language = profile.language;
        });
      }
    }
  }

  void _saveProfile(BuildContext context) async {
    setState(() => _loading = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _loading = false);
      return;
    }

    final profile = UserProfile(
      uid: user.uid,
      username: _usernameController.text,
      realName: _realNameController.text,
      gender: _gender ?? '',
      birthDate: _birthDate ?? DateTime.now(),
      profileType: _profileType ?? '',
      region: _region,
      language: _language,
    );

    if (!profile.isReallyComplete) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos obligatorios.')),
      );
      return;
    }

    await Provider.of<UserViewModel>(context, listen: false).setProfile(profile);
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Completa tu perfil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Nombre de usuario'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _realNameController,
              decoration: const InputDecoration(labelText: 'Nombre y apellido reales'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _gender,
              items: const [
                DropdownMenuItem(value: 'Femenino', child: Text('Femenino')),
                DropdownMenuItem(value: 'Masculino', child: Text('Masculino')),
              ],
              onChanged: (v) => setState(() => _gender = v),
              decoration: const InputDecoration(labelText: 'Género'),
            ),
            const SizedBox(height: 16),
            TextField(
              readOnly: true,
              controller: TextEditingController(
                text: _birthDate == null
                    ? ''
                    : '${_birthDate!.day.toString().padLeft(2, '0')}/${_birthDate!.month.toString().padLeft(2, '0')}/${_birthDate!.year}',
              ),
              decoration: InputDecoration(
                labelText: 'Fecha de nacimiento',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _birthDate ?? DateTime(2000),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() => _birthDate = picked);
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _profileType,
              items: const [
                DropdownMenuItem(value: 'Estudiante', child: Text('Estudiante')),
                DropdownMenuItem(value: 'Trabajador', child: Text('Trabajador')),
                DropdownMenuItem(value: 'Ambos', child: Text('Ambos')),
              ],
              onChanged: (v) => setState(() => _profileType = v),
              decoration: const InputDecoration(labelText: 'Perfil'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: TextEditingController(text: _region),
              decoration: const InputDecoration(labelText: 'Región (país)'),
              onChanged: (v) => _region = v,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: TextEditingController(text: _language),
              decoration: const InputDecoration(labelText: 'Idioma'),
              onChanged: (v) => _language = v,
            ),
            const SizedBox(height: 24),
            _loading
                ? const CircularProgressIndicator()
                : SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => _saveProfile(context),
                      child: const Text('Guardar y continuar'),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}