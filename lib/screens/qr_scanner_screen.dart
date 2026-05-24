import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../models/qr_scan_models.dart';
import '../services/camera_permission_service.dart';
import '../widgets/qr_scanner_overlay.dart';

final _scannerFormats = <BarcodeFormat>[
  BarcodeFormat.qrCode,
  BarcodeFormat.code128,
  BarcodeFormat.code39,
  BarcodeFormat.code93,
  BarcodeFormat.ean13,
  BarcodeFormat.ean8,
  BarcodeFormat.upcA,
  BarcodeFormat.upcE,
  BarcodeFormat.dataMatrix,
  BarcodeFormat.pdf417,
  BarcodeFormat.aztec,
  BarcodeFormat.itf,
  BarcodeFormat.codabar,
];

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen>
    with SingleTickerProviderStateMixin {
  final CameraPermissionService _permissionService = CameraPermissionService();
  MobileScannerController? _controller;
  late final AnimationController _scanLineController;

  CameraPermissionState _permission = CameraPermissionState.denied;
  bool _checkingPermission = true;
  bool _torchOn = false;
  bool _torchAvailable = false;
  bool _handledScan = false;

  @override
  void initState() {
    super.initState();
    _scanLineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _initPermission();
  }

  Future<void> _initPermission() async {
    var state = await _permissionService.check();
    if (state == CameraPermissionState.denied) {
      state = await _permissionService.request();
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _permission = state;
      _checkingPermission = false;
    });
    if (state == CameraPermissionState.granted) {
      _startScanner();
    }
  }

  void _startScanner() {
    _controller?.dispose();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      torchEnabled: _torchOn,
      formats: _scannerFormats,
    );
    setState(() {
      _torchAvailable = !kIsWeb;
      _torchOn = false;
    });
  }

  Future<void> _requestPermissionAgain() async {
    setState(() => _checkingPermission = true);
    final state = await _permissionService.request();
    if (!mounted) {
      return;
    }
    setState(() {
      _permission = state;
      _checkingPermission = false;
    });
    if (state == CameraPermissionState.granted) {
      _startScanner();
    }
  }

  Future<void> _openSettings() async {
    await _permissionService.openSettings();
    if (!mounted) {
      return;
    }
    await _initPermission();
  }

  void _close() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handledScan) {
      return;
    }
    for (final barcode in capture.barcodes) {
      final value = barcode.rawValue?.trim();
      if (value == null || value.isEmpty) {
        continue;
      }
      _handledScan = true;
      _controller?.stop();
      final payload = QrScanPayload(
        rawValue: value,
        format: barcode.format,
        scannedAt: DateTime.now(),
      );
      context.pushReplacement('/qr/result', extra: payload);
      return;
    }
  }

  Future<void> _toggleTorch() async {
    final controller = _controller;
    if (controller == null || !_torchAvailable) {
      return;
    }
    await controller.toggleTorch();
    if (!mounted) {
      return;
    }
    setState(() => _torchOn = !_torchOn);
  }

  @override
  void dispose() {
    _scanLineController.dispose();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingPermission) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    if (_permission != CameraPermissionState.granted) {
      return QrScannerPermissionDenied(
        permanentlyDenied:
            _permission == CameraPermissionState.permanentlyDenied ||
            _permission == CameraPermissionState.restricted,
        onRequest: _requestPermissionAgain,
        onOpenSettings: _openSettings,
        onClose: _close,
      );
    }

    final controller = _controller;
    if (controller == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: controller,
            onDetect: _onDetect,
            errorBuilder: (context, error, child) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Не удалось запустить камеру.\n${error.errorCode.name}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
              );
            },
          ),
          QrScannerOverlay(scanLineAnimation: _scanLineController),
          SafeArea(
            child: Column(
              children: [
                QrScannerTopBar(onClose: _close),
                const Spacer(),
                QrScannerBottomBar(
                  torchOn: _torchOn,
                  torchAvailable: _torchAvailable,
                  onTorchToggle: _toggleTorch,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}
