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

final RegExp usernameRegex = RegExp(r'^[a-zA-Z0-9._-]+$');

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
  String? _mainError;

  final List<int> _days = List.generate(31, (i) => i + 1);
  final List<int> _years = List.generate(100, (i) => DateTime.now().year - i);

  static const List<String> friendlyMessages = [
    "Otras personas te verán y buscarán\npor tu nombre de usuario.",
    "Fitsi te llamará por el nombre\nque pongas en este apartado.",
    "Tus apellidos reales servirán en\nfunciones de la aplicación.",
    "Aquí puedes elegir tu género, lamentamos\nponer solamente dos.",
    "Tu fecha de nacimiento servirá para\nfunciones de la aplicación.",
    "Elige tu perfil para personalizar tu\nexperiencia en Fitsi.",
    "Especificar tu región nos servirá para\nmejorar tu experiencia.",
    "El idioma que escojas es el idioma\nen el que saldrá la aplicación.",
  ];

  static const List<String> profileImages = [
    "lib/core/utils/images/completeprofile1.png",
    "lib/core/utils/images/completeprofile2.png",
    "lib/core/utils/images/completeprofile3.png",
    "lib/core/utils/images/completeprofile4.png",
    "lib/core/utils/images/completeprofile5.png",
    "lib/core/utils/images/completeprofile6.png",
    "lib/core/utils/images/completeprofile7.png",
    "lib/core/utils/images/completeprofile8.png",
  ];

  @override
  void dispose() {
    _usernameController.dispose();
    _realNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _nextStep() async {
    _mainError = null;
    if (_step == 0) {
      setState(() {
        _loading = true;
        _mainError = null;
      });

      final username = _usernameController.text.trim().toLowerCase();

      if (!usernameRegex.hasMatch(username)) {
        setState(() {
          _loading = false;
          _mainError = "Solo letras, números, puntos, guión y guión bajo";
        });
        return;
      }

      final userRepo = UserRepository();
      bool taken = false;
      try {
        taken = await userRepo.isUsernameTaken(username).timeout(const Duration(seconds: 10));
      } catch (e) {
        setState(() {
          _loading = false;
          _mainError = "Error de conexión. Intenta de nuevo.";
        });
        return;
      }

      if (taken) {
        setState(() {
          _loading = false;
          _mainError = "Este nombre de usuario ya está en uso";
        });
        return;
      }

      setState(() {
        _loading = false;
        _step++;
      });
    } else if (_step < 7) {
      if (!_isCurrentStepComplete()) {
        setState(() {
          _mainError = "Completa el campo para continuar";
        });
        return;
      }
      setState(() => _step++);
    } else {
      _saveProfile(context);
    }
  }

  void _prevStep() {
    if (_step > 0) setState(() => _step--);
  }

  void _saveProfile(BuildContext context) async {
    setState(() {
      _loading = true;
      _mainError = null;
    });
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _loading = false;
        _mainError = "No hay usuario autenticado.";
      });
      return;
    }
    final profile = UserProfile(
      uid: user.uid,
      username: _usernameController.text.trim().toLowerCase(),
      firstName: _realNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: user.email ?? '',
      gender: _gender ?? '',
      birthDate: _birthDate,
      profileType: _profileType ?? '',
      region: regiones[_regionIndex],
      language: idiomas[_idiomaIndex],
    );
    if (!profile.isReallyComplete) {
      setState(() {
        _loading = false;
        _mainError = 'Completa todos los campos obligatorios.';
      });
      return;
    }
    await Provider.of<UserViewModel>(context, listen: false).setProfile(profile);
    if (mounted) {
      setState(() => _loading = false);
      Navigator.pushReplacementNamed(context, '/main');
    } else {
      setState(() => _loading = false);
    }
  }

  Widget _buildDots() {
    return Padding(
      padding: const EdgeInsets.only(top: 44, bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(8, (i) => AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: 16,
          height: 6,
          decoration: BoxDecoration(
            color: i == _step ? Colors.black : Colors.transparent,
            border: Border.all(color: Colors.black, width: 1),
            borderRadius: BorderRadius.circular(4),
          ),
        )),
      ),
    );
  }

  bool _isCurrentStepComplete() {
    switch (_step) {
      case 0: return _usernameController.text.trim().isNotEmpty && _mainError == null;
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

  Widget _buildMessageBox(String? text, {bool isError = false}) {
    return Container(
      width: 320,
      constraints: const BoxConstraints(
        minHeight: 68,
        maxHeight: 68,
      ),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
            color: isError ? Colors.red.shade400 : Colors.grey.shade400,
            width: 1),
      ),
      alignment: Alignment.center,
      child: text != null && text.isNotEmpty
          ? Text(
              text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 16,
                color: isError ? Colors.red[700] : Colors.grey[900],
                fontWeight: isError ? FontWeight.w600 : FontWeight.w500,
                fontFamily: 'RobotoMono',
                letterSpacing: 0.2,
                height: 1.22,
              ),
              textAlign: TextAlign.center,
            )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final fieldWidth = screenW > 360 ? 320.0 : screenW * 0.9;

    final inputDecoration = InputDecoration(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(width: 1.5, color: Colors.black),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(width: 1.5, color: Colors.black),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(width: 2, color: Colors.black),
      ),
      hintStyle: const TextStyle(color: Colors.grey),
      isDense: true,
    );

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

    Widget stepContent;
    switch (_step) {
      case 0:
        stepContent = SizedBox(
          width: fieldWidth,
          child: TextField(
            controller: _usernameController,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            decoration: inputDecoration.copyWith(
              hintText: "Escribe tu nombre de usuario",
            ),
            onChanged: (_) => setState(() {
              _mainError = null;
            }),
            enabled: !_loading,
          ),
        );
        break;
      case 1:
        stepContent = SizedBox(
          width: fieldWidth,
          child: TextField(
            controller: _realNameController,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            decoration: inputDecoration.copyWith(hintText: "Escribe tu nombre"),
            onChanged: (_) => setState(() {
              _mainError = null;
            }),
            enabled: !_loading,
          ),
        );
        break;
      case 2:
        stepContent = SizedBox(
          width: fieldWidth,
          child: TextField(
            controller: _lastNameController,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            decoration: inputDecoration.copyWith(hintText: "Escribe tus apellidos"),
            onChanged: (_) => setState(() {
              _mainError = null;
            }),
            enabled: !_loading,
          ),
        );
        break;
      case 3:
        // GÉNERO
        stepContent = SizedBox(
          width: fieldWidth,
          child: Row(
            children: [
              Expanded(
                child: _GenderButton(
                  selected: _gender == "Masculino",
                  icon: Icons.male,
                  label: "MASCULINO",
                  onTap: () => setState(() {
                    _gender = "Masculino";
                    _mainError = null;
                  }),
                  wideShort: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _GenderButton(
                  selected: _gender == "Femenino",
                  icon: Icons.female,
                  label: "FEMENINO",
                  onTap: () => setState(() {
                    _gender = "Femenino";
                    _mainError = null;
                  }),
                  wideShort: true,
                ),
              ),
            ],
          ),
        );
        break;
      case 4:
        // FECHA DE NACIMIENTO - pickers compactos en fieldWidth y centrados
        stepContent = SizedBox(
          width: fieldWidth,
          height: 85,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _MinimalPicker(
                width: 65,
                height: 85,
                child: CupertinoPicker(
                  scrollController: FixedExtentScrollController(initialItem: _birthDate.day - 1),
                  itemExtent: 36,
                  diameterRatio: 1.15,
                  useMagnifier: true,
                  magnification: 1.10,
                  onSelectedItemChanged: (i) => setState(() => _birthDate = DateTime(
                    _birthDate.year, _birthDate.month, i + 1,
                  )),
                  children: _days.map((d) => Center(child: Text('$d', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)))).toList(),
                ),
              ),
              const SizedBox(width: 10),
              _MinimalPicker(
                width: 110,
                height: 85,
                child: CupertinoPicker(
                  scrollController: FixedExtentScrollController(initialItem: _birthDate.month - 1),
                  itemExtent: 36,
                  diameterRatio: 1.15,
                  useMagnifier: true,
                  magnification: 1.10,
                  onSelectedItemChanged: (i) => setState(() => _birthDate = DateTime(
                    _birthDate.year, i + 1, _birthDate.day,
                  )),
                  children: List.generate(12, (i) => Center(
                    child: Text(
                      meses[i], style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                    ),
                  )),
                ),
              ),
              const SizedBox(width: 10),
              _MinimalPicker(
                width: 75,
                height: 85,
                child: CupertinoPicker(
                  scrollController: FixedExtentScrollController(initialItem: _years.indexOf(_birthDate.year)),
                  itemExtent: 36,
                  diameterRatio: 1.15,
                  useMagnifier: true,
                  magnification: 1.10,
                  onSelectedItemChanged: (i) => setState(() => _birthDate = DateTime(
                    _years[i], _birthDate.month, _birthDate.day,
                  )),
                  children: _years.map((y) => Center(child: Text('$y', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)))).toList(),
                ),
              ),
            ],
          ),
        );
        break;
      case 5:
        // PERFIL - Dos arriba y uno centrado abajo, altura reducida, botones más cuadrados
        final isAmbos = _profileType == "Ambos";
        final isEstudiante = _profileType == "Estudiante" || isAmbos;
        final isTrabajador = _profileType == "Trabajador" || isAmbos;
        stepContent = SizedBox(
          width: fieldWidth,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _ProfileCompactButton(
                      label: "ESTUDIANTE",
                      selected: isEstudiante,
                      height: 40,
                      borderRadius: 7,
                      onTap: () => setState(() {
                        _profileType = "Estudiante";
                        _mainError = null;
                      }),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ProfileCompactButton(
                      label: "TRABAJADOR",
                      selected: isTrabajador,
                      height: 40,
                      borderRadius: 7,
                      onTap: () => setState(() {
                        _profileType = "Trabajador";
                        _mainError = null;
                      }),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Spacer(),
                  Expanded(
                    flex: 2,
                    child: _ProfileCompactButton(
                      label: "AMBOS",
                      selected: isAmbos,
                      height: 40,
                      borderRadius: 7,
                      onTap: () => setState(() {
                        _profileType = "Ambos";
                        _mainError = null;
                      }),
                    ),
                  ),
                  Spacer(),
                ],
              ),
            ],
          ),
        );
        break;
      case 6:
        // REGIÓN - picker compacto y alineado
        stepContent = SizedBox(
          width: fieldWidth,
          height: 85,
          child: _MinimalPicker(
            width: fieldWidth,
            height: 85,
            child: CupertinoPicker(
              scrollController: FixedExtentScrollController(initialItem: _regionIndex),
              itemExtent: 36,
              diameterRatio: 1.15,
              useMagnifier: true,
              magnification: 1.10,
              onSelectedItemChanged: (i) => setState(() => _regionIndex = i),
              children: regiones.map((r) => Center(child: Text(r, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)))).toList(),
            ),
          ),
        );
        break;
      case 7:
        // IDIOMA - picker compacto y alineado
        stepContent = SizedBox(
          width: fieldWidth,
          height: 85,
          child: _MinimalPicker(
            width: fieldWidth,
            height: 85,
            child: CupertinoPicker(
              scrollController: FixedExtentScrollController(initialItem: _idiomaIndex),
              itemExtent: 36,
              diameterRatio: 1.15,
              useMagnifier: true,
              magnification: 1.10,
              onSelectedItemChanged: (i) => setState(() => _idiomaIndex = i),
              children: idiomas.map((r) => Center(child: Text(r, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)))).toList(),
            ),
          ),
        );
        break;
      default:
        stepContent = const SizedBox.shrink();
    }

    final bool isError = _mainError != null && _mainError!.isNotEmpty;
    final String? boxMessage = isError ? _mainError : friendlyMessages[_step];

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDots(),
                  const SizedBox(height: 0),
                ],
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 250),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Center(
                        child: Text(
                          titles[_step],
                          style: const TextStyle(
                            fontFamily: 'RobotoMono',
                            fontWeight: FontWeight.w700,
                            fontSize: 22,
                            letterSpacing: 0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Center(child: stepContent),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            // Botones arriba del cuadro de mensajes
            Positioned(
              left: 0,
              right: 0,
              top: 400,
              child: Center(
                child: SizedBox(
                  width: 320,
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: (_step > 0 && !_loading) ? _prevStep : null,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.black),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text(
                            'volver',
                            style: TextStyle(
                              fontFamily: 'RobotoMono',
                              color: Colors.black,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: (_isCurrentStepComplete() && !_loading)
                              ? _nextStep
                              : null,
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                                color: _isCurrentStepComplete()
                                    ? Colors.black
                                    : Colors.grey),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: _loading
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    color: Colors.black,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'siguiente',
                                  style: TextStyle(
                                    fontFamily: 'RobotoMono',
                                    color: Colors.black,
                                    fontSize: 15,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Mensaje fijo
            Positioned(
              left: 0,
              right: 0,
              top: 480,
              child: Center(
                child: _buildMessageBox(boxMessage, isError: isError),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 80),
                child: Image.asset(
                  profileImages[_step.clamp(0, 7)],
                  height: 265,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// BOTÓN DE GÉNERO MODIFICADO (más ancho, bajo y con bordes redondeados)
class _GenderButton extends StatelessWidget {
  final bool selected;
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool wideShort;

  const _GenderButton({
    required this.selected,
    required this.icon,
    required this.label,
    required this.onTap,
    this.wideShort = false,
  });

  @override
  Widget build(BuildContext context) {
    final double height = wideShort ? 60 : 150;
    final double iconSize = wideShort ? 28 : 32;
    final double fontSize = wideShort ? 16 : 15;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: height,
        margin: const EdgeInsets.symmetric(horizontal: 0),
        decoration: BoxDecoration(
          border: Border.all(
            color: selected ? Colors.black : Colors.grey[400]!,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(18),
          color: selected ? Colors.black : Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: iconSize, color: selected ? Colors.white : Colors.black),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : Colors.black,
                fontSize: fontSize,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// BOTÓN DE PERFIL COMPACTO
class _ProfileCompactButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final double height;
  final double borderRadius;

  const _ProfileCompactButton({
    required this.label,
    required this.selected,
    required this.onTap,
    this.height = 36,
    this.borderRadius = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: selected ? Colors.black : Colors.white,
          side: BorderSide(color: Colors.black, width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: EdgeInsets.zero,
        ),
        onPressed: onTap,
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'RobotoMono',
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: selected ? Colors.white : Colors.black,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }
}

class _MinimalPicker extends StatelessWidget {
  final Widget child;
  final double width;
  final double height;

  const _MinimalPicker({
    required this.child,
    this.width = 100,
    this.height = 120,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: child,
    );
  }
}