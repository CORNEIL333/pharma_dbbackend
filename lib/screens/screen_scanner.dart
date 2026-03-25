import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../services/app_state.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class ScreenScanner extends StatefulWidget {
  const ScreenScanner({super.key});

  @override
  State<ScreenScanner> createState() => _ScreenScannerState();
}

class _ScreenScannerState extends State<ScreenScanner> {
  CameraController? _controller;
  bool _isProcessing = false;
  ScanResult? _currentResult;
  
  final List<String> _services = [
    "Urgences", "Consultation générale", "Pédiatrie", 
    "Maternité", "Cardiologie", "Radiologie", 
    "Chirurgie", "Neurologie"
  ];

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;
    
    _controller = CameraController(cameras[0], ResolutionPreset.high, enableAudio: false);
    await _controller!.initialize();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized || _isProcessing) return;

    setState(() => _isProcessing = true);
    try {
      final image = await _controller!.takePicture();
      final appState = context.read<AppState>();
      final result = await appState.ocr.processImage(image);
      
      if (mounted) {
        setState(() {
          _currentResult = result;
          _isProcessing = false;
        });
      }
    } catch (e) {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentResult != null) {
      return _buildForm();
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Scanner une pièce")),
      body: Stack(
        children: [
          if (_controller != null && _controller!.value.isInitialized)
            SizedBox.expand(child: CameraPreview(_controller!))
          else
            const Center(child: CircularProgressIndicator()),
          
          // Overlay guide
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.width * 0.8 * 0.63,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: _isProcessing 
                ? const CircularProgressIndicator(color: AppTheme.primaryColor)
                : FloatingActionButton.large(
                    onPressed: _takePicture,
                    backgroundColor: AppTheme.primaryColor,
                    child: const Icon(Icons.camera_alt, size: 40),
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    final appState = context.watch<AppState>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("Vérification des données"),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => setState(() => _currentResult = null),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle(title: "Informations Personnelles"),
            const SizedBox(height: 15),
            TextFormField(
              initialValue: _currentResult!.nom,
              decoration: const InputDecoration(labelText: "Nom"),
              onChanged: (v) => _currentResult = _updateResult(nom: v),
            ),
            const SizedBox(height: 15),
            TextFormField(
              initialValue: _currentResult!.prenom,
              decoration: const InputDecoration(labelText: "Prénom"),
              onChanged: (v) => _currentResult = _updateResult(prenom: v),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: _currentResult!.dateNais,
                    decoration: const InputDecoration(labelText: "Date de naissance"),
                    onChanged: (v) => _currentResult = _updateResult(dateNais: v),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _currentResult!.typePiece,
                    decoration: const InputDecoration(labelText: "Type de pièce"),
                    items: ["CNI", "Passeport", "Séjour", "Scolaire"]
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) => _currentResult = _updateResult(typePiece: v!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            TextFormField(
              initialValue: _currentResult!.numPiece,
              decoration: const InputDecoration(labelText: "Numéro de pièce"),
              onChanged: (v) => _currentResult = _updateResult(numPiece: v),
            ),
            const SizedBox(height: 30),
            const SectionTitle(title: "Service Hospitalier"),
            const SizedBox(height: 15),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _services.map((s) {
                final isSelected = _currentResult!.service == s;
                return ChoiceChip(
                  label: Text(s),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) setState(() => _currentResult = _updateResult(service: s));
                  },
                  selectedColor: AppTheme.primaryColor,
                  labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.grey),
                );
              }).toList(),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: appState.isConnected ? () async {
                  await appState.sendScan(_currentResult!);
                  if (mounted) context.push('/confirmation');
                } : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(appState.isConnected ? "ENVOYER AU DESKTOP" : "HORS LIGNE"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ScanResult _updateResult({
    String? nom, String? prenom, String? typePiece, 
    String? numPiece, String? dateNais, String? service
  }) {
    return ScanResult(
      nom: nom ?? _currentResult!.nom,
      prenom: prenom ?? _currentResult!.prenom,
      typePiece: typePiece ?? _currentResult!.typePiece,
      numPiece: numPiece ?? _currentResult!.numPiece,
      dateNais: dateNais ?? _currentResult!.dateNais,
      expiration: _currentResult!.expiration,
      service: service ?? _currentResult!.service,
    );
  }
}
