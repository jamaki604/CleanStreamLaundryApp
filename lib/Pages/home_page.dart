import 'package:clean_stream_laundry_app/Components/base_page.dart';
import 'package:clean_stream_laundry_app/Components/large_button.dart';
import 'package:clean_stream_laundry_app/Logic/Theme/theme.dart';
import 'package:clean_stream_laundry_app/Middleware/database_service.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  String? selectedName;
  late final Map<String,int> locationID = {};
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
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.black87,
                                ),
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
                                    style: TextStyle(
                                        fontSize: 18,
                                    color: Theme.of(context).colorScheme.fontSecondary),
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

                    final machineIdle = snapshot.data![0];
                    final totalMachine = snapshot.data![0];

                    return LargeButton(
                      headLineText: "$totalMachine available",
                      descripitionText: "$totalMachine/$machineIdle washers",
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

                    final machineIdle = snapshot.data![0];
                    final totalMachine = snapshot.data![0];

                    return LargeButton(
                      headLineText: "$totalMachine available",
                      descripitionText: "$totalMachine/$machineIdle dryers",
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