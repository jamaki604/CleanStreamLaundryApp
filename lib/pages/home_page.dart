import 'dart:async';
import 'package:clean_stream_laundry_app/logic/parsing/location_parser.dart';
import 'package:clean_stream_laundry_app/widgets/base_page.dart';
import 'package:clean_stream_laundry_app/logic/services/location_service.dart';
import 'package:clean_stream_laundry_app/logic/services/machine_service.dart';
import 'package:clean_stream_laundry_app/logic/theme/theme.dart';
import 'package:clean_stream_laundry_app/middleware/storage_service.dart';
import 'package:clean_stream_laundry_app/logic/services/profile_service.dart';
import 'package:clean_stream_laundry_app/logic/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  static const pageKey = Key("home_page");

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  String? selectedName;
  String? username;
  Map<String, dynamic>? balance;
  late final Map<String, int> locationID = {};
  late final Map<String, LatLng> locationCoordinates = {};
  bool locationSelected = false;
  late int? locationIDSelected;
  late StorageService storage;
  late final MapController _mapController;


  final authService = GetIt.instance<AuthService>();
  final profileService = GetIt.instance<ProfileService>();

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _initStorage();
    _loadUserData();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _initStorage() async {
    storage = StorageService();
    await storage.init();

    String? lastVal = await storage.getValue("lastSelectedLocation");
    setState(() {
      selectedName = lastVal;
    });
  }

  void _zoomToLocation(String locationName) {
    if (locationCoordinates.containsKey(locationName)) {
      final coords = locationCoordinates[locationName]!;
      _mapController.move(coords, 15.0);
    }
  }

  void _loadUserData() async {
    final userId = authService.getCurrentUserId;
    if (userId == null) return;

    final loadedUsername = await profileService.getUserNameById(userId);
    final loadedBalance = await profileService.getUserBalanceById(userId);

    if (mounted) {
      setState(() {
        username = loadedUsername;
        balance = loadedBalance;
      });
    }
  }

  final machineService = GetIt.instance<MachineService>();
  final locationService = GetIt.instance<LocationService>();

  @override
  Widget build(BuildContext context) {
    return BasePage(
      key: HomePage.pageKey,
      body: Padding(
        padding: const EdgeInsets.all(4.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                username == null
                    ? "Welcome!"
                    : "Welcome $username!",

                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                  color: Theme.of(context).colorScheme.fontInverted,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                "Current balance: \$${balance?["balance"] ?? 'Loading...'}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Theme.of(context).colorScheme.fontInverted,
                ),
              ),

              const SizedBox(height: 10),

              FutureBuilder(
                future: locationService.getLocations(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container(
                      height: 400,
                      width: 400,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey.shade400,
                          width: 1,
                        ),
                      ),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final locations = snapshot.data ?? [];
                  final markers = LocationParser.parseLocations(locations);

                  for (var location in locations) {
                    if (location["Address"] != null &&
                        location["Latitude"] != null &&
                        location["Longitude"] != null) {
                      locationCoordinates[location["Address"]] = LatLng(
                        location["Latitude"],
                        location["Longitude"],
                      );
                    }
                  }

                  LatLng initialCenter = LatLng(40.273502, -86.126976);
                  double initialZoom = 7.2;

                  return Container(
                    height: 400,
                    width: 400,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade400, width: 1),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: initialCenter,
                        initialZoom: initialZoom,
                        keepAlive: true,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName:
                              'https://cleanstreamlaundry.com/',
                          tileProvider: NetworkTileProvider(),
                        ),
                        MarkerLayer(markers: markers),
                      ],
                    ),
                  );
                },
              ),
              Container(
                margin: EdgeInsets.only(top: 20),
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade400, width: 1),
                  color: Theme.of(context).colorScheme.cardSecondary,
                ),
                child: Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.blue, size: 28),
                    SizedBox(width: 8),
                    Expanded(
                      child: FutureBuilder(
                        future: Future.wait([locationService.getLocations()]),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          final data = snapshot.data![0];
                          for (var item in data) {
                            locationID[item["Address"]] = item["id"];
                          }

                          if (selectedName != null &&
                              locationID.containsKey(selectedName!) &&
                              !locationSelected) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              setState(() {
                                locationSelected = true;
                                locationIDSelected = locationID[selectedName!];
                              });
                              _zoomToLocation(selectedName!);
                            });
                          }

                          return DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: locationID.containsKey(selectedName)
                                  ? selectedName
                                  : null,
                              hint: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "Select Location",
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.fontInverted,
                                  ),
                                ),
                              ),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  storage.setValue(
                                    "lastSelectedLocation",
                                    newValue,
                                  );
                                  _zoomToLocation(newValue);
                                }
                                setState(() {
                                  selectedName = newValue;
                                  locationSelected = true;
                                  locationIDSelected = locationID[newValue];
                                });
                              },
                              items: locationID.entries.map((entry) {
                                return DropdownMenuItem<String>(
                                  value: entry.key,
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      entry.key,
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.fontInverted,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              if (locationSelected)
                FutureBuilder(
                  future: Future.wait([
                    machineService.getWasherCountByLocation(
                      locationIDSelected.toString(),
                    ),
                    machineService.getIdleWasherCountByLocation(
                      locationIDSelected.toString(),
                    ),
                    machineService.getDryerCountByLocation(
                      locationIDSelected.toString(),
                    ),
                    machineService.getIdleDryerCountByLocation(
                      locationIDSelected.toString(),
                    ),
                  ]),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }

                    final totalWashers = snapshot.data![0];
                    final idleWashers = snapshot.data![1];
                    final totalDryers = snapshot.data![2];
                    final idleDryers = snapshot.data![3];

                    return Container(
                      width: 520,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blue, width: 3),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.transparent,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            height: 45,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.blue,
                                  width: 2,
                                ),
                              ),
                            ),
                            child: Text(
                              "Availability",
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.fontSecondary,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          SizedBox(
                            height: 80,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "$idleWashers/$totalWashers Washers",
                                        style: TextStyle(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.fontSecondary,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      const Icon(
                                        Icons.local_laundry_service,
                                        color: Colors.blue,
                                        size: 36,
                                      ),
                                    ],
                                  ),
                                ),

                                Container(width: 2, color: Colors.blue),

                                Expanded(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "$idleDryers/$totalDryers Dryers",
                                        style: TextStyle(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.fontSecondary,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      const Icon(
                                        Icons.local_laundry_service,
                                        color: Colors.blue,
                                        size: 36,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
