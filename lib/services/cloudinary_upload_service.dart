import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../constants/cloudinary_config.dart';
import 'avatar_upload_exception.dart';

class CloudinaryUploadService {
  CloudinaryUploadService({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  Uri get _uploadUri => Uri.https(
    'api.cloudinary.com',
    '/v1_1/${CloudinaryConfig.cloudName}/image/upload',
  );

  Future<String> uploadAvatar({
    required String uid,
    required Uint8List data,
  }) async {
    if (CloudinaryConfig.cloudName == 'YOUR_CLOUDINARY_CLOUD_NAME' ||
        CloudinaryConfig.uploadPreset == 'YOUR_UNSIGNED_UPLOAD_PRESET') {
      throw const AvatarUploadException(
        'Cloudinary не настроен. Укажите cloudName и uploadPreset.',
        code: 'cloudinary-config-missing',
      );
    }

    final request = http.MultipartRequest('POST', _uploadUri)
      ..fields['upload_preset'] = CloudinaryConfig.uploadPreset
      ..fields['public_id'] =
          'avatar_${uid}_${DateTime.now().millisecondsSinceEpoch}'
      ..files.add(
        http.MultipartFile.fromBytes('file', data, filename: 'avatar.jpg'),
      );

    http.StreamedResponse response;
    try {
      response = await _client
          .send(request)
          .timeout(const Duration(seconds: 30));
    } catch (_) {
      throw const AvatarUploadException(
        'Не удалось загрузить фото. Проверьте интернет и попробуйте снова.',
        code: 'cloudinary-network-error',
      );
    }

    final body = await response.stream.bytesToString();
    Map<String, dynamic> payload;
    try {
      payload = body.isEmpty
          ? <String, dynamic>{}
          : jsonDecode(body) as Map<String, dynamic>;
    } on FormatException {
      throw const AvatarUploadException(
        'Cloudinary вернул некорректный ответ. Повторите попытку позже.',
        code: 'cloudinary-invalid-response',
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final errorData = payload['error'];
      final message = errorData is Map<String, dynamic>
          ? errorData['message'] as String?
          : null;
      throw AvatarUploadException(
        message ??
            'Cloudinary вернул ошибку загрузки (${response.statusCode}).',
        code: 'cloudinary-upload-failed',
      );
    }

    final secureUrl = payload['secure_url'] as String?;
    if (secureUrl == null || secureUrl.trim().isEmpty) {
      throw const AvatarUploadException(
        'Cloudinary не вернул secure_url для загруженного фото.',
        code: 'cloudinary-missing-secure-url',
      );
    }

    return secureUrl;
  }
}
