import 'package:clean_stream_laundry_app/logic/parsing/location_parser.dart';
import 'package:clean_stream_laundry_app/logic/services/auth_service.dart';
import 'package:clean_stream_laundry_app/logic/services/location_service.dart';
import 'package:clean_stream_laundry_app/logic/services/machine_service.dart';
import 'package:clean_stream_laundry_app/logic/services/profile_service.dart';
import 'package:clean_stream_laundry_app/core/storage/storage_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePageController extends ChangeNotifier {
  final AuthService authService = GetIt.instance<AuthService>();
  final ProfileService profileService = GetIt.instance<ProfileService>();
  final LocationService locationService = GetIt.instance<LocationService>();
  final MachineService machineService = GetIt.instance<MachineService>();
  final LocationParser locationParser;

  HomePageController({LocationParser? locationParser})
      : locationParser = locationParser ?? LocationParser();

  String? selectedName;
  String? username;
  Map<String, dynamic>? balance;
  final Map<String, int> locationID = {};
  final Map<String, LatLng> locationCoordinates = {};
  List<Map<String, dynamic>> locations = [];
  bool locationSelected = false;
  int? locationIDSelected;
  bool isLoading = true;
  StorageService storage = StorageService();

  void Function(LatLng coords, double zoom)? onZoom;

  Future<void> init() async {
    await Future.wait([_initStorage(), _loadUserData()]);
    await _loadLocations();
    isLoading = false;
    notifyListeners();
  }

  Future<void> _initStorage() async {
    await storage.init();
    final lastVal = await storage.getValue('lastSelectedLocation');
    selectedName = lastVal;
  }

  Future<void> _loadUserData() async {
    final userId = authService.getCurrentUserId;
    if (userId == null) return;
    username = await profileService.getUserNameById(userId);
    balance = await profileService.getUserBalanceById(userId);
  }

  Future<void> _loadLocations() async {
    locations = await locationService.getLocations();

    for (final location in locations) {
      final address = location['Address'];
      final id = location['id'];
      final lat = location['Latitude'];
      final lng = location['Longitude'];

      if (address != null && id != null) locationID[address] = id;
      if (address != null && lat != null && lng != null) {
        locationCoordinates[address] = LatLng(lat as double, lng as double);
      }
    }

    if (selectedName != null && locationID.containsKey(selectedName)) {
      locationSelected = true;
      locationIDSelected = locationID[selectedName!];
    }
  }

  void selectLocation(String address) {
    final id = locationID[address];
    if (id == null) return;

    selectedName = address;
    locationSelected = true;
    locationIDSelected = id;
    storage.setValue('lastSelectedLocation', address);
    notifyListeners();

    if (locationCoordinates.containsKey(address)) {
      onZoom?.call(locationCoordinates[address]!, 15.0);
    }
  }

  Future<void> selectNearestLocation() async {
    final nearest = await locationParser.getNearestLocation(locations);
    if (nearest != null) {
      selectLocation(nearest['Address'] as String);
    }
  }

  Future<List<int>> getMachineCounts() async {
    if (locationIDSelected == null) return [0, 0, 0, 0];
    final id = locationIDSelected.toString();
    return await Future.wait([
      machineService.getWasherCountByLocation(id),
      machineService.getIdleWasherCountByLocation(id),
      machineService.getDryerCountByLocation(id),
      machineService.getIdleDryerCountByLocation(id),
    ]);
  }

  Future<void> openDirectionsFromAddress(String? address) async {
    if (address == null) return;

    final encodedAddress = Uri.encodeComponent(address);
    Uri uri;

    if (kIsWeb) {
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
    }
  }

  void disposeController() {}
}