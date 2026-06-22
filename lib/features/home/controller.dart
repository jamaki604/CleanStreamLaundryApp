import 'dart:async';

import 'package:clean_stream_laundry_app/logic/parsing/location_parser.dart';
import 'package:clean_stream_laundry_app/logic/services/auth_service.dart';
import 'package:clean_stream_laundry_app/logic/services/location_service.dart';
import 'package:clean_stream_laundry_app/logic/services/machine_service.dart';
import 'package:clean_stream_laundry_app/logic/services/profile_service.dart';
import 'package:clean_stream_laundry_app/core/storage/storage_service.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePageController extends ChangeNotifier {
  static const _lastSelectedLocationKey = 'lastSelectedLocation';
  static const _locationSelectionModeKey = 'locationSelectionMode';
  static const _manualSelectionMode = 'manual';
  static const _nearestSelectionMode = 'nearest';

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
  String _selectionMode = _nearestSelectionMode;

  void Function(LatLng coords, double zoom)? onZoom;

  LatLng? get selectedCoordinates =>
      selectedName == null ? null : locationCoordinates[selectedName];

  Future<void> init() async {
    await Future.wait([_initStorage(), _loadUserData()]);
    await _loadLocations();
    isLoading = false;
    notifyListeners();
  }

  Future<void> _initStorage() async {
    await storage.init();
    final storedMode = await storage.getValue(_locationSelectionModeKey);
    final lastVal = await storage.getValue(_lastSelectedLocationKey);

    _selectionMode =
        storedMode ??
        (lastVal == null ? _nearestSelectionMode : _manualSelectionMode);
    selectedName = _selectionMode == _manualSelectionMode ? lastVal : null;
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
        locationCoordinates[address] = LatLng(
          (lat as num).toDouble(),
          (lng as num).toDouble(),
        );
      }
    }

    final storedManualLocation = selectedName;
    if (_selectionMode == _manualSelectionMode &&
        storedManualLocation != null &&
        locationID.containsKey(storedManualLocation)) {
      _selectLocationInMemory(
        storedManualLocation,
        mode: _manualSelectionMode,
        shouldNotify: false,
        shouldZoom: false,
      );
      return;
    }

    if (_selectionMode == _manualSelectionMode) {
      selectedName = null;
      locationSelected = false;
      locationIDSelected = null;
      _selectionMode = _nearestSelectionMode;
    }

    if (locationCoordinates.isNotEmpty) {
      await _selectNearestLocation(shouldNotify: false, shouldZoom: false);
    }
  }

  void selectLocation(String address) {
    final selected = _selectLocationInMemory(
      address,
      mode: _manualSelectionMode,
    );
    if (!selected) return;

    unawaited(
      _persistSelection(
        address,
        _manualSelectionMode,
      ).catchError((e) => debugPrint('Unable to save selected location: $e')),
    );
  }

  Future<void> selectNearestLocation() async {
    await _selectNearestLocation();
  }

  Future<void> _selectNearestLocation({
    bool shouldNotify = true,
    bool shouldZoom = true,
  }) async {
    if (locations.isEmpty || locationCoordinates.isEmpty) return;

    Map<String, dynamic>? nearest;
    try {
      nearest = await locationParser.getNearestLocation(locations);
    } catch (e) {
      debugPrint('Unable to select nearest location: $e');
      return;
    }

    if (nearest != null) {
      final address = nearest['Address'] as String?;
      if (address == null) return;

      final selected = _selectLocationInMemory(
        address,
        mode: _nearestSelectionMode,
        shouldNotify: shouldNotify,
        shouldZoom: shouldZoom,
      );
      if (selected) await _persistSelection(address, _nearestSelectionMode);
    }
  }

  bool _selectLocationInMemory(
    String address, {
    required String mode,
    bool shouldNotify = true,
    bool shouldZoom = true,
  }) {
    final id = locationID[address];
    if (id == null) return false;

    selectedName = address;
    locationSelected = true;
    locationIDSelected = id;
    _selectionMode = mode;

    if (shouldZoom && locationCoordinates.containsKey(address)) {
      onZoom?.call(locationCoordinates[address]!, 15.0);
    }

    if (shouldNotify) notifyListeners();
    return true;
  }

  Future<void> _persistSelection(String address, String mode) async {
    await storage.setValue(_locationSelectionModeKey, mode);
    await storage.setValue(_lastSelectedLocationKey, address);
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
