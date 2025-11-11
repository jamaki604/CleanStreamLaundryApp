import '../Logic/Authentication/auth_system.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

Future<List<Map<String, dynamic>>> fetchInfo() async {
  final response = await supabase
      .from('transactions')
      .select('id, amount, created_at');
  return response;
}

class RefundPage extends StatefulWidget {
  late final AuthSystem _auth;

  RefundPage({super.key, required AuthSystem auth}) {
    _auth = auth;
  }

  @override
  State<RefundPage> createState() => _RefundState();
}

class _RefundState extends State<RefundPage> {
  String? _Refund;

  final List<String> _dropdownItems = [];

  @override
  void initState() {
    super.initState();
    _Refund = _dropdownItems.first;

    @override
    Widget build(BuildContext context) {
      return FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchInfo(), // Your Supabase data fetching function
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Text('No products found.');
          } else {
            final List<DropdownMenuItem<String>> dropdownItems = snapshot.data!
                .map((data) {
                  return DropdownMenuItem<String>(
                    value: data['id'].toString(),
                    child: Text(data['washer']! + data['dryer']!),
                  );
                })
                .toList();

            return DropdownButton<String>(
              value: _Refund,
              items: dropdownItems,
              onChanged: (String? newValue) {
                setState(() {
                  _Refund = newValue;
                });
              },
            );
          }
        },
      );
    }
  }
}
