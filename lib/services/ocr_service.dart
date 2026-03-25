import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:camera/camera.dart';
import '../models/models.dart';

class OCRService {
  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  Future<ScanResult?> processImage(XFile imageFile) async {
    final inputImage = InputImage.fromFilePath(imageFile.path);
    final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
    
    String text = recognizedText.text;
    
    // Logic simpliste d'extraction (à affiner selon les formats réels)
    // On cherche des patterns communs
    String nom = _extractField(text, ["NOM", "SURNAME", "NAME"]);
    String prenom = _extractField(text, ["PRENOM", "GIVEN NAME"]);
    String numPiece = _extractField(text, ["N°", "NUMBER", "ID"]);
    String dateNais = _extractField(text, ["NAISSANCE", "BIRTH"]);
    String expiration = _extractField(text, ["EXPIRATION", "EXPIRE"]);

    return ScanResult(
      nom: nom.toUpperCase(),
      prenom: prenom,
      typePiece: "CNI", // Par défaut
      numPiece: numPiece,
      dateNais: dateNais,
      expiration: expiration,
      service: "Urgences",
    );
  }

  String _extractField(String text, List<String> keywords) {
    final lines = text.split('\n');
    for (var i = 0; i < lines.length; i++) {
      for (var keyword in keywords) {
        if (lines[i].toUpperCase().contains(keyword)) {
          // Souvent la valeur est sur la même ligne après le mot clé ou sur la ligne suivante
          String line = lines[i];
          String value = line.substring(line.toUpperCase().indexOf(keyword) + keyword.length).trim();
          if (value.length > 2) return value;
          if (i + 1 < lines.length) return lines[i + 1].trim();
        }
      }
    }
    return "";
  }

  void dispose() {
    _textRecognizer.close();
  }
}
