import 'package:flutter/material.dart';
import '../../../data/models/user_profile.dart';
import '../../../viewmodel/user_viewmodel.dart';

class ProfileTab extends StatefulWidget {
  final UserViewModel userViewModel;

  const ProfileTab({super.key, required this.userViewModel});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late String _selectedGender;
  late String _selectedRegion;
  late String _selectedLanguage;
  late String _selectedProfileType;
  late DateTime _selectedBirthDate;
  bool _isEditing = false;
  bool _isLoading = false;

  final List<String> _genders = ['Masculino', 'Femenino', 'Otro'];
  final List<String> _regions = [
    'España', 'México', 'Argentina', 'Colombia', 'Venezuela', 
    'Perú', 'Chile', 'Ecuador', 'Uruguay', 'Paraguay', 'Bolivia',
    'Costa Rica', 'Panamá', 'Guatemala', 'Honduras', 'El Salvador',
    'Nicaragua', 'República Dominicana', 'Puerto Rico', 'Cuba'
  ];
  final List<String> _languages = ['Español', 'English', 'Português', 'Français'];
  final List<String> _profileTypes = ['Básico', 'Intermedio', 'Avanzado'];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final profile = widget.userViewModel.profile;
    _firstNameController = TextEditingController(text: profile?.firstName ?? '');
    _lastNameController = TextEditingController(text: profile?.lastName ?? '');
    _usernameController = TextEditingController(text: profile?.username ?? '');
    _emailController = TextEditingController(text: profile?.email ?? '');
    
    // Asegurar que los valores iniciales estén en las listas
    _selectedGender = _genders.contains(profile?.gender) ? profile!.gender : _genders.first;
    _selectedRegion = _regions.contains(profile?.region) ? profile!.region : _regions.first;
    _selectedLanguage = _languages.contains(profile?.language) ? profile!.language : _languages.first;
    _selectedProfileType = _profileTypes.contains(profile?.profileType) ? profile!.profileType : _profileTypes.first;
    _selectedBirthDate = profile?.birthDate ?? DateTime.now().subtract(const Duration(days: 365 * 25));
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final updatedProfile = UserProfile(
        uid: widget.userViewModel.profile!.uid,
        username: _usernameController.text.trim(),
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        gender: _selectedGender,
        birthDate: _selectedBirthDate,
        profileType: _selectedProfileType,
        region: _selectedRegion,
        language: _selectedLanguage,
      );

      await widget.userViewModel.setProfile(updatedProfile);
      
      setState(() {
        _isEditing = false;
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil actualizado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar perfil: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.black87,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedBirthDate) {
      setState(() {
        _selectedBirthDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.userViewModel.profile;

    if (profile == null) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.black87),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar y nombre
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[200],
                    child: Icon(
                      Icons.person,
                      size: 60,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    profile.fullName.isNotEmpty ? profile.fullName : 'Sin nombre',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '@${profile.username}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.userViewModel.userAge} años',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),

            // Botón de editar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Información Personal',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                if (!_isEditing)
                  TextButton.icon(
                    onPressed: () => setState(() => _isEditing = true),
                    icon: const Icon(Icons.edit, size: 18, color: Colors.black87),
                    label: const Text(
                      'Editar',
                      style: TextStyle(color: Colors.black87),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // Campos de perfil
            _buildProfileField(
              'Nombres',
              _firstNameController,
              enabled: _isEditing,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Los nombres son requeridos';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            _buildProfileField(
              'Apellidos',
              _lastNameController,
              enabled: _isEditing,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Los apellidos son requeridos';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            _buildProfileField(
              'Correo electrónico',
              _emailController,
              enabled: false, // Email bloqueado según requisitos
              hint: 'El correo electrónico no se puede cambiar',
            ),

            const SizedBox(height: 16),

            _buildProfileField(
              'Nombre de usuario',
              _usernameController,
              enabled: false, // Username bloqueado según requisitos
              hint: 'El nombre de usuario no se puede cambiar',
            ),

            const SizedBox(height: 16),

            _buildDropdownField(
              'Género',
              _selectedGender,
              _genders,
              enabled: _isEditing,
              onChanged: (value) => setState(() => _selectedGender = value!),
            ),

            const SizedBox(height: 16),

            _buildDateField(
              'Fecha de nacimiento',
              _selectedBirthDate,
              enabled: _isEditing,
              onTap: _isEditing ? _selectDate : null,
            ),

            const SizedBox(height: 16),

            _buildDropdownField(
              'Región',
              _selectedRegion,
              _regions,
              enabled: _isEditing,
              onChanged: (value) => setState(() => _selectedRegion = value!),
            ),

            const SizedBox(height: 16),

            _buildDropdownField(
              'Idioma',
              _selectedLanguage,
              _languages,
              enabled: _isEditing,
              onChanged: (value) => setState(() => _selectedLanguage = value!),
            ),

            const SizedBox(height: 16),

            _buildDropdownField(
              'Nivel de experiencia',
              _selectedProfileType,
              _profileTypes,
              enabled: _isEditing,
              onChanged: (value) => setState(() => _selectedProfileType = value!),
            ),

            if (_isEditing) ...[
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () {
                        setState(() => _isEditing = false);
                        _initializeControllers(); // Resetear valores
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Colors.grey),
                      ),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Guardar',
                              style: TextStyle(color: Colors.white),
                            ),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileField(
    String label,
    TextEditingController controller, {
    bool enabled = true,
    String? hint,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          enabled: enabled,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[500]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.black87),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            filled: true,
            fillColor: enabled ? Colors.white : Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(
    String label,
    String value,
    List<String> items, {
    bool enabled = true,
    void Function(String?)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          onChanged: enabled ? onChanged : null,
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(item),
            );
          }).toList(),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.black87),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            filled: true,
            fillColor: enabled ? Colors.white : Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(
    String label,
    DateTime date, {
    bool enabled = true,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12),
              color: enabled ? Colors.white : Colors.grey[50],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${date.day}/${date.month}/${date.year}',
                  style: TextStyle(
                    color: enabled ? Colors.black87 : Colors.grey[600],
                  ),
                ),
                Icon(
                  Icons.calendar_today,
                  color: enabled ? Colors.grey[600] : Colors.grey[400],
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
