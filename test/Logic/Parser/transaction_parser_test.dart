import 'package:clean_stream_laundry_app/Logic/Parser/transaction_parser.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';


void main(){

  group("Test for TransactionParser",(){

    test("Test that transactions are parsed correctly",(){

      final result = TransactionParser.formatTransaction(({"amount": 2.75, "description": "Dryer", "created_at": DateTime.now().toString()}), "transactionHistory");
      expect(result, "\$2.75 used on Dryer on ${DateFormat("MMM").format(DateTime.now()).toString()} ${DateFormat("dd").format(DateTime.now()).toString()}, ${DateFormat("y").format(DateTime.now()).toString()}");
    });

    test("Test that transactions are parsed correctly if description is Loyalty Card",(){

      final result = TransactionParser.formatTransaction(({"amount": 2.75, "description": "Loyalty Card", "created_at": DateTime.now().toString()}), "transactionHistory");
      expect(result, "\$2.75 added to Loyalty Card on ${DateFormat("MMM").format(DateTime.now()).toString()} ${DateFormat("dd").format(DateTime.now()).toString()}, ${DateFormat("y").format(DateTime.now()).toString()}");
    });

    test("Test that it can format a list of transactions",(){
      final result = TransactionParser.formatTransactionsList([{"amount": 2.75, "description": "Dryer", "created_at": DateTime.now().toString()},{"amount": 4.75, "description": "Washer", "created_at": "2025-11-12T19:23:24.781326+00:00"}], "transactionHistory");
      expect(result[0], "\$2.75 used on Dryer on ${DateFormat("MMM").format(DateTime.now()).toString()} ${DateFormat("dd").format(DateTime.now()).toString()}, ${DateFormat("y").format(DateTime.now()).toString()}");
    });
    
    test("Test for monthly report",(){
      final data = [
        {"amount": 2.75, "description": "washer", "created_at": "2025-11-12T19:23:24.781326+00:00"},
        {"amount": 3.5, "description": "Machine", "created_at": "2025-11-11T23:31:57.39522+00:00"},
        {"amount": 3.5, "description": "Machine", "created_at": "2025-11-11T23:14:48.968499+00:00"},
        {"amount": 10, "description": "Loyalty Card", "created_at": "2025-11-11T23:09:41.410673+00:00"},
        {"amount": 20, "description": "Loyalty Card", "created_at": "2025-11-11T23:07:14.775736+00:00"},
        {"amount": 2.75, "description": "Machine", "created_at": "2025-11-02T16:24:51.685419+00:00"},
        {"amount": 2.75, "description": "dryer", "created_at": "2025-10-28T15:13:24.87605+00:00"},
        {"amount": 2.75, "description": "Machine", "created_at": "2025-10-28T14:27:54.429939+00:00"},
        {"amount": 2.75, "description": "loyalty card", "created_at": "2025-10-28T14:26:21.662999+00:00"},
        {"amount": 2.75, "description": "Machine", "created_at": "2025-10-27T18:06:40.987278+00:00"},
        {"amount": 2.75, "description": "Machine", "created_at": "2025-10-27T00:17:18.01511+00:00"}
      ];

      final result = TransactionParser.getMonthlySums(data);
      expect(result["Oct 2025"]?["directWasher"],0.0);
    });

  });

}