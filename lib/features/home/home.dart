import 'package:clean_stream_laundry_app/features/home/controller.dart';
import 'package:clean_stream_laundry_app/features/home/widgets/availability_card.dart';
import 'package:clean_stream_laundry_app/features/home/widgets/map.dart';
import 'package:clean_stream_laundry_app/features/home/widgets/location_selector.dart';
import 'package:clean_stream_laundry_app/features/home/widgets/header.dart';
import 'package:clean_stream_laundry_app/features/widgets/base_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  static const pageKey = Key('home_page');

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  late final HomePageController _controller;
  late final MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _controller = HomePageController();
    _controller.onZoom = (coords, zoom) => _mapController.move(coords, zoom);
    _controller.init().catchError((e) => debugPrint('HomePage init error: $e'));
    _controller.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.disposeController();
    _controller.dispose();
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller.isLoading) {
      return BasePage(
        key: HomePage.pageKey,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return BasePage(
      key: HomePage.pageKey,
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compactHeight = constraints.maxHeight < 620;
            final mapHeightFactor = _controller.locationSelected ? 0.48 : 0.54;
            final mapHeight = (constraints.maxHeight * mapHeightFactor).clamp(
              185.0,
              320.0,
            );

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                10,
                compactHeight ? 2 : 4,
                10,
                compactHeight ? 4 : 8,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Header(
                    controller: _controller,
                    onNearestLocationTap: _controller.selectNearestLocation,
                  ),
                  SizedBox(height: compactHeight ? 6 : 8),
                  LocationMap(
                    locations: _controller.locations,
                    mapController: _mapController,
                    selectedLocation: _controller.selectedCoordinates,
                    height: mapHeight,
                  ),
                  LocationSelector(
                    controller: _controller,
                    onGetDirections: () async {
                      if (_controller.selectedName != null) {
                        await _controller.openDirectionsFromAddress(
                          _controller.selectedName,
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Please select a location to get directions!',
                            ),
                          ),
                        );
                      }
                    },
                  ),
                  SizedBox(height: compactHeight ? 8 : 12),
                  if (_controller.locationSelected)
                    AvailabilityCard(controller: _controller),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
