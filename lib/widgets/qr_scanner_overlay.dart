import 'package:flutter/material.dart';

import '../data/kaspi_catalog.dart';

/// Kaspi-style viewfinder overlay with animated scan line.
class QrScannerOverlay extends StatelessWidget {
  const QrScannerOverlay({
    super.key,
    required this.scanLineAnimation,
    this.hint = 'Наведите камеру на QR-код',
    this.subhint = 'Поддерживаются QR-коды и штрихкоды',
  });

  final Animation<double> scanLineAnimation;
  final String hint;
  final String subhint;

  static const double viewfinderSize = 260;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final center = Offset(
          constraints.maxWidth / 2,
          constraints.maxHeight * 0.42,
        );
        final rect = Rect.fromCenter(
          center: center,
          width: viewfinderSize,
          height: viewfinderSize,
        );

        return Stack(
          fit: StackFit.expand,
          children: [
            CustomPaint(
              painter: _ScannerMaskPainter(scanRect: rect),
            ),
            Positioned.fromRect(
              rect: rect,
              child: AnimatedBuilder(
                animation: scanLineAnimation,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _ViewfinderFramePainter(
                      progress: scanLineAnimation.value,
                    ),
                  );
                },
              ),
            ),
            Positioned(
              left: 24,
              right: 24,
              top: rect.bottom + 28,
              child: Column(
                children: [
                  Text(
                    hint,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subhint,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.75),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ScannerMaskPainter extends CustomPainter {
  _ScannerMaskPainter({required this.scanRect});

  final Rect scanRect;

  @override
  void paint(Canvas canvas, Size size) {
    final background = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final hole = Path()
      ..addRRect(RRect.fromRectAndRadius(scanRect, const Radius.circular(20)));
    final overlay = Path.combine(PathOperation.difference, background, hole);
    canvas.drawPath(
      overlay,
      Paint()..color = Colors.black.withValues(alpha: 0.55),
    );
  }

  @override
  bool shouldRepaint(covariant _ScannerMaskPainter oldDelegate) {
    return oldDelegate.scanRect != scanRect;
  }
}

class _ViewfinderFramePainter extends CustomPainter {
  _ViewfinderFramePainter({required this.progress});

  final double progress;
  static const _cornerLen = 28.0;
  static const _stroke = 4.0;
  static const _color = kaspiPrimary;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _color
      ..strokeWidth = _stroke
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    void corner(Offset origin, {required bool top, required bool left}) {
      final dx = left ? 1.0 : -1.0;
      final dy = top ? 1.0 : -1.0;
      canvas.drawLine(
        origin,
        origin + Offset(_cornerLen * dx, 0),
        paint,
      );
      canvas.drawLine(
        origin,
        origin + Offset(0, _cornerLen * dy),
        paint,
      );
    }

    corner(const Offset(0, 0), top: true, left: true);
    corner(Offset(size.width, 0), top: true, left: false);
    corner(Offset(0, size.height), top: false, left: true);
    corner(Offset(size.width, size.height), top: false, left: false);

    final lineY = 12 + (size.height - 24) * progress;
    final linePaint = Paint()
      ..shader = LinearGradient(
        colors: [
          _color.withValues(alpha: 0.0),
          _color,
          _color.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(16, lineY, size.width - 32, 2))
      ..strokeWidth = 2.5;

    canvas.drawLine(
      Offset(16, lineY),
      Offset(size.width - 16, lineY),
      linePaint,
    );

    canvas.drawCircle(
      Offset(size.width / 2, lineY),
      4,
      Paint()..color = _color.withValues(alpha: 0.9),
    );
  }

  @override
  bool shouldRepaint(covariant _ViewfinderFramePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Top bar for the scanner with close action.
class QrScannerTopBar extends StatelessWidget {
  const QrScannerTopBar({super.key, required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
            tooltip: 'Закрыть',
          ),
          const Expanded(
            child: Text(
              'Сканирование QR',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

/// Bottom controls: flashlight toggle.
class QrScannerBottomBar extends StatelessWidget {
  const QrScannerBottomBar({
    super.key,
    required this.torchOn,
    required this.torchAvailable,
    required this.onTorchToggle,
  });

  final bool torchOn;
  final bool torchAvailable;
  final VoidCallback onTorchToggle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        16 + MediaQuery.paddingOf(context).bottom,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _ScannerControlButton(
            icon: torchOn ? Icons.flash_on_rounded : Icons.flash_off_outlined,
            label: torchOn ? 'Вспышка вкл.' : 'Вспышка',
            enabled: torchAvailable,
            onTap: onTorchToggle,
          ),
        ],
      ),
    );
  }
}

class _ScannerControlButton extends StatelessWidget {
  const _ScannerControlButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.enabled = true,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: Material(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.white, size: 28),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Permission denied / restricted placeholder.
class QrScannerPermissionDenied extends StatelessWidget {
  const QrScannerPermissionDenied({
    super.key,
    required this.permanentlyDenied,
    required this.onRequest,
    required this.onOpenSettings,
    required this.onClose,
  });

  final bool permanentlyDenied;
  final VoidCallback onRequest;
  final VoidCallback onOpenSettings;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1F23),
      body: SafeArea(
        child: Column(
          children: [
            QrScannerTopBar(onClose: onClose),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: kaspiPrimary.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.videocam_off_outlined,
                        color: kaspiPrimary,
                        size: 44,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Нет доступа к камере',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      permanentlyDenied
                          ? 'Разрешите доступ к камере в настройках устройства, чтобы сканировать QR-коды Kaspi.'
                          : 'Для сканирования QR-кодов и штрихкодов приложению нужен доступ к камере.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.72),
                        fontSize: 15,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: permanentlyDenied
                            ? onOpenSettings
                            : onRequest,
                        style: FilledButton.styleFrom(
                          backgroundColor: kaspiPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          permanentlyDenied
                              ? 'Открыть настройки'
                              : 'Разрешить доступ',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    if (!permanentlyDenied) ...[
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: onClose,
                        child: const Text(
                          'Закрыть',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
