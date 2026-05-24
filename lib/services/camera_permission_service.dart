import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

enum CameraPermissionState {
  granted,
  denied,
  permanentlyDenied,
  restricted,
}

class CameraPermissionService {
  Future<CameraPermissionState> check() async {
    if (kIsWeb) {
      return CameraPermissionState.granted;
    }
    final status = await Permission.camera.status;
    return _mapStatus(status);
  }

  Future<CameraPermissionState> request() async {
    if (kIsWeb) {
      return CameraPermissionState.granted;
    }
    final status = await Permission.camera.request();
    return _mapStatus(status);
  }

  Future<bool> openSettings() => openAppSettings();

  CameraPermissionState _mapStatus(PermissionStatus status) {
    if (status.isGranted || status.isLimited) {
      return CameraPermissionState.granted;
    }
    if (status.isPermanentlyDenied) {
      return CameraPermissionState.permanentlyDenied;
    }
    if (status.isRestricted) {
      return CameraPermissionState.restricted;
    }
    return CameraPermissionState.denied;
  }
}
