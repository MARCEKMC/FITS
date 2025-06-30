class SecureNote {
  final String id;
  final String title;
  final String encryptedContent;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String color;

  SecureNote({
    required this.id,
    required this.title,
    required this.encryptedContent,
    required this.createdAt,
    required this.updatedAt,
    this.color = '#FFFFFF',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'encryptedContent': encryptedContent,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'color': color,
    };
  }

  static SecureNote fromMap(Map<String, dynamic> map) {
    return SecureNote(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      encryptedContent: map['encryptedContent'] ?? '',
      createdAt: map['createdAt'] != null 
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null 
          ? DateTime.tryParse(map['updatedAt']) ?? DateTime.now()
          : DateTime.now(),
      color: map['color'] ?? '#FFFFFF',
    );
  }

  SecureNote copyWith({
    String? id,
    String? title,
    String? encryptedContent,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? color,
  }) {
    return SecureNote(
      id: id ?? this.id,
      title: title ?? this.title,
      encryptedContent: encryptedContent ?? this.encryptedContent,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      color: color ?? this.color,
    );
  }
}
