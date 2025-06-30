import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodel/secure_notes_viewmodel.dart';

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
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 40),
            
            // Icon
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.lock_outline,
                size: 64,
                color: Colors.blue[600],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Title and description
            const Text(
              'Bóveda Segura',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 12),
            
            Text(
              'Ingresa tu PIN de 4 dígitos para acceder a tus notas seguras',
              style: TextStyle(
                fontSize: 16,
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
            
            const SizedBox(height: 40),
            
            // PIN dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                final isFilled = index < _pin.length;
                
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
            
            // Forgot PIN option
            TextButton(
              onPressed: _attemptCount >= _maxAttempts ? null : _showForgotPinDialog,
              child: Text(
                '¿Olvidaste tu PIN?',
                style: TextStyle(
                  color: _attemptCount >= _maxAttempts ? Colors.grey : Colors.blue[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberButton(String number) {
    return InkWell(
      onTap: _attemptCount >= _maxAttempts ? null : () => _addDigit(number),
      borderRadius: BorderRadius.circular(35),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: _attemptCount >= _maxAttempts ? Colors.grey[300]! : Colors.grey[400]!,
          ),
        ),
        child: Center(
          child: Text(
            number,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: _attemptCount >= _maxAttempts ? Colors.grey[400] : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({required IconData icon, required VoidCallback onPressed}) {
    return InkWell(
      onTap: _attemptCount >= _maxAttempts ? null : onPressed,
      borderRadius: BorderRadius.circular(35),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _attemptCount >= _maxAttempts ? Colors.grey[200] : Colors.grey[100],
        ),
        child: Center(
          child: Icon(
            icon,
            size: 24,
            color: _attemptCount >= _maxAttempts ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
      ),
    );
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

  void _deleteDigit() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
      });
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
