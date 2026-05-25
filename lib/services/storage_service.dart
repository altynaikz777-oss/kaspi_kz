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
    print(
      'Avatar upload started via putData: path=${ref.fullPath}, bytes=${data.length}',
    );
    try {
      final snapshot = await ref.putData(
        data,
        SettableMetadata(
          contentType: 'image/jpeg',
          cacheControl: 'public,max-age=3600',
        ),
      );
      print(
        'Avatar upload completed via putData: path=${ref.fullPath}, state=${snapshot.state}',
      );
      final downloadUrl = await ref.getDownloadURL();
      print('Avatar download URL retrieved: $downloadUrl');
      return downloadUrl;
    } on FirebaseException catch (error) {
      print(
        'FirebaseStorageException during putData: code=${error.code}, message=${error.message}',
      );
      rethrow;
    } catch (error) {
      print('Avatar upload exception during putData: $error');
      rethrow;
    }
  }

  Future<String> uploadProfilePhotoFile({
    required String uid,
    required File file,
  }) async {
    final ref = _storage.ref(avatarPath(uid));
    print(
      'Avatar upload started via putFile: localPath=${file.path}, storagePath=${ref.fullPath}',
    );
    try {
      final snapshot = await ref.putFile(
        file,
        SettableMetadata(
          contentType: 'image/jpeg',
          cacheControl: 'public,max-age=3600',
        ),
      );
      print(
        'Avatar upload completed via putFile: path=${ref.fullPath}, state=${snapshot.state}',
      );
      final downloadUrl = await ref.getDownloadURL();
      print('Avatar download URL retrieved: $downloadUrl');
      return downloadUrl;
    } on FirebaseException catch (error) {
      print(
        'FirebaseStorageException during putFile: code=${error.code}, message=${error.message}',
      );
      rethrow;
    } catch (error) {
      print('Avatar upload exception during putFile: $error');
      rethrow;
    }
  }
}
