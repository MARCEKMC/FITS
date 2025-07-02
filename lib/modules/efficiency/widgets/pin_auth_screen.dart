import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/secure_notes_viewmodel.dart';

class PinAuthScreen extends StatefulWidget {
  const PinAuthScreen({super.key});

  @override
  State<PinAuthScreen> createState() => _PinAuthScreenState();
}

class _PinAuthScreenState extends State<PinAuthScreen> {
  String _pin = '';
  bool _isLoading = false;
  int _attemptCount = 0;
  static const int _maxAttempts = 3;

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
        title: const Text(
          'Ingresa tu PIN',
          style: TextStyle(
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
                Icons.lock_outline,
                size: 40,
                color: Colors.black87,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Title más pequeño
            const Text(
              'Bóveda Segura',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 8),
            
            Text(
              'Ingresa tu PIN de 4 dígitos',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            
            if (_attemptCount > 0) ...[
              const SizedBox(height: 16),
              Text(
                'PIN incorrecto. Intentos restantes: ${_maxAttempts - _attemptCount}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            
            const SizedBox(height: 32),
            
            // PIN dots más pequeños
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                final isFilled = index < _pin.length;
                
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
                        onPressed: _removeDigit,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Enlace para "¿Olvidaste tu PIN?"
            TextButton(
              onPressed: _attemptCount >= _maxAttempts ? null : _showForgotPinDialog,
              child: Text(
                '¿Olvidaste tu PIN?',
                style: TextStyle(
                  color: _attemptCount >= _maxAttempts ? Colors.grey : Colors.black87,
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Botón de número compacto
  Widget _buildCompactNumberButton(String number) {
    return InkWell(
      onTap: _attemptCount >= _maxAttempts ? null : () => _addDigit(number),
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
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: _attemptCount >= _maxAttempts ? Colors.grey[400] : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  // Botón de acción compacto
  Widget _buildCompactActionButton({required IconData icon, required VoidCallback onPressed}) {
    return InkWell(
      onTap: _attemptCount >= _maxAttempts ? null : onPressed,
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
            color: _attemptCount >= _maxAttempts ? Colors.grey[400] : Colors.black87,
            size: 20,
          ),
        ),
      ),
    );
  }

  void _removeDigit() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
      });
    }
  }

  void _addDigit(String digit) {
    if (_pin.length < 4) {
      setState(() {
        _pin += digit;
      });
      
      if (_pin.length == 4) {
        _authenticate();
      }
    }
  }



  void _authenticate() async {
    setState(() {
      _isLoading = true;
    });

    final success = await context.read<SecureNotesViewModel>().authenticate(_pin);
    
    setState(() {
      _isLoading = false;
    });

    if (success) {
      if (mounted) {
        Navigator.pop(context);
      }
    } else {
      setState(() {
        _pin = '';
        _attemptCount++;
      });

      if (_attemptCount >= _maxAttempts) {
        _showMaxAttemptsDialog();
      }
    }
  }

  void _showForgotPinDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Olvidaste tu PIN?'),
        content: const Text(
          'Para restablecer tu PIN, todas las notas seguras existentes se eliminarán. '
          '¿Estás seguro de que quieres continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetPin();
            },
            child: const Text(
              'Restablecer',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showMaxAttemptsDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Máximo de intentos alcanzado'),
        content: const Text(
          'Has excedido el número máximo de intentos. Por favor, espera antes de intentar nuevamente.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _resetPin() {
    // TODO: Implement PIN reset functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidad de restablecimiento en desarrollo'),
        backgroundColor: Colors.orange,
      ),
    );
  }
}
