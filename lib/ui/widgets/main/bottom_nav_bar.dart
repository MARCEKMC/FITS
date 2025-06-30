import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final GlobalKey? exportKey; // Permite capturar como imagen

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.exportKey,
  });

  static const _icons = [
    Icons.home_rounded,
    Icons.bolt_rounded,
    Icons.favorite_rounded,
    Icons.person_rounded,
  ];
  static const _labels = [
    'Home',
    'Eficiencia',
    'Salud',
    'Perfil',
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RepaintBoundary(
        key: exportKey,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16), // Más margen para resaltar
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12), // Más padding interno
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12), // Bordes más redondeados
            border: Border.all(color: Colors.black26, width: 1.5), // Borde más visible
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15), // Sombra más intensa
                blurRadius: 20, // Mayor difuminado
                offset: const Offset(0, 6), // Más separación
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.08), // Sombra adicional más sutil
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_icons.length, (i) {
              final selected = i == currentIndex;
              return _NavBarItem(
                icon: _icons[i],
                label: _labels[i],
                selected: selected,
                onTap: () => onTap(i),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? Colors.black87 : Colors.grey[500]; // Colores más contrastantes
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250), // Animación más suave
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), // Más padding
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: selected ? 30 : 26, // Íconos más grandes
              height: selected ? 30 : 26,
              child: Icon(icon, color: color, size: selected ? 30 : 26),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.only(top: 6), // Más separación
              height: selected ? 4 : 3, // Indicador más grueso cuando está seleccionado
              width: selected ? 24 : 0, // Más ancho
              decoration: BoxDecoration(
                color: selected ? Colors.black87 : Colors.transparent,
                borderRadius: BorderRadius.circular(3), // Bordes más redondeados
              ),
            ),
          ],
        ),
      ),
    );
  }
}