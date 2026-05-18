import 'package:latlong2/latlong.dart';

class BuildingModel {
  final String name;
  final LatLng location;
  final String? description;
  final String? category;

  const BuildingModel({
    required this.name,
    required this.location,
    this.description,
    this.category,
  });

  factory BuildingModel.fromJson(Map<String, dynamic> json) {
    return BuildingModel(
      name: json['name'] ?? '',
      location: LatLng(
        (json['lat'] as num).toDouble(),
        (json['lng'] as num).toDouble(),
      ),
      description: json['description'],
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'lat': location.latitude,
      'lng': location.longitude,
      'description': description,
      'category': category,
    };
  }
}
