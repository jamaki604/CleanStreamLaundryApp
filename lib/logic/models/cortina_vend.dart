class CortinaQuote {
  final int machineId;
  final String machineName;
  final String machineType;
  final String? washerSizeLabel;
  final int amountCents;
  final int dryerMinimumCents;
  final int dryerMaximumCents;
  final int dryerDefaultCents;
  final int dryerIncrementCents;

  const CortinaQuote({
    required this.machineId,
    required this.machineName,
    required this.machineType,
    required this.washerSizeLabel,
    required this.amountCents,
    required this.dryerMinimumCents,
    required this.dryerMaximumCents,
    required this.dryerDefaultCents,
    required this.dryerIncrementCents,
  });

  bool get isDryer => machineType.toLowerCase() == 'dryer';

  factory CortinaQuote.fromJson(Map<String, dynamic> json) {
    final dryer = json['dryer'] as Map<String, dynamic>?;
    return CortinaQuote(
      machineId: (json['machineId'] as num).toInt(),
      machineName: json['machineName'] as String,
      machineType: json['machineType'] as String,
      washerSizeLabel: json['washerSizeLabel'] as String?,
      amountCents: (json['amountCents'] as num).toInt(),
      dryerMinimumCents: (dryer?['minimumCents'] as num?)?.toInt() ?? 25,
      dryerMaximumCents: (dryer?['maximumCents'] as num?)?.toInt() ?? 450,
      dryerDefaultCents: (dryer?['defaultCents'] as num?)?.toInt() ?? 150,
      dryerIncrementCents: (dryer?['incrementCents'] as num?)?.toInt() ?? 25,
    );
  }
}

class CortinaCardSession {
  final String sessionId;
  final String accessToken;
  final String clientSecret;

  const CortinaCardSession({
    required this.sessionId,
    required this.accessToken,
    required this.clientSecret,
  });

  factory CortinaCardSession.fromJson(Map<String, dynamic> json) =>
      CortinaCardSession(
        sessionId: json['sessionId'] as String,
        accessToken: json['accessToken'] as String,
        clientSecret: json['clientSecret'] as String,
      );
}

class CortinaVendReference {
  final String sessionId;
  final String accessToken;

  const CortinaVendReference({
    required this.sessionId,
    required this.accessToken,
  });

  factory CortinaVendReference.fromJson(Map<String, dynamic> json) =>
      CortinaVendReference(
        sessionId: json['sessionId'] as String,
        accessToken: json['accessToken'] as String,
      );
}

class CortinaVendStatus {
  final String status;
  final String? failureMessage;

  const CortinaVendStatus({required this.status, this.failureMessage});

  bool get isSuccessful => status == 'started';
  bool get isTerminalFailure => const {
    'refunded',
    'failed',
    'timed_out',
    'support_required',
  }.contains(status);

  factory CortinaVendStatus.fromJson(Map<String, dynamic> json) =>
      CortinaVendStatus(
        status: json['status'] as String,
        failureMessage: json['failure_message'] as String?,
      );
}
