
import 'package:clean_stream_laundry_app/Logic/Parser/machine_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main(){

  group("Test for machine formatter", (){

    test("Given a machine string from the database it properly returns the name",(){
      final result = MachineFormatter.formatMachineType("Dryer 1");
      expect(result, "Dryer");

    });
  });

}