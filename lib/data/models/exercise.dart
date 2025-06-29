class Exercise {
  final String id;
  final String name;
  final String? description;
  final List<String> primaryMuscles;
  final String? category;
  final List<String> images;

  Exercise({
    required this.id,
    required this.name,
    this.description,
    required this.primaryMuscles,
    this.category,
    required this.images,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) => Exercise(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        description: json['description'] ??
            (json['instructions'] != null && (json['instructions'] as List).isNotEmpty
                ? (json['instructions'] as List).join('\n')
                : null),
        primaryMuscles: (json['primaryMuscles'] as List?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        category: json['category']?.toString(),
        images: (json['images'] as List?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
      );
}