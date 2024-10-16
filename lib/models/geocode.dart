
import 'package:latlong2/latlong.dart';

class GeoCodeData {
  String name;
  LatLng latLng;
  GeoCodeData({
    required this.name,
    required this.latLng,
  });

  factory GeoCodeData.fromJson(Map<String, dynamic> json) {
    return GeoCodeData(
      name: json['name'],
      latLng: LatLng(json['lat'], json['lon']),
    );
  }
}
