
import 'package:clean_stream_laundry_app/Logic/Parser/transaction_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main(){

  group("Test for TransactionParser",(){

    test("Test that transactions are parsed correctly",(){

      final result = TransactionParser.formatTransaction(({"amount": 2.75, "description": "Dryer", "created_at": "2025-11-12T19:23:24.781326+00:00"}));
      expect(result, "\$2.75 used on Dryer on Nov 12, 2025");
    });

    test("Test that transactions are parsed correctly if descrpition is Loyalty Card",(){

      final result = TransactionParser.formatTransaction(({"amount": 2.75, "description": "Loyalty Card", "created_at": "2025-11-12T19:23:24.781326+00:00"}));
      expect(result, "\$2.75 added to Loyalty Card on Nov 12, 2025");
    });

  });

}