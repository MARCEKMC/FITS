import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodel/secure_notes_viewmodel.dart';

class PinSetupScreen extends StatefulWidget {
  const PinSetupScreen({super.key});

  @override
  State<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen> {
  String _pin = '';
  String _confirmPin = '';
  bool _isConfirming = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isConfirming ? 'Confirmar PIN' : 'Crear PIN',
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 40),
            
            // Icon
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.security,
                size: 64,
                color: Colors.green[600],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Title and description
            Text(
              _isConfirming ? 'Confirma tu PIN' : 'Crea un PIN',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 12),
            
            Text(
              _isConfirming 
                  ? 'Ingresa nuevamente tu PIN para confirmarlo'
                  : 'Crea un PIN de 4 dígitos para proteger tus notas seguras',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 40),
            
            // PIN dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                final currentPin = _isConfirming ? _confirmPin : _pin;
                final isFilled = index < currentPin.length;
                
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isFilled ? Colors.black87 : Colors.grey[300],
                  ),
                );
              }),
            ),
            
            const SizedBox(height: 60),
            
            // Number pad
            Expanded(
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1.2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                ),
                itemCount: 12,
                itemBuilder: (context, index) {
                  if (index == 9) {
                    return const SizedBox(); // Empty space
                  } else if (index == 10) {
                    return _buildNumberButton('0');
                  } else if (index == 11) {
                    return _buildActionButton(
                      icon: Icons.backspace,
                      onPressed: _deleteDigit,
                    );
                  } else {
                    return _buildNumberButton('${index + 1}');
                  }
                },
              ),
            ),
            
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(color: Colors.black87),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberButton(String number) {
    return InkWell(
      onTap: () => _addDigit(number),
      borderRadius: BorderRadius.circular(35),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Center(
          child: Text(
            number,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({required IconData icon, required VoidCallback onPressed}) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(35),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey[100],
        ),
        child: Center(
          child: Icon(
            icon,
            size: 24,
            color: Colors.grey[600],
          ),
        ),
      ),
    );
  }

  void _addDigit(String digit) {
    if (_isConfirming) {
      if (_confirmPin.length < 4) {
        setState(() {
          _confirmPin += digit;
        });
        
        if (_confirmPin.length == 4) {
          _validateAndSetPin();
        }
      }
    } else {
      if (_pin.length < 4) {
        setState(() {
          _pin += digit;
        });
        
        if (_pin.length == 4) {
          setState(() {
            _isConfirming = true;
          });
        }
      }
    }
  }

  void _deleteDigit() {
    if (_isConfirming) {
      if (_confirmPin.isNotEmpty) {
        setState(() {
          _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
        });
      }
    } else {
      if (_pin.isNotEmpty) {
        setState(() {
          _pin = _pin.substring(0, _pin.length - 1);
        });
      }
    }
  }

  void _validateAndSetPin() async {
    if (_pin != _confirmPin) {
      _showError('Los PINs no coinciden. Intenta de nuevo.');
      setState(() {
        _pin = '';
        _confirmPin = '';
        _isConfirming = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final success = await context.read<SecureNotesViewModel>().setInitialPin(_pin);
    
    setState(() {
      _isLoading = false;
    });

    if (success) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PIN creado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      _showError('Error al crear el PIN. Intenta de nuevo.');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
