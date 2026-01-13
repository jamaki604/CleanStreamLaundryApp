import 'dart:async';
import 'package:clean_stream_laundry_app/logic/exceptions/null_url_exception.dart';
import 'package:clean_stream_laundry_app/logic/services/payment_service.dart';
import 'package:clean_stream_laundry_app/logic/services/edge_function_service.dart';
import 'dart:html' as html show window;
import 'package:get_it/get_it.dart';
import 'package:clean_stream_laundry_app/logic/services/transaction_service.dart';

class StripeService implements PaymentService {
  final edgeFunctionService = GetIt.instance<EdgeFunctionService>();
  final transactionService = GetIt.instance<TransactionService>();
  Completer<int>? _paymentCompleter;
  bool channelSubscribed = false;

  @override
  Future<void> makePayment(double amount) async {
    _paymentCompleter = Completer<int>();

    try {
      await transactionService.subscribeForPaymentConfirmation(
        channelSubscribed,
        _paymentCompleter,
      );

      final response = await edgeFunctionService.runEdgeFunction(
        name: 'createCheckoutSession',
        body: {'amount': (amount * 100).toInt()},
      );

      final url = response?.data['url'];
      if (url == null) throw NullUrlException("Checkout URL is null");

      final paymentPortal = html.window.open(url, '_blank');

      late Timer closeCheckoutTimer;
      closeCheckoutTimer = Timer.periodic(const Duration(milliseconds: 200), (
        _,
      ) {
        if (paymentPortal.closed!) {
          closeCheckoutTimer.cancel();
          if (!_paymentCompleter!.isCompleted) {
            _paymentCompleter!.complete(400);
            throw Exception("Payment portal was closed before completion");
          }
        }
      });

      await _paymentCompleter!.future
          .timeout(const Duration(minutes: 2), onTimeout: () => 400)
          .whenComplete(() {
            paymentPortal.close();
            closeCheckoutTimer.cancel();
          });
    } catch (e) {
      rethrow;
    }
  }
}
