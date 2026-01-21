import 'package:clean_stream_laundry_app/widgets/map_marker.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class LocationParser {
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
            width: 15,
            height: 15,
            child: MapMarker(),
          ),
        );
      }
    }
    return markers;
  }
}
