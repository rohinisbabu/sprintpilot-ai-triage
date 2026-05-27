// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';

import 'file_picker.dart';

Future<UploadedEvidence?> pickUploadFile() async {
  final completer = Completer<UploadedEvidence?>();
  final input = html.FileUploadInputElement();
  input.accept = '.png,.jpg,.jpeg,.pdf';
  input.multiple = false;
  StreamSubscription<html.Event>? inputSubscription;
  Timer? timeoutTimer;

  void safeComplete(UploadedEvidence? evidence) {
    if (!completer.isCompleted) completer.complete(evidence);
    timeoutTimer?.cancel();
    inputSubscription?.cancel();
  }

  void handleFile(html.Event _) {
    final files = input.files;
    if (files == null || files.isEmpty) {
      safeComplete(null);
      return;
    }
    final file = files.first;
    final reader = html.FileReader();
    StreamSubscription<html.ProgressEvent>? loadSubscription;
    StreamSubscription<html.ProgressEvent>? errorSubscription;
    void cleanupReader() {
      loadSubscription?.cancel();
      errorSubscription?.cancel();
    }

    loadSubscription = reader.onLoadEnd.listen((event) {
      cleanupReader();
      final data = reader.result;
      if (data is! ByteBuffer) {
        safeComplete(null);
        return;
      }
      final bytes = Uint8List.view(data);
      if (bytes.isEmpty) {
        safeComplete(null);
        return;
      }
      safeComplete(
        UploadedEvidence(
          name: file.name.isEmpty ? 'uploaded-evidence' : file.name,
          bytes: bytes,
          type: file.type.isEmpty ? _inferMimeType(file.name) : file.type,
        ),
      );
    });
    errorSubscription = reader.onError.listen((event) {
      cleanupReader();
      safeComplete(null);
    });
    reader.readAsArrayBuffer(file);
  }

  inputSubscription = input.onChange.listen(handleFile);
  timeoutTimer = Timer(const Duration(seconds: 45), () => safeComplete(null));
  input.click();
  return completer.future;
}

String _inferMimeType(String name) {
  final lower = name.toLowerCase();
  if (lower.endsWith('.png')) return 'image/png';
  if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
  if (lower.endsWith('.pdf')) return 'application/pdf';
  return 'application/octet-stream';
}
