import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

enum PhotoAccessState {
  granted,
  denied,
  permanentlyDenied,
}

class PhotoPermissionService {
  Future<PhotoAccessState> ensureGalleryAccess() async {
    if (kIsWeb) {
      return PhotoAccessState.granted;
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      final photos = await Permission.photos.status;
      if (photos.isGranted || photos.isLimited) {
        return PhotoAccessState.granted;
      }
      final requested = await Permission.photos.request();
      if (requested.isGranted || requested.isLimited) {
        return PhotoAccessState.granted;
      }
      if (requested.isPermanentlyDenied) {
        return PhotoAccessState.permanentlyDenied;
      }

      final storage = await Permission.storage.status;
      if (storage.isGranted) {
        return PhotoAccessState.granted;
      }
      final storageReq = await Permission.storage.request();
      if (storageReq.isGranted) {
        return PhotoAccessState.granted;
      }
      if (storageReq.isPermanentlyDenied || requested.isPermanentlyDenied) {
        return PhotoAccessState.permanentlyDenied;
      }
      return PhotoAccessState.denied;
    }

    final status = await Permission.photos.status;
    if (status.isGranted || status.isLimited) {
      return PhotoAccessState.granted;
    }
    final result = await Permission.photos.request();
    if (result.isGranted || result.isLimited) {
      return PhotoAccessState.granted;
    }
    if (result.isPermanentlyDenied) {
      return PhotoAccessState.permanentlyDenied;
    }
    return PhotoAccessState.denied;
  }

  Future<bool> openSettings() => openAppSettings();
}
