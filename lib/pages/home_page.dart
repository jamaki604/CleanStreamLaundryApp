import 'package:clean_stream_laundry_app/widgets/base_page.dart';
import 'package:clean_stream_laundry_app/logic/services/location_service.dart';
import 'package:clean_stream_laundry_app/logic/services/machine_service.dart';
import 'package:clean_stream_laundry_app/logic/theme/theme.dart';
import 'package:clean_stream_laundry_app/middleware/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  static const pageKey = Key("home_page");

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  String? selectedName;
  late final Map<String,int> locationID = {};
  bool locationSelected = false;
  late int? locationIDSelected;
  late StorageService storage;

  @override
  void initState() {
    super.initState();
    _initStorage();
  }

  Future<void> _initStorage() async {
    storage = StorageService();
    await storage.init();

    String? lastVal = await storage.getValue("lastSelectedLocation");
    setState(() {
      selectedName = lastVal;
    });
  }
  final machineService = GetIt.instance<MachineService>();
  final locationService = GetIt.instance<LocationService>();

  @override
  Widget build(BuildContext context) {

    return BasePage(
      key:HomePage.pageKey,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
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

                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          final data = snapshot.data![0];
                          for (var item in data) {
                            locationID[item["Address"]] = item["id"];
                          }

                          if (selectedName != null && locationID.containsKey(selectedName!) && !locationSelected) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              setState(() {
                                locationSelected = true;
                                locationIDSelected = locationID[selectedName!];
                              });
                            });
                          }

                          return DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: selectedName,
                              hint: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "Select Location",
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Theme.of(context).colorScheme.fontInverted,
                                  ),
                                ),
                              ),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  storage.setValue("lastSelectedLocation", newValue);
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
                                        color: Theme.of(context).colorScheme.fontInverted,
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
              SizedBox(height: 40),
              if (locationSelected)
                FutureBuilder(
                  future: Future.wait([
                    machineService.getWasherCountByLocation(locationIDSelected.toString()),
                    machineService.getIdleWasherCountByLocation(locationIDSelected.toString())
                  ]),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }

                    final totalMachine = snapshot.data![0];
                    final machineIdle = snapshot.data![1];

                    return Container(
                      width: 250,
                      height: 160,
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blue, width: 3),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.transparent,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "$totalMachine available",
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.fontInverted,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              Text(
                                "$machineIdle/$totalMachine washers",
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.fontSecondary,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),

                          Icon(
                            Icons.local_laundry_service,
                            color: Colors.blue,
                            size: 40,
                          ),
                        ],
                      ),
                    );
                  },
                ),

              SizedBox(height: 20),
              if (locationSelected)
                FutureBuilder(
                  future: Future.wait([
                    machineService.getDryerCountByLocation(locationIDSelected.toString()),
                    machineService.getIdleDryerCountByLocation(locationIDSelected.toString())
                  ]),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }

                    final totalMachine = snapshot.data![0];
                    final machineIdle = snapshot.data![1];

                    return Container(
                      width: 250,
                      height: 160,
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blue, width: 3),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.transparent,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "$totalMachine available",
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.fontInverted,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              Text(
                                "$machineIdle/$totalMachine dryers",
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.fontSecondary,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          Icon(
                            Icons.local_laundry_service,
                            color: Colors.blue,
                            size: 40,
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