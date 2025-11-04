import 'package:clean_stream_laundry_app/Components/BasePage.dart';
import 'package:clean_stream_laundry_app/Components/LargeButton.dart';
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
  final List<String> names = ["Anderson", "Indianapolis"];

  @override
  Widget build(BuildContext context) {
    return BasePage(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
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
                    child: DropdownButtonHideUnderline(
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
                          });
                        },
                        items: names.map((name) {
                          return DropdownMenuItem<String>(
                            value: name,
                            child: Text(
                              name,
                              style: TextStyle(fontSize: 18),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 40),
            MachineAvailabilityButton(
                headLineText: "${DatabaseService.instance.getIdleWasherCountByLocation("1")} available",
                descripitionText: "${DatabaseService.instance.getIdleWasherCountByLocation("1")}/${DatabaseService.instance.getWasherCountByLocation("1")} dryers",
                icon: Icons.dry_cleaning_rounded, onPressed: (){}
            ),
            SizedBox(height:20),
            MachineAvailabilityButton(
                headLineText: "${DatabaseService.instance.getIdleDryerCountByLocation("1")} available",
                descripitionText: "${DatabaseService.instance.getIdleDryerCountByLocation("1")}/${DatabaseService.instance.getDryerCountByLocation("1")} dryers",
                icon: Icons.dry_cleaning_rounded, onPressed: (){}
            )
          ],
        ),
      ),
    );
  }
}