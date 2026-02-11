class DeliveryTask {
  final int id;
  final String title;
  final bool isCompleted;
  final String? proofImagePath;
  final double? latitude;
  final double? longitude;

  // Constructor
  const DeliveryTask({
    required this.id,
    required this.title,
    required this.isCompleted,
    this.proofImagePath,
    this.latitude,
    this.longitude,
  });

  // Factory constructor untuk membuat instance dari JSON map
  factory DeliveryTask.fromJson(Map<String, dynamic> json) {
    return DeliveryTask(
      id: json['id'],
      title: json['title'],
      isCompleted: json['completed'],
    );
  }

  // Method copyWith untuk membuat salinan objek dengan perubahan tertentu
  DeliveryTask copyWith({
    int? id,
    String? title,
    bool? isCompleted,
    String? proofImagePath,
    double? latitude,
    double? longitude,
  }) {
    return DeliveryTask(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      proofImagePath: proofImagePath ?? this.proofImagePath,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}