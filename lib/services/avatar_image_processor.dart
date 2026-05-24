import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// Resizes and compresses avatar photos for Firebase Storage upload.
class AvatarImageProcessor {
  static const int targetSize = 512;
  static const int jpegQuality = 85;

  Uint8List process(Uint8List input) {
    final decoded = img.decodeImage(input);
    if (decoded == null) {
      throw const FormatException('Не удалось обработать выбранное фото');
    }

    final cropped = img.copyResizeCropSquare(
      decoded,
      size: targetSize,
    );
    return Uint8List.fromList(
      img.encodeJpg(cropped, quality: jpegQuality),
    );
  }
}
