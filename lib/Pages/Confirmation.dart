import 'package:clean_stream_laundry_app/Components/BasePage.dart';
import 'package:clean_stream_laundry_app/Middleware/DatabaseQueries.dart';
import 'package:flutter/material.dart';
import 'package:clean_stream_laundry_app/Logic/Payment/ProcessPayment.dart';

class ConfirmationPage extends StatefulWidget {
  final String machineId;


  const ConfirmationPage({Key? key, required this.machineId}) : super(key: key);

  @override
  State<ConfirmationPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<ConfirmationPage> {
  bool _isConfirmed = false;
  double? _price;
  String? _machineName;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMachineInfo();
  }

  Future<void> _fetchMachineInfo() async {

    final data = await DatabaseService.instance.getMachineById(widget.machineId);

    if (data != null) {
      setState(() {
        _machineName = data['Name'];
        _price = (data['Price'] as num).toDouble();
        _isLoading = false;
      });
    } else {

      // handle error / machine not found
      setState(() {
        _machineName = 'Unknown';
        _price = 0;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    'Machine ${_machineName}',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.local_laundry_service,
                          size: 80,
                          color: Colors.blue[700],
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Amount Due',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '\$${_price?.toStringAsFixed(2) ?? '0.00'}',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: (_isConfirmed || _price == null || _price == 0)
                    ? null
                    : () => processPayment(context, _price!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: (_isConfirmed || _price == null || _price == 0)
                      ? Colors.grey
                      : Colors.blue,
                  disabledBackgroundColor: Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: _isConfirmed
                    ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
                    : Text(
                  _price != null && _price! > 0
                      ? 'Pay \$${_price!.toStringAsFixed(2)}'
                      : 'Pay',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


}