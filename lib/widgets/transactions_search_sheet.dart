import 'package:flutter/material.dart';

class TransactionSearchSheet extends StatefulWidget {
  final List<String> transactions;

  const TransactionSearchSheet({
    super.key,
    required this.transactions,
  });

  @override
  State<TransactionSearchSheet> createState() =>
      _TransactionSearchSheetState();
}

class _TransactionSearchSheetState
    extends State<TransactionSearchSheet> {
  late List<String> filtered;
  String query = '';

  @override
  void initState() {
    super.initState();
    filtered = widget.transactions;
  }

  void _filter(String value) {
    setState(() {
      query = value;
      filtered = widget.transactions
          .where((transaction) =>
          transaction.toLowerCase().contains(value.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: SizedBox(
          height: 500,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Search by date...',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: _filter,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (_, index) {
                    final transaction = filtered[index];

                    return ListTile(
                      title: Text(transaction),
                      onTap: () {
                        Navigator.pop(context, transaction);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
