import 'dart:async';
import 'package:clean_stream_laundry_app/Logic/Services/payment_service.dart';
import 'package:clean_stream_laundry_app/Logic/Services/edge_function_service.dart';
import 'dart:html' as html show window;
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StripeService implements PaymentService {
  final edgeFunctionService = GetIt.instance<EdgeFunctionService>();
  Completer<int>? _paymentCompleter;
  bool _channelSubscribed = false;

  @override
  Future<int> makePayment(double amount) async {
    _paymentCompleter = Completer<int>();

    try {
      await _subscribeForPaymentConfirmation();

      final response = await edgeFunctionService.runEdgeFunction(
        name: 'createCheckoutSession',
        body: {'amount': (amount * 100).toInt()},
      );

      final url = response?.data['url'];
      if (url == null) return 400;

      html.window.open(url, '_blank');

      return _paymentCompleter!.future.timeout(
        const Duration(minutes: 5),
        onTimeout: () => 400,
      );
    } catch (e) {
      return 400;
    }
  }

  Future<void> _subscribeForPaymentConfirmation() async {
    final supabase = Supabase.instance.client;

    if (supabase.auth.currentUser == null) {
      final completer = Completer<void>();
      late final StreamSubscription authSub;

      authSub = supabase.auth.onAuthStateChange.listen((data) {
        if (supabase.auth.currentUser != null) {
          authSub.cancel();
          completer.complete();
        }
      });

      await completer.future;
    }

    if (!_channelSubscribed) {
      await _startPaymentChannel();
      _channelSubscribed = true;
    }
  }

  Future<void> _startPaymentChannel() async {
    final supabase = Supabase.instance.client;
    final completer = Completer<void>();

    supabase.channel('payments')
        .onBroadcast(
      event: 'payment_success',
      callback: (payload) {
        final nestedPayload = payload['payload'];
        if (nestedPayload is Map) {
          final uid = nestedPayload['user_id'];
          if (uid == supabase.auth.currentUser?.id) {
            if (_paymentCompleter != null && !_paymentCompleter!.isCompleted) {
              _paymentCompleter!.complete(200);
            }
          }
        }
      },
    )
        .subscribe((status, [error]) {
      if (status == RealtimeSubscribeStatus.subscribed) {
        completer.complete();
      } else if (status == RealtimeSubscribeStatus.closed ||
          status == RealtimeSubscribeStatus.channelError) {
        completer.completeError('Channel subscription failed');
      }
    });

    await completer.future;
  }
}
