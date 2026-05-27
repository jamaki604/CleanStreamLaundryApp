import 'package:clean_stream_laundry_app/logic/parsing/location_parser.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class LocationMap extends StatelessWidget {
  static const LatLng _defaultCenter = LatLng(40.273502, -86.126976);

  final List<Map<String, dynamic>> locations;
  final MapController mapController;
  final LatLng? selectedLocation;
  final double height;

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

    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade400, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
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
    );
  }
}
