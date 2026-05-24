import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  StorageService(this._storage);

  final FirebaseStorage _storage;

  static String avatarPath(String uid) => 'avatars/$uid/profile.jpg';

  Future<String> uploadProfilePhoto({
    required String uid,
    required Uint8List data,
  }) async {
    final ref = _storage.ref(avatarPath(uid));
    await ref.putData(
      data,
      SettableMetadata(
        contentType: 'image/jpeg',
        cacheControl: 'public,max-age=3600',
      ),
    );
    return ref.getDownloadURL();
  }

  Future<String> uploadProfilePhotoFile({
    required String uid,
    required File file,
  }) async {
    final ref = _storage.ref(avatarPath(uid));
    await ref.putFile(
      file,
      SettableMetadata(
        contentType: 'image/jpeg',
        cacheControl: 'public,max-age=3600',
      ),
    );
    return ref.getDownloadURL();
  }
}
