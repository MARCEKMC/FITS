import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodel/user_viewmodel.dart';
import '../../../data/models/user_profile.dart';
import '../../../data/repositories/user_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

const List<String> regiones = [
  'Argentina', 'Bolivia', 'Chile', 'Colombia', 'Ecuador', 'España', 'México', 'Perú', 'Uruguay', 'Venezuela'
];
const List<String> idiomas = [
  'Español', 'Inglés', 'Portugués', 'Francés', 'Alemán', 'Italiano'
];
const List<String> meses = [
  "ENERO","FEBRERO","MARZO","ABRIL","MAYO","JUNIO","JULIO","AGOSTO","SEPTIEMBRE","OCTUBRE","NOVIEMBRE","DICIEMBRE"
];

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _usernameController = TextEditingController();
  final _realNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  String? _gender;
  DateTime _birthDate = DateTime(2000, 1, 1);
  String? _profileType;
  int _regionIndex = 0;
  int _idiomaIndex = 0;

  int _step = 0;
  bool _loading = false;
  String? _usernameError;

  final List<int> _days = List.generate(31, (i) => i + 1);
  final List<int> _years = List.generate(100, (i) => DateTime.now().year - i);

  void _nextStep() {
    if (_step < 7) {
      setState(() => _step++);
    } else {
      _saveProfile(context);
    }
  }

  void _prevStep() {
    if (_step > 0) setState(() => _step--);
  }

  Future<void> _saveProfile(BuildContext context) async {
    setState(() {
      _loading = true;
      _usernameError = null;
    });
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _loading = false);
      return;
    }

    final userRepo = UserRepository();
    final username = _usernameController.text.trim().toLowerCase();

    // Validación de unicidad de username
    final taken = await userRepo.isUsernameTaken(username);
    if (taken) {
      setState(() {
        _loading = false;
        _usernameError = "Nombre de usuario no disponible";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El nombre de usuario ya existe.')),
      );
      return;
    }

    final profile = UserProfile(
      uid: user.uid,
      username: username,
      realName: "${_realNameController.text.trim()} ${_lastNameController.text.trim()}",
      gender: _gender ?? '',
      birthDate: _birthDate,
      profileType: _profileType ?? '',
      region: regiones[_regionIndex],
      language: idiomas[_idiomaIndex],
    );

    if (!profile.isReallyComplete) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos obligatorios.')),
      );
      return;
    }

    try {
      await userRepo.saveUserProfile(profile);
      await Provider.of<UserViewModel>(context, listen: false).setProfile(profile);
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar perfil: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  Widget _buildDots() {
    return Padding(
      padding: const EdgeInsets.only(top: 36.0, bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(8, (i) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 9, height: 9,
          decoration: BoxDecoration(
            color: i == _step ? Colors.black : Colors.grey[300],
            shape: BoxShape.circle,
          ),
        )),
      ),
    );
  }

  bool _isCurrentStepComplete() {
    switch (_step) {
      case 0: return _usernameController.text.trim().isNotEmpty;
      case 1: return _realNameController.text.trim().isNotEmpty;
      case 2: return _lastNameController.text.trim().isNotEmpty;
      case 3: return _gender != null;
      case 4: return true;
      case 5: return _profileType != null;
      case 6: return true;
      case 7: return true;
      default: return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final fieldWidth = screenW > 360 ? 320.0 : screenW * 0.9;

    final inputDecoration = InputDecoration(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(width: 1.5, color: Colors.black),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(width: 1.5, color: Colors.black),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(width: 2, color: Colors.black),
      ),
      hintStyle: const TextStyle(color: Colors.grey),
      isDense: true,
    );

    Widget stepContent;
    switch (_step) {
      case 0: // NOMBRE DE USUARIO
        stepContent = SizedBox(
          width: fieldWidth,
          child: TextField(
            controller: _usernameController,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            decoration: inputDecoration.copyWith(
              hintText: "Escribe tu nombre de usuario",
              errorText: _usernameError,
            ),
            onChanged: (_) => setState(() => _usernameError = null),
          ),
        );
        break;
      case 1: // NOMBRE
        stepContent = SizedBox(
          width: fieldWidth,
          child: TextField(
            controller: _realNameController,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            decoration: inputDecoration.copyWith(hintText: "Escribe tu nombre"),
            onChanged: (_) => setState(() {}),
          ),
        );
        break;
      case 2: // APELLIDOS
        stepContent = SizedBox(
          width: fieldWidth,
          child: TextField(
            controller: _lastNameController,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            decoration: inputDecoration.copyWith(hintText: "Escribe tus apellidos"),
            onChanged: (_) => setState(() {}),
          ),
        );
        break;
      case 3: // GÉNERO
        stepContent = Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _GenderButton(
              selected: _gender == "Masculino",
              icon: Icons.male,
              label: "HOMBRE",
              onTap: () => setState(() => _gender = "Masculino"),
            ),
            const SizedBox(width: 24),
            _GenderButton(
              selected: _gender == "Femenino",
              icon: Icons.female,
              label: "MUJER",
              onTap: () => setState(() => _gender = "Femenino"),
            ),
          ],
        );
        break;
      case 4: // FECHA DE NACIMIENTO
        stepContent = Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 132,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _MinimalPicker(
                    width: 62,
                    child: CupertinoPicker(
                      scrollController: FixedExtentScrollController(initialItem: _birthDate.day - 1),
                      itemExtent: 38,
                      diameterRatio: 1.15,
                      useMagnifier: true,
                      magnification: 1.12,
                      onSelectedItemChanged: (i) => setState(() => _birthDate = DateTime(
                        _birthDate.year, _birthDate.month, i + 1,
                      )),
                      children: _days.map((d) => Center(child: Text('$d', style: const TextStyle(fontSize: 18)))).toList(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _MinimalPicker(
                    width: 120,
                    child: CupertinoPicker(
                      scrollController: FixedExtentScrollController(initialItem: _birthDate.month - 1),
                      itemExtent: 38,
                      diameterRatio: 1.15,
                      useMagnifier: true,
                      magnification: 1.12,
                      onSelectedItemChanged: (i) => setState(() => _birthDate = DateTime(
                        _birthDate.year, i + 1, _birthDate.day,
                      )),
                      children: List.generate(12, (i) => Center(
                        child: Text(
                          meses[i], style: const TextStyle(fontSize: 18),
                        ),
                      )),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _MinimalPicker(
                    width: 70,
                    child: CupertinoPicker(
                      scrollController: FixedExtentScrollController(initialItem: _years.indexOf(_birthDate.year)),
                      itemExtent: 38,
                      diameterRatio: 1.15,
                      useMagnifier: true,
                      magnification: 1.12,
                      onSelectedItemChanged: (i) => setState(() => _birthDate = DateTime(
                        _years[i], _birthDate.month, _birthDate.day,
                      )),
                      children: _years.map((y) => Center(child: Text('$y', style: const TextStyle(fontSize: 18)))).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
        break;
      case 5: // PERFIL
        final isAmbos = _profileType == "Ambos";
        final isEstudiante = _profileType == "Estudiante";
        final isTrabajador = _profileType == "Trabajador";
        stepContent = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: _PerfilButton(
                label: "ESTUDIANTE",
                selected: isAmbos ? true : (isEstudiante ? true : false),
                onTap: () => setState(() => _profileType = "Estudiante"),
                highlight: isAmbos,
                minimal: true,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: _PerfilButton(
                label: "TRABAJADOR",
                selected: isAmbos ? true : (isTrabajador ? true : false),
                onTap: () => setState(() => _profileType = "Trabajador"),
                highlight: isAmbos,
                minimal: true,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: _PerfilButton(
                label: "AMBOS",
                selected: isAmbos,
                onTap: () => setState(() => _profileType = "Ambos"),
                highlight: isAmbos,
                minimal: true,
              ),
            ),
          ],
        );
        break;
      case 6: // REGIÓN
        stepContent = SizedBox(
          height: 132,
          child: _MinimalPicker(
            width: 230,
            child: CupertinoPicker(
              scrollController: FixedExtentScrollController(initialItem: _regionIndex),
              itemExtent: 38,
              diameterRatio: 1.15,
              useMagnifier: true,
              magnification: 1.12,
              onSelectedItemChanged: (i) => setState(() => _regionIndex = i),
              children: regiones.map((r) => Center(child: Text(r, style: const TextStyle(fontSize: 18)))).toList(),
            ),
          ),
        );
        break;
      case 7: // IDIOMA
        stepContent = SizedBox(
          height: 132,
          child: _MinimalPicker(
            width: 170,
            child: CupertinoPicker(
              scrollController: FixedExtentScrollController(initialItem: _idiomaIndex),
              itemExtent: 38,
              diameterRatio: 1.15,
              useMagnifier: true,
              magnification: 1.12,
              onSelectedItemChanged: (i) => setState(() => _idiomaIndex = i),
              children: idiomas.map((r) => Center(child: Text(r, style: const TextStyle(fontSize: 18)))).toList(),
            ),
          ),
        );
        break;
      default:
        stepContent = const SizedBox.shrink();
    }

    // Titulos para cada paso
    const titles = [
      "NOMBRE DE USUARIO",
      "NOMBRE",
      "APELLIDOS",
      "GÉNERO",
      "FECHA DE NACIMIENTO",
      "PERFIL",
      "REGIÓN",
      "IDIOMA",
    ];

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildDots(),
              const SizedBox(height: 42),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  titles[_step],
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 26,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 34),
              Expanded(
                child: Center(
                  child: stepContent,
                ),
              ),
              if (_loading)
                const Padding(
                  padding: EdgeInsets.only(bottom: 60),
                  child: CircularProgressIndicator(),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(bottom: 36, left: 18, right: 18),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_step > 0)
                        _MinimalArrowButton(
                          icon: Icons.arrow_back_ios_new_rounded,
                          onTap: _prevStep,
                          enabled: true,
                        ),
                      const SizedBox(width: 25),
                      _MinimalArrowButton(
                        icon: Icons.arrow_forward_rounded,
                        onTap: _isCurrentStepComplete() && !_loading ? _nextStep : null,
                        enabled: _isCurrentStepComplete() && !_loading,
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
}

// Botón minimalista para género
class _GenderButton extends StatelessWidget {
  final bool selected;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _GenderButton({
    required this.selected,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 130,
        height: 230,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          border: Border.all(
            color: selected ? Colors.black : Colors.grey[400]!,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(25),
          color: selected ? Colors.black : Colors.white,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 44, color: selected ? Colors.white : Colors.black),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : Colors.black,
                fontSize: 17,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Botón minimalista para perfil — opción centrada y elegante
class _PerfilButton extends StatelessWidget {
  final String label;
  final bool selected;
  final bool highlight;
  final VoidCallback onTap;
  final bool minimal;

  const _PerfilButton({
    required this.label,
    required this.selected,
    this.highlight = false,
    required this.onTap,
    this.minimal = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = highlight
        ? Colors.black
        : (selected ? Colors.black : Colors.transparent);
    final textColor = highlight || selected ? Colors.white : Colors.black;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 260,
        padding: minimal
            ? const EdgeInsets.symmetric(vertical: 16)
            : const EdgeInsets.symmetric(vertical: 13, horizontal: 8),
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          border: Border.all(
            color: selected || highlight ? Colors.black : Colors.grey[400]!,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(15),
          color: color,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: textColor,
              fontStyle: FontStyle.italic,
              fontSize: 18,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }
}

// Picker minimalista sin borde, para fecha, región, idioma
class _MinimalPicker extends StatelessWidget {
  final Widget child;
  final double width;

  const _MinimalPicker({required this.child, this.width = 100});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 120,
      child: child,
    );
  }
}

// Botón flecha minimalista y elegante
class _MinimalArrowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool enabled;

  const _MinimalArrowButton({
    required this.icon,
    this.onTap,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: enabled ? Colors.black : Colors.grey[300],
          boxShadow: enabled
              ? [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))]
              : [],
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 26,
        ),
      ),
    );
  }
}