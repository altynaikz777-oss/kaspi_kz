class AuthFlowState {
  const AuthFlowState({
    this.phoneNumber = '',
    this.verificationId,
    this.errorMessage,
    this.isSendingCode = false,
    this.isVerifyingCode = false,
    this.isSigningInWithGoogle = false,
    this.codeSent = false,
  });

  final String phoneNumber;
  final String? verificationId;
  final String? errorMessage;
  final bool isSendingCode;
  final bool isVerifyingCode;
  final bool isSigningInWithGoogle;
  final bool codeSent;

  AuthFlowState copyWith({
    String? phoneNumber,
    String? verificationId,
    String? errorMessage,
    bool? isSendingCode,
    bool? isVerifyingCode,
    bool? isSigningInWithGoogle,
    bool? codeSent,
    bool clearError = false,
  }) {
    return AuthFlowState(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      verificationId: verificationId ?? this.verificationId,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      isSendingCode: isSendingCode ?? this.isSendingCode,
      isVerifyingCode: isVerifyingCode ?? this.isVerifyingCode,
      isSigningInWithGoogle:
          isSigningInWithGoogle ?? this.isSigningInWithGoogle,
      codeSent: codeSent ?? this.codeSent,
    );
  }
}
