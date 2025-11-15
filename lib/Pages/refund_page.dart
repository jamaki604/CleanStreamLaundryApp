import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RefundPage extends StatefulWidget {
  const RefundPage({super.key});

  @override
  State<RefundPage> createState() => _RefundPage();
}

class _RefundPage extends State<RefundPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _reasonController = TextEditingController();

  bool _loading = false;
  String? _selectedItemId;
  List<Map<String, dynamic>> _transactions = [];

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _loadTransactions() async {
    setState(() => _loading = true);
    try {
      final List<dynamic> data = await Supabase.instance.client
          .from('transactions')
          .select('id, amount, created_at')
          .limit(100);

      final rows = data
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      setState(() {
        _transactions = rows;
        _selectedItemId = rows.isNotEmpty ? rows.first['id'].toString() : null;
      });
      print('Loaded ${rows.length} transactions');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load transactions: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transaction Selection')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    if (_transactions.isEmpty) ...[
                      const Text(
                        'No transactions found',
                        style: TextStyle(color: Colors.blueAccent),
                      ),
                      const SizedBox(height: 12),
                    ] else ...[
                      DropdownButtonFormField<String>(
                        value: _selectedItemId,
                        hint: const Text('Choose a transaction'),
                        decoration: const InputDecoration(
                          labelText: 'Select a Transaction',
                          border: OutlineInputBorder(),
                        ),
                        items: _transactions.map((row) {
                          final id = row['id'].toString();
                          final amount = row['amount'];
                          final createdAt = row['created_at'];
                          final amountStr = amount != null
                              ? '${(amount as num).toStringAsFixed(2)}'
                              : '';
                          final label = amount != null
                              ? '$id - $createdAt - \$$amountStr'
                              : id;
                          return DropdownMenuItem<String>(
                            value: id,
                            child: Text(label),
                          );
                        }).toList(),
                        onChanged: (val) =>
                            setState(() => _selectedItemId = val),
                        validator: (v) => (v == null || v.isEmpty)
                            ? 'Please select a transaction'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _reasonController,
                        decoration: const InputDecoration(
                          labelText: 'Reason for refund',
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Please enter a reason'
                            : null,
                      ),
                    ],
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            final reason = _reasonController.text.trim();
                            final txIdStr = _selectedItemId ?? '';
                            dynamic txId;
                            try {
                              txId = int.parse(txIdStr);
                            } catch (_) {
                              txId = txIdStr;
                            }

                            // Get the amount from the selected transaction
                            final selectedTransaction = _transactions
                                .firstWhere(
                                  (row) => row['id'].toString() == txIdStr,
                                  orElse: () => <String, dynamic>{},
                                );
                            final amount =
                                selectedTransaction['amount'] as num?;

                            setState(() => _loading = true);
                            try {
                              await Supabase.instance.client
                                  .from('Refunds')
                                  .insert({
                                    'transaction_id': txId,
                                    'Description': reason,
                                    'Amount': amount,
                                    'created_at': DateTime.now()
                                        .toIso8601String(),
                                  });
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Submitted successfully'),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Submit error: $e')),
                                );
                              }
                            } finally {
                              if (mounted) {
                                setState(() => _loading = false);
                              }
                            }
                          }
                        },
                        child: const Text('Submit'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
