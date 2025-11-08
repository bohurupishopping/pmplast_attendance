import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'kiosk_controller.dart';
import '../../core/constants.dart';

class KioskScreen extends ConsumerStatefulWidget {
  const KioskScreen({super.key});

  @override
  ConsumerState<KioskScreen> createState() => _KioskScreenState();
}

class _KioskScreenState extends ConsumerState<KioskScreen> {
  late MobileScannerController _scannerController;
  bool _isScanning = true;

  @override
  void initState() {
    super.initState();
    _initScanner();
  }

  void _initScanner() {
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.front,
      returnImage: true,
      autoStart: true,
    );
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  void _switchCamera() {
    _scannerController.switchCamera();
  }

  void _pauseScanning() {
    setState(() {
      _isScanning = false;
    });
  }

  void _restartForNextScan() {
    // Simply reset the scanning flag - don't dispose controller
    setState(() {
      _isScanning = true;
    });
    ref.read(kioskControllerProvider.notifier).resetToReady();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(kioskControllerProvider);
    final isOnline = ref.watch(isOnlineProvider);



    return Scaffold(
      body: Stack(
        children: [
          MobileScanner(
            controller: _scannerController,
            onDetect: (capture) async {
              if (state.status == KioskStatus.ready && _isScanning) {
                final barcodes = capture.barcodes;
                if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
                  final employeeId = barcodes.first.rawValue!;
                  final imageBytes = capture.image;
                  
                  // Pause scanning immediately
                  _pauseScanning();
                  
                  // Start verification instantly
                  ref.read(kioskControllerProvider.notifier).verifyAttendance(
                    employeeId,
                    imageBytes,
                  );
                }
              }
            },
          ),
          _buildOverlay(context, state, isOnline),
          if (state.status == KioskStatus.success || state.status == KioskStatus.failure)
            _buildFeedbackOverlay(context, state),
        ],
      ),
    );
  }

  Widget _buildOverlay(BuildContext context, KioskState state, bool isOnline) {
    // If idle, show start button
    if (state.status == KioskStatus.idle) {
      return _buildIdleScreen(context);
    }

    return SafeArea(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.7),
                  Colors.transparent,
                ],
              ),
            ),
            child: Column(
              children: [
Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppConstants.appName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: _switchCamera,
                          icon: const Icon(
                            Icons.flip_camera_android,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isOnline ? Colors.green : Colors.orange,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isOnline ? Icons.cloud_done : Icons.cloud_off,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isOnline ? 'Online' : 'Offline',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  _getStatusText(state.status),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const Spacer(),
          if (state.status == KioskStatus.ready)
            Container(
              margin: const EdgeInsets.all(40),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 3),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Container(
                height: 250,
                width: 250,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          if (state.status == KioskStatus.verifying)
            const Column(
              children: [
                CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 4,
                ),
                SizedBox(height: 16),
                Text(
                  'Verifying...',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ],
            ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildIdleScreen(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.qr_code_scanner_rounded,
              size: 120,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 32),
            Text(
              'Ready to scan',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () {
                _restartForNextScan();
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 48,
                  vertical: 20,
                ),
              ),
              child: const Text(
                'Start Scan',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackOverlay(BuildContext context, KioskState state) {
    final isSuccess = state.status == KioskStatus.success;
    
    return Container(
      color: (isSuccess ? Colors.green : Colors.red).withValues(alpha: 0.95),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isSuccess ? Icons.check_rounded : Icons.close_rounded,
                  size: 100,
                  color: isSuccess ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                state.message ?? (isSuccess ? 'Success!' : 'Failed!'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getStatusText(KioskStatus status) {
    switch (status) {
      case KioskStatus.ready:
        return 'Please scan your QR code';
      case KioskStatus.verifying:
        return 'Verifying...';
      case KioskStatus.success:
      case KioskStatus.failure:
      case KioskStatus.idle:
        return '';
    }
  }
}

final isOnlineProvider = Provider<bool>((ref) {
  return true;
});
