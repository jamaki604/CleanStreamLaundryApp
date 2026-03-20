import 'package:clean_stream_laundry_app/features/home/controller.dart';
import 'package:clean_stream_laundry_app/features/home/widgets/availability_card.dart';
import 'package:clean_stream_laundry_app/features/home/widgets/map.dart';
import 'package:clean_stream_laundry_app/features/home/widgets/location_selector.dart';
import 'package:clean_stream_laundry_app/features/home/widgets/header.dart';
import 'package:clean_stream_laundry_app/widgets/base_page.dart';
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 2.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Header(
                controller: _controller,
                onNearestLocationTap: _controller.selectNearestLocation,
              ),
              const SizedBox(height: 10),
              LocationMap(
                locations: _controller.locations,
                mapController: _mapController,
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
              const SizedBox(height: 14),
              if (_controller.locationSelected)
                AvailabilityCard(controller: _controller),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}