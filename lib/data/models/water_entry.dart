class WaterEntry {
  final String id;
  final String userId;
  final DateTime date;
  final int glasses;

  WaterEntry({
    required this.id,
    required this.userId,
    required this.date,
    required this.glasses,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        // Normaliza la fecha a sólo año/mes/día (sin hora)
        'date': DateTime(date.year, date.month, date.day).toIso8601String(),
        'glasses': glasses,
      };

  static WaterEntry fromMap(Map<String, dynamic> map) => WaterEntry(
        id: map['id'],
        userId: map['userId'],
        date: DateTime.parse(map['date']),
        glasses: map['glasses'],
      );
}