import 'package:flutter/material.dart';
import '../models/models.dart';
import 'websocket_service.dart';
import 'storage_service.dart';
import 'ocr_service.dart';

class AppState extends ChangeNotifier {
  final WebSocketService _ws = WebSocketService();
  final StorageService _storage = StorageService();
  final OCRService _ocr = OCRService();

  SessionInfo? _session;
  List<VisiteRecord> _history = [];
  String? _lastDossierNum;
  bool _isInitialized = false;

  AppState() {
    _init();
    _ws.messages.listen(_handleWsMessage);
  }

  bool get isConnected => _ws.isConnected;
  bool get isInitialized => _isInitialized;
  SessionInfo? get session => _session;
  List<VisiteRecord> get history => _history;
  String? get lastDossierNum => _lastDossierNum;
  OCRService get ocr => _ocr;

  Future<void> _init() async {
    _session = await _storage.getSession();
    _history = await _storage.getHistory();
    if (_session != null) {
      _ws.connect(_session!);
    }
    _isInitialized = true;
    notifyListeners();
  }

  void _handleWsMessage(Map<String, dynamic> data) {
    if (data['type'] == 'scan_response' || data['dossier_num'] != null) {
      _lastDossierNum = data['dossier_num'];
      notifyListeners();
    }
    // Update connection status if needed
    notifyListeners();
  }

  Future<void> pair(String qrData) async {
    // Format attendu du QR: IP:PORT:TOKEN
    try {
      final parts = qrData.split(':');
      if (parts.length == 3) {
        _session = SessionInfo(ip: parts[0], port: parts[1], token: parts[2]);
        await _storage.saveSession(_session!);
        _ws.connect(_session!);
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Erreur appairage: $e");
    }
  }

  Future<void> sendScan(ScanResult result) async {
    if (_session != null && isConnected) {
      _ws.send(result.toJson(_session!.token));
      
      // On ajoute temporairement à l'historique en "En attente"
      // En prod, on attendrait le retour du serveur pour confirmer
      final record = VisiteRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        nom: result.nom,
        prenom: result.prenom,
        service: result.service,
        timestamp: DateTime.now(),
        dossierNum: "...",
        statut: "En attente",
      );
      _history.insert(0, record);
      await _storage.saveHistory(_history);
      notifyListeners();
    }
  }

  void confirmScan(String dossierNum) {
    if (_history.isNotEmpty && _history.first.statut == "En attente") {
      final old = _history.removeAt(0);
      _history.insert(0, VisiteRecord(
        id: old.id,
        nom: old.nom,
        prenom: old.prenom,
        service: old.service,
        timestamp: old.timestamp,
        dossierNum: dossierNum,
        statut: "Entré",
      ));
      _storage.saveHistory(_history);
      notifyListeners();
    }
  }

  Future<void> disconnect() async {
    _ws.disconnect();
    _session = null;
    await _storage.clearSession();
    notifyListeners();
  }

  Future<void> clearHistory() async {
    _history.clear();
    await _storage.clearHistory();
    notifyListeners();
  }

  @override
  void dispose() {
    _ws.dispose();
    _ocr.dispose();
    super.dispose();
  }
}
