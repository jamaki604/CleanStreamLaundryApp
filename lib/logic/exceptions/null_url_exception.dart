class NullUrlException implements Exception {
  final String message;

  NullUrlException(this.message);

  @override
  String toString() => 'NullUrlException: $message';
}
