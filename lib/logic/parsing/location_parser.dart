import 'package:clean_stream_laundry_app/widgets/map_marker.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class LocationParser {
  final GeolocatorPlatform? geolocator;

  LocationParser({this.geolocator});

  static List<Marker> parseLocations(List<Map<String, dynamic>> locations) {
    List<Marker> markers = [];

    for (var location in locations) {
      if (location.containsKey('Latitude') &&
          location.containsKey('Longitude')) {
        markers.add(
          Marker(
            point: LatLng(
              location['Latitude'].toDouble(),
              location['Longitude'].toDouble(),
            ),
            width: 50,
            height: 50,
            child: MapMarker(),
          ),
        );
      }
    }
    return markers;
  }

  Future<String> determinePosition() async {
    LocationPermission permission;

    // Use injected geolocator if provided (for tests), otherwise use Geolocator
    permission = geolocator != null
        ? await geolocator!.checkPermission()
        : await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = geolocator != null
          ? await geolocator!.requestPermission()
          : await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location Permissions are denied');
      }
    }

    Position position = geolocator != null
        ? await geolocator!.getCurrentPosition()
        : await Geolocator.getCurrentPosition();
    return position.toString();
  }
  Future<List<double>> parseCurrentLocation() async {
    final positionString = await determinePosition();
    final parts = positionString.split(', ');
    final List<double> coords = [];

    coords.add(double.parse(parts[0].split(': ')[1]));
    coords.add(double.parse(parts[1].split(': ')[1]));
    return coords;
  }

  Future<Map<String, dynamic>?> getNearestLocation(
      List<Map<String, dynamic>> locations,
      ) async {
    final coords = await parseCurrentLocation();
    final userLat = coords[0];
    final userLng = coords[1];

    Map<String, dynamic>? nearest;
    double shortestDistance = double.infinity;

    for (var location in locations) {
      if (location.containsKey('Latitude') &&
          location.containsKey('Longitude')) {
        final distance = Geolocator.distanceBetween(
          userLat,
          userLng,
          location['Latitude'].toDouble(),
          location['Longitude'].toDouble(),
        );

        if (distance < shortestDistance) {
          shortestDistance = distance;
          nearest = location;
        }
      }
    }

    return nearest;
  }
}