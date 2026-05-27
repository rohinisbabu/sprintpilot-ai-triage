import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

class UploadedEvidence {
  const UploadedEvidence({
    required this.name,
    required this.bytes,
    required this.type,
  });

  final String name;
  final Uint8List bytes;
  final String type;

  bool get isImage => type.startsWith('image/');
  bool get isPdf => type.toLowerCase().contains('pdf');
}

Future<UploadedEvidence?> pickUploadFile() async {
  try {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg', 'jpeg', 'pdf'],
      withData: true,
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty) {
      return null;
    }

    final file = result.files.first;
    final bytes = file.bytes;
    if (bytes == null || bytes.isEmpty) {
      return null;
    }

    final type = _inferMimeType(file.name);

    return UploadedEvidence(name: file.name, bytes: bytes, type: type);
  } catch (error) {
    debugPrint('pickUploadFile failed: $error');
    return null;
  }
}

String _inferMimeType(String name) {
  final lower = name.toLowerCase();
  if (lower.endsWith('.png')) return 'image/png';
  if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
  if (lower.endsWith('.pdf')) return 'application/pdf';
  return 'application/octet-stream';
}
