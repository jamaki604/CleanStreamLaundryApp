import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'mocks.dart';

void main(){

  late MachineCommunicatorMock machineCommunicatorMock;

  group("Machine communicator tests", (){

    setUp((){
      machineCommunicatorMock = MachineCommunicatorMock();
    });

    test("Machine successfully wakes up",() async {

      when(() => machineCommunicatorMock.wakeDevice(any())).thenAnswer((_) async => true);

      final result = await machineCommunicatorMock.wakeDevice('123');

      expect(result, true);
    });

    test("Machine unsuccessfully wakes up",() async {

      when(() => machineCommunicatorMock.wakeDevice(any())).thenAnswer((_) async => false);

      final result = await machineCommunicatorMock.wakeDevice('123');

      expect(result, false);
    });

  });

}