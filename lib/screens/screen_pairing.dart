import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';

class ScreenPairing extends StatefulWidget {
  const ScreenPairing({super.key});

  @override
  State<ScreenPairing> createState() => _ScreenPairingState();
}

class _ScreenPairingState extends State<ScreenPairing> {
  bool _isScanning = true;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    // Si déjà connecté, on redirige
    if (appState.session != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/main');
      });
    }

    return Scaffold(
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (capture) {
              if (!_isScanning) return;
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  setState(() => _isScanning = false);
                  appState.pair(barcode.rawValue!).then((_) {
                    if (context.mounted) context.go('/main');
                  });
                  break;
                }
              }
            },
          ),
          // Overlay
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.primaryColor, width: 4),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    "Scanner le QR Code Desktop",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Pour établir la connexion sécurisée",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 60,
            left: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "MedGate Mobile",
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  "Hôpital de Référence",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
