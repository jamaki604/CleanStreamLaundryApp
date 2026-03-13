import 'dart:async';
import 'dart:io';
import 'package:clean_stream_laundry_app/logic/parsing/location_parser.dart';
import 'package:clean_stream_laundry_app/widgets/base_page.dart';
import 'package:clean_stream_laundry_app/logic/services/location_service.dart';
import 'package:clean_stream_laundry_app/logic/services/machine_service.dart';
import 'package:clean_stream_laundry_app/logic/theme/theme.dart';
import 'package:clean_stream_laundry_app/middleware/storage_service.dart';
import 'package:clean_stream_laundry_app/logic/services/profile_service.dart';
import 'package:clean_stream_laundry_app/logic/services/auth_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

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

  Future<void> _openDirectionsFromAddress(String? address) async {
    if (address == null) return;

    final encodedAddress = Uri.encodeComponent(address);
    Uri uri;

    if (kIsWeb) {
      // Web fallback
      uri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$encodedAddress',
      );
    } else {
      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
          uri = Uri.parse('google.navigation:q=$encodedAddress');
          break;
        case TargetPlatform.iOS:
          uri = Uri.parse(
            'http://maps.apple.com/?daddr=$encodedAddress&dirflg=d',
          );
          break;
        default:
          uri = Uri.parse(
            'https://www.google.com/maps/dir/?api=1&destination=$encodedAddress',
          );
      }
    }

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not open maps';
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
  final locationParser = LocationParser();

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
                username == null ? "Welcome!" : "Welcome $username!",

                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                  color: Theme.of(context).colorScheme.fontInverted,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      'Current balance: \$${balance?["balance"] != null ? (balance!["balance"] as num).toStringAsFixed(2) : 'Loading...'}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Theme.of(context).colorScheme.fontInverted,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                  InkWell(
                    onTap: () async {
                      final locations = await locationService.getLocations();
                      final nearest = await locationParser.getNearestLocation(
                        locations,
                      );

                      if (nearest != null) {
                        final address = nearest["Address"] as String;
                        setState(() {
                          selectedName = address;
                          locationSelected = true;
                          locationIDSelected = locationID[address];
                        });
                        storage.setValue("lastSelectedLocation", address);
                        _zoomToLocation(address);
                      }
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Find Nearest Location",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                              decoration: TextDecoration.underline,
                              decorationColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 6),
                          SvgPicture.asset(
                            "assets/locationPin.svg",
                            width: 24,
                            height: 24,
                            colorFilter: ColorFilter.mode(
                              Theme.of(context).colorScheme.primary,
                              BlendMode.srcIn,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              FutureBuilder(
                future: locationService.getLocations(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container(
                      height: 400,
                      width: 300,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
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
                    height: 300,
                    width: 400,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade400, width: 1),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: initialCenter,
                        initialZoom: initialZoom,
                        keepAlive: true,
                        maxZoom: 15,
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
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade400, width: 1),
                  color: Theme.of(context).colorScheme.cardSecondary,
                ),
                child: Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.blue, size: 24),
                    SizedBox(width: 8),
                    Expanded(
                      child: FutureBuilder(
                        future: locationService.getLocations(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const SizedBox(
                              height: 24,
                              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                            );
                          }

                          final data = snapshot.data!;
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

                          return GestureDetector(
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                                ),
                                builder: (_) => ListView.separated(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  itemCount: data.length,
                                  separatorBuilder: (_, __) => Divider(height: 1),
                                  itemBuilder: (_, index) {
                                    final item = data[index];
                                    return ListTile(
                                      title: Text(
                                        item["Address"],
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Theme.of(context).colorScheme.fontInverted,
                                        ),
                                      ),
                                      onTap: () {
                                        setState(() {
                                          selectedName = item["Address"];
                                          locationSelected = true;
                                          locationIDSelected = item["id"];
                                        });
                                        storage.setValue("lastSelectedLocation", selectedName!);
                                        _zoomToLocation(selectedName!);
                                        Navigator.pop(context);
                                      },
                                    );
                                  },
                                ),
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 4),
                              child: Text(
                                selectedName ?? "Select Location",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: selectedName == null
                                      ? Colors.grey
                                      : Theme.of(context).colorScheme.fontInverted,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        if (selectedName != null) {
                          await _openDirectionsFromAddress(selectedName);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Please select a location to get directions!")),
                          );
                        }
                      },
                      icon: Icon(Icons.navigation, color: Theme.of(context).primaryColor, size: 24),
                      padding: EdgeInsets.zero, // remove extra padding
                      constraints: BoxConstraints(),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 18),

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
                        borderRadius: BorderRadius.circular(14),
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
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4.0,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Flexible(
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Text(
                                              "$idleWashers/$totalWashers Washers",
                                              style: TextStyle(
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.fontSecondary,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Icon(
                                          Icons.local_laundry_service,
                                          color: Colors.blue,
                                          size: 36,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                Container(width: 2, color: Colors.blue),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4.0,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Flexible(
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Text(
                                              "$idleDryers/$totalDryers Dryers",
                                              style: TextStyle(
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.fontSecondary,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Icon(
                                          Icons.local_laundry_service,
                                          color: Colors.blue,
                                          size: 36,
                                        ),
                                      ],
                                    ),
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
