import 'package:flutter/material.dart';

class QuickActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;
  final bool isLarge;

  const QuickActionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.iconColor = Colors.black87,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: isLarge ? 120 : 85,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(isLarge ? 16 : 12),
            child: Row(
              children: [
                Container(
                  width: isLarge ? 56 : 40,
                  height: isLarge ? 56 : 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(isLarge ? 14 : 12),
                  ),
                  child: Icon(
                    icon,
                    size: isLarge ? 28 : 20,
                    color: iconColor,
                  ),
                ),
                SizedBox(width: isLarge ? 16 : 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: isLarge ? 18 : 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                          letterSpacing: 0.2,
                        ),
                      ),
                      SizedBox(height: isLarge ? 4 : 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: isLarge ? 14 : 11,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey[600],
                          letterSpacing: 0.1,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  size: isLarge ? 20 : 16,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
