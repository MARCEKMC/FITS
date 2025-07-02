import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/secure_notes_viewmodel.dart';

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
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon más pequeño y minimalista
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.security_outlined,
                size: 40,
                color: Colors.black87,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Title más pequeño
            Text(
              _isConfirming ? 'Confirma tu PIN' : 'Crea un PIN',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 8),
            
            Text(
              _isConfirming 
                  ? 'Ingresa nuevamente tu PIN para confirmarlo'
                  : 'Crea un PIN de 4 dígitos para proteger tus notas seguras',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 32),
            
            // PIN dots más pequeños
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                final currentPin = _isConfirming ? _confirmPin : _pin;
                final isFilled = index < currentPin.length;
                
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isFilled ? Colors.black87 : Colors.grey[300],
                  ),
                );
              }),
            ),
            
            const SizedBox(height: 40),
            
            // Teclado numérico compacto
            Container(
              constraints: const BoxConstraints(maxWidth: 240),
              child: Column(
                children: [
                  // Fila 1-2-3
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildCompactNumberButton('1'),
                      _buildCompactNumberButton('2'),
                      _buildCompactNumberButton('3'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Fila 4-5-6
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildCompactNumberButton('4'),
                      _buildCompactNumberButton('5'),
                      _buildCompactNumberButton('6'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Fila 7-8-9
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildCompactNumberButton('7'),
                      _buildCompactNumberButton('8'),
                      _buildCompactNumberButton('9'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Fila vacío-0-borrar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const SizedBox(width: 50), // Espacio vacío
                      _buildCompactNumberButton('0'),
                      _buildCompactActionButton(
                        icon: Icons.backspace_outlined,
                        onPressed: _deleteDigit,
                      ),
                    ],
                  ),
                ],
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

  // Botón de número compacto
  Widget _buildCompactNumberButton(String number) {
    return InkWell(
      onTap: () => _addDigit(number),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
          color: Colors.white,
        ),
        child: Center(
          child: Text(
            number,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  // Botón de acción compacto
  Widget _buildCompactActionButton({required IconData icon, required VoidCallback onPressed}) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
          color: Colors.white,
        ),
        child: Center(
          child: Icon(
            icon,
            color: Colors.black87,
            size: 20,
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
