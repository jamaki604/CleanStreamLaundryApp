import 'dart:async';
import 'package:clean_stream_laundry_app/logic/services/transaction_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseTransactionService extends TransactionService{

  late final SupabaseClient _client;

  SupabaseTransactionService({required SupabaseClient client}){
    _client = client;
  }

  @override
  Future<List<Map<String, dynamic>>> getTransactionsForUser() async {
    final user = _client.auth.currentUser;
    if (user == null) return [];

    final response = await _client
        .from('transactions')
        .select('id, amount, description, created_at')
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Future<List<Map<String, dynamic>>> getRefundableTransactionsForUser() async {
    final user = _client.auth.currentUser;
    if (user == null) return [];

    final response = await _client
        .from('transactions')
        .select('id, amount, description, created_at')
        .eq('user_id', user.id)
        .neq('requested_refund', true)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Future<void> recordTransaction({
    required double amount,
    required String description,
    required String type,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return;
    }

    await _client.from('transactions').insert({
      'user_id': user.id,
      'amount': amount,
      'description': description,
      'type': type,
    });
  }

  @override
  Future<String?> recordRefundRequest({
    required String transaction_id,
    required String description,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return null;
    }

    final data = await _client
        .from('transactions')
        .select('amount')
        .eq('id', transaction_id)
        .single();

    await _client
        .from('transactions')
        .update({'requested_refund': true})
        .eq('id', transaction_id)
        .select();

    final amount = data['amount'].toString();

    await _client.from('Refunds').insert({
      'user_id': user.id,
      'transaction_id': transaction_id,
      'description': description,
      'amount': amount
    });

    await _client.rpc('increment_user_refund_attempts', params: {'uid': user.id});

    return amount;
  }

  @override
  Future<void> subscribeForPaymentConfirmation( bool channelSubscribed,Completer<int>? paymentCompleter ) async {

    if (_client.auth.currentUser == null) {
      final completer = Completer<void>();
      late final StreamSubscription authSub;

      authSub = _client.auth.onAuthStateChange.listen((data) {
        if (_client.auth.currentUser != null) {
          authSub.cancel();
          completer.complete();
        }
      });

      await completer.future;
    }

    if (!channelSubscribed) {
      await _startPaymentChannel(paymentCompleter);
      channelSubscribed = true;
    }
  }

  Future<void> _startPaymentChannel(Completer<int>? paymentCompleter) async {
    final completer = Completer<void>();

    _client.channel('payments')
        .onBroadcast(
      event: 'payment_success',
      callback: (payload) {
        final nestedPayload = payload['payload'];
        if (nestedPayload is Map) {
          final uid = nestedPayload['user_id'];
          if (uid == _client.auth.currentUser?.id) {
            if (paymentCompleter != null && !paymentCompleter.isCompleted) {
              paymentCompleter.complete(200);
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