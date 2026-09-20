class SectionModel {
  final int id;
  final int classId;
  final String name;
  final int capacity;
  final String description;

  SectionModel({
    required this.id,
    required this.classId,
    required this.name,
    required this.capacity,
    required this.description,
  });

  factory SectionModel.fromJson(Map<String, dynamic> json) {
    return SectionModel(
      id: json['id'] ?? 0,
      classId: json['classId'] ?? 0,
      name: json['name'] ?? '',
      capacity: json['capacity'] ?? 0,
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'classId': classId,
      'name': name,
      'capacity': capacity,
      'description': description,
    };
  }
}
