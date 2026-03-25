class ScanResult {
  final String nom;
  final String prenom;
  final String typePiece;
  final String numPiece;
  final String dateNais;
  final String expiration;
  final String service;

  ScanResult({
    required this.nom,
    required this.prenom,
    required this.typePiece,
    required this.numPiece,
    required this.dateNais,
    required this.expiration,
    required this.service,
  });

  Map<String, dynamic> toJson(String token) {
    return {
      "type": "scan",
      "token": token,
      "nom": nom,
      "prenom": prenom,
      "type_piece": typePiece,
      "num_piece": numPiece,
      "date_nais": dateNais,
      "expiration": expiration,
      "service": service,
    };
  }
}

class SessionInfo {
  final String ip;
  final String port;
  final String token;

  SessionInfo({
    required this.ip,
    required this.port,
    required this.token,
  });

  String get wsUrl => "ws://$ip:$port";

  Map<String, String> toMap() {
    return {
      'ip': ip,
      'port': port,
      'token': token,
    };
  }

  factory SessionInfo.fromMap(Map<String, dynamic> map) {
    return SessionInfo(
      ip: map['ip'] ?? '',
      port: map['port'] ?? '',
      token: map['token'] ?? '',
    );
  }
}

class VisiteRecord {
  final String id;
  final String nom;
  final String prenom;
  final String service;
  final DateTime timestamp;
  final String dossierNum;
  final String statut; // 'Entré', 'Sorti', 'En attente'

  VisiteRecord({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.service,
    required this.timestamp,
    required this.dossierNum,
    this.statut = 'Entré',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'service': service,
      'timestamp': timestamp.toIso8601String(),
      'dossierNum': dossierNum,
      'statut': statut,
    };
  }

  factory VisiteRecord.fromMap(Map<String, dynamic> map) {
    return VisiteRecord(
      id: map['id'],
      nom: map['nom'],
      prenom: map['prenom'],
      service: map['service'],
      timestamp: DateTime.parse(map['timestamp']),
      dossierNum: map['dossierNum'],
      statut: map['statut'] ?? 'Entré',
    );
  }
}
