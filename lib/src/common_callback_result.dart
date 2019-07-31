class CommonCallbackResult {
  final bool isSuccessful;
  final String response;
  final String errorCode;
  final String errorMessage;
  final String iosError;

  CommonCallbackResult(
      {this.isSuccessful,
      this.response,
      this.errorCode,
      this.errorMessage,
      this.iosError});
}
