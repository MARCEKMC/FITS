import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../screens/fitsi/fitsi_chat_screen.dart';
import '../../../viewmodel/fitsi_chat_viewmodel.dart';

class FitsiFAB extends StatefulWidget {
  const FitsiFAB({Key? key}) : super(key: key);

  @override
  State<FitsiFAB> createState() => _FitsiFABState();
}

class _FitsiFABState extends State<FitsiFAB> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    
    if (_isExpanded) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _openFitsiChat() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider(
          create: (context) => FitsiChatViewModel(),
          child: const FitsiChatScreen(),
        ),
      ),
    );
    
    if (_isExpanded) {
      _toggleExpansion();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 16,
      right: 16,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Opciones rápidas (cuando está expandido)
          if (_isExpanded) ...[
            _buildQuickActionButton(
              icon: Icons.health_and_safety,
              label: 'Reporte Salud',
              onTap: () {
                _openFitsiChat();
                Future.delayed(const Duration(milliseconds: 500), () {
                  context.read<FitsiChatViewModel>().sendQuickCommand('health_report');
                });
              },
            ),
            const SizedBox(height: 12),
            _buildQuickActionButton(
              icon: Icons.analytics,
              label: 'Productividad',
              onTap: () {
                _openFitsiChat();
                Future.delayed(const Duration(milliseconds: 500), () {
                  context.read<FitsiChatViewModel>().sendQuickCommand('productivity_report');
                });
              },
            ),
            const SizedBox(height: 12),
            _buildQuickActionButton(
              icon: Icons.chat,
              label: 'Chat Completo',
              onTap: _openFitsiChat,
            ),
            const SizedBox(height: 16),
          ],
          
          // FAB principal de Fitsi
          ScaleTransition(
            scale: _scaleAnimation,
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: FloatingActionButton(
                    onPressed: _toggleExpansion,
                    backgroundColor: const Color(0xFF6C5CE7),
                    child: AnimatedRotation(
                      turns: _isExpanded ? 0.125 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _isExpanded ? Icons.close : Icons.psychology,
                              color: Colors.white,
                              size: 20,
                            ),
                            if (!_isExpanded)
                              Text(
                                'Fitsi',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ScaleTransition(
      scale: _animationController,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    color: const Color(0xFF6C5CE7),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Color(0xFF2D3436),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Widget para ser usado en las pantallas principales
class FitsiFloatingButton extends StatelessWidget {
  const FitsiFloatingButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Stack(
      children: [
        FitsiFAB(),
      ],
    );
  }
}
