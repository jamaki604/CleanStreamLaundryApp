import 'dart:async';
import 'package:clean_stream_laundry_app/Logic/Services/payment_service.dart';
import 'package:clean_stream_laundry_app/Logic/Services/edge_function_service.dart';
import 'dart:html' as html show window;
import 'package:get_it/get_it.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StripeService implements PaymentService {
  final edgeFunctionService = GetIt.instance<EdgeFunctionService>();
  Completer<int>? _paymentCompleter;
  bool _channelSubscribed = false;

  late final Stripe _stripeInstance;
  StripeService({required Stripe instance}) {
    _stripeInstance = instance;
  }

  @override
  Future<int> makePayment(double amount) async {
    _paymentCompleter = Completer<int>();

    try {
      // 1️⃣ Ensure channel subscription is ready before redirect
      await _subscribeForPaymentConfirmation();

      // 2️⃣ Create Checkout session via Edge Function
      final response = await edgeFunctionService.runEdgeFunction(
        name: 'createCheckoutSession',
        body: {'amount': (amount * 100).toInt()},
      );

      final url = response?.data['url'];
      if (url == null) return 400;

      // 3️⃣ open Stripe Checkout
      html.window.open(url, '_blank');

      // 4️⃣ Wait for broadcast from webhook (with timeout)
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

    // If user is not logged in yet, wait for auth
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

    // Start the channel only once
    if (!_channelSubscribed) {
      await _startPaymentChannel();
      _channelSubscribed = true;
    }
  }

  Future<void> _startPaymentChannel() async {
    final supabase = Supabase.instance.client;
    final completer = Completer<void>();

    print('🔵 Starting payment channel subscription...');

    supabase.channel('payments')
        .onBroadcast(
      event: 'payment_success',
      callback: (payload) {
        print('🟢 Broadcast received! Full payload: $payload');
        print('🟢 Payload type: ${payload.runtimeType}');
        print('🟢 Payload keys: ${payload.keys}');

        // Try accessing the nested payload
        final nestedPayload = payload['payload'];
        print('🟢 Nested payload: $nestedPayload');
        print('🟢 Nested payload type: ${nestedPayload.runtimeType}');

        if (nestedPayload is Map) {
          final uid = nestedPayload['user_id'];
          print('🟢 Extracted user_id: $uid');
          print('🟢 Current user_id: ${supabase.auth.currentUser?.id}');

          if (uid == supabase.auth.currentUser?.id) {
            print('🟢 User IDs match! Completing payment...');
            if (_paymentCompleter != null && !_paymentCompleter!.isCompleted) {
              _paymentCompleter!.complete(200);
              print('🟢 Payment completer completed with 200');
            }
          }
        }
      },
    )
        .subscribe((status, [error]) {
      print('🔵 Channel status: $status');
      if (status == RealtimeSubscribeStatus.subscribed) {
        print('🟢 Channel subscribed successfully');
        completer.complete();
      } else if (status == RealtimeSubscribeStatus.closed ||
          status == RealtimeSubscribeStatus.channelError) {
        print('🔴 Channel error: $error');
        completer.completeError('Channel subscription failed');
      }
    });

    await completer.future;
  }
}
