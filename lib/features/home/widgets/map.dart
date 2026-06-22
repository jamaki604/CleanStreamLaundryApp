import 'package:clean_stream_laundry_app/logic/parsing/location_parser.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class LocationMap extends StatelessWidget {
  static const LatLng _defaultCenter = LatLng(40.273502, -86.126976);

  final List<Map<String, dynamic>> locations;
  final MapController mapController;
  final LatLng? selectedLocation;
  final double? height;

  const LocationMap({
    super.key,
    required this.locations,
    required this.mapController,
    this.selectedLocation,
    this.height = 300,
  });

  @override
  Widget build(BuildContext context) {
    final markers = LocationParser.parseLocations(locations);
    final initialCenter = selectedLocation ?? _defaultCenter;

    return Card(
      elevation: 5,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.black.withValues(alpha: 0.18),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.20)),
      ),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: FlutterMap(
          mapController: mapController,
          options: MapOptions(
            initialCenter: initialCenter,
            initialZoom: selectedLocation == null ? 7.2 : 15,
            keepAlive: true,
            maxZoom: 15,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'https://cleanstreamlaundry.com/',
              tileProvider: NetworkTileProvider(),
            ),
            MarkerLayer(markers: markers),
          ],
        ),
      ),
    );
  }
}
