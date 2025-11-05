import 'package:clean_stream_laundry_app/Components/BasePage.dart';
import 'package:clean_stream_laundry_app/Middleware/DatabaseService.dart';
import 'package:clean_stream_laundry_app/Pages/MachineAvailabilityButton.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? selectedName;
  late final Map<String,int> locationID = Map();
  bool locationSelected = false;
  late int? locationIDSelected;

  @override
  Widget build(BuildContext context) {

    return BasePage(
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
                  color: Colors.grey.shade100,
                ),
                child: Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.blue, size: 28),
                    SizedBox(width: 8),
                    Expanded(
                      child: FutureBuilder(
                        future: Future.wait([DatabaseService.instance.getLocations()]),
                        builder: (context, snapshot) {

                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          final data = snapshot.data![0];
                          for (var item in data) {
                            locationID[item["Address"]] = item["id"];
                          }

                          return DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: selectedName,
                              hint: Text(
                                "Select Location",
                                style: TextStyle(fontSize: 18),
                              ),
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedName = newValue;
                                  locationSelected = true;
                                  locationIDSelected = locationID[newValue];
                                });
                              },
                              items: locationID.entries.map((entry) {
                                return DropdownMenuItem<String>(
                                  value: entry.key,
                                  child: Text(
                                    entry.key,
                                    style: TextStyle(fontSize: 18),
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
                    DatabaseService.instance.getWasherCountByLocation(locationIDSelected.toString()),
                    DatabaseService.instance.getIdleWasherCountByLocation(locationIDSelected.toString())
                  ]),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }

                    final machineIdle = snapshot.data![0] as int;
                    final totalMachine = snapshot.data![0] as int;

                    return MachineAvailabilityButton(
                      headLineText: "${totalMachine} available",
                      descripitionText: "${totalMachine}/${machineIdle} washers",
                      icon: Icons.local_laundry_service,
                      onPressed: () {},
                    );
                  },
                ),
              SizedBox(height: 20),
              if (locationSelected)
                FutureBuilder(
                  future: Future.wait([
                    DatabaseService.instance.getDryerCountByLocation(locationIDSelected.toString()),
                    DatabaseService.instance.getIdleDryerCountByLocation(locationIDSelected.toString())
                  ]),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }

                    final machineIdle = snapshot.data![0] as int;
                    final totalMachine = snapshot.data![0] as int;

                    return MachineAvailabilityButton(
                      headLineText: "${totalMachine} available",
                      descripitionText: "${totalMachine}/${machineIdle} dryer",
                      icon: Icons.local_laundry_service,
                      onPressed: () {},
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