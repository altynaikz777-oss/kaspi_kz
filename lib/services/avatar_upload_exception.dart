class AvatarUploadException implements Exception {
  const AvatarUploadException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => message;
}
