import 'package:flutter/material.dart';

class WaterTracker extends StatelessWidget {
  final int glasses;
  final int maxGlasses;
  final Function(int) onTapGlass;

  static const int mlPerGlass = 250;

  const WaterTracker({
    super.key,
    required this.glasses,
    this.maxGlasses = 10,
    required this.onTapGlass,
  });

  @override
  Widget build(BuildContext context) {
    final totalMl = glasses * mlPerGlass;
    final totalL = totalMl / 1000;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[100]!,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and Amount
          Row(
            children: [
              const Icon(Icons.water_drop, color: Colors.blueAccent, size: 26),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  "Registra tus vasos de agua tomados",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: Colors.black87,
                  ),
                ),
              ),
              // Counter
              Container(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.blue.withOpacity(0.08),
                  border: Border.all(color: Colors.blue[100]!),
                ),
                child: Column(
                  children: [
                    Text(
                      "$totalMl ml",
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.blueAccent,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      "(${totalL.toStringAsFixed(2)} L)",
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Glasses Row
          SizedBox(
            height: 54,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: maxGlasses,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final filled = i < glasses;
                return GestureDetector(
                  onTap: () => onTapGlass(i + 1),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 36,
                    height: 54,
                    decoration: BoxDecoration(
                      color: filled ? Colors.blueAccent : Colors.white,
                      border: Border.all(
                        color: filled ? Colors.blueAccent : Colors.grey[300]!,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.local_drink,
                      size: 28,
                      color: filled ? Colors.white : Colors.grey[400],
                    ),
                  ),
                );
              },
            ),
          ),
          // Optional: Number of glasses text
          Padding(
            padding: const EdgeInsets.only(top: 7, left: 4),
            child: Text(
              "$glasses/${maxGlasses} vasos",
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}