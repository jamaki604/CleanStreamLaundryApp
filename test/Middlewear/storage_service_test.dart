import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'mocks.dart';

void main(){

  late StorageServiceMock storageServiceMock;

  group("Storage Service tests",(){

    setUp((){
      storageServiceMock = StorageServiceMock();

      when(() => storageServiceMock.init())
          .thenAnswer((_) async {});

      storageServiceMock.init();
    });

    test("Gets value from storage if a value is set",() async {

      when(() => storageServiceMock.getValue(any()))
          .thenAnswer((_) async => "testLocation");

      expect(await storageServiceMock.getValue("locationLastSelected"), "testLocation");
    });

    test("Returns null if no value is found",() async {

      when(() => storageServiceMock.getValue(any()))
          .thenAnswer((_) async => null);

      expect(await storageServiceMock.getValue("locationLastSelected"), null);
    });

  });

}