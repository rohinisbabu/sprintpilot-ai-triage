// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';

import 'file_picker.dart';

class FileDropZone extends StatefulWidget {
  const FileDropZone({
    super.key,
    required this.child,
    required this.onFileDropped,
    required this.onTap,
  });

  final Widget child;
  final ValueChanged<UploadedEvidence> onFileDropped;
  final VoidCallback onTap;

  @override
  State<FileDropZone> createState() => _FileDropZoneState();
}

class _FileDropZoneState extends State<FileDropZone> {
  late final String _viewType;
  final List<StreamSubscription<dynamic>> _subscriptions = [];

  @override
  void initState() {
    super.initState();
    _viewType =
        'file-drop-zone-${widget.hashCode}-${DateTime.now().microsecondsSinceEpoch}';

    ui_web.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
      final element = html.DivElement()
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.position = 'absolute'
        ..style.top = '0'
        ..style.left = '0'
        ..style.cursor = 'pointer'
        ..style.backgroundColor = 'transparent';

      _subscriptions.addAll([
        element.onDragOver.listen((event) {
          event.preventDefault();
          element.style.backgroundColor = 'rgba(255,255,255,0.06)';
        }),
        element.onDragLeave.listen((event) {
          event.preventDefault();
          element.style.backgroundColor = 'transparent';
        }),
        element.onDrop.listen((event) {
          event.preventDefault();
          element.style.backgroundColor = 'transparent';
          final files = event.dataTransfer.files;
          if (files == null || files.isEmpty) return;
          final file = files.first;
          final reader = html.FileReader();
          StreamSubscription<html.ProgressEvent>? loadSubscription;
          StreamSubscription<html.ProgressEvent>? errorSubscription;
          void cleanupReader() {
            loadSubscription?.cancel();
            errorSubscription?.cancel();
          }

          loadSubscription = reader.onLoadEnd.listen((_) {
            cleanupReader();
            final data = reader.result;
            if (data is! ByteBuffer || !mounted) return;
            final bytes = Uint8List.view(data);
            if (bytes.isEmpty) return;
            widget.onFileDropped(
              UploadedEvidence(
                name: file.name.isEmpty ? 'uploaded-evidence' : file.name,
                bytes: bytes,
                type: file.type.isEmpty ? _inferMimeType(file.name) : file.type,
              ),
            );
          });
          errorSubscription = reader.onError.listen((_) {
            cleanupReader();
          });
          reader.readAsArrayBuffer(file);
        }),
        element.onClick.listen((_) {
          if (!mounted) return;
          widget.onTap();
        }),
      ]);
      return element;
    });
  }

  @override
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Positioned.fill(child: HtmlElementView(viewType: _viewType)),
      ],
    );
  }
}

String _inferMimeType(String name) {
  final lower = name.toLowerCase();
  if (lower.endsWith('.png')) return 'image/png';
  if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
  if (lower.endsWith('.pdf')) return 'application/pdf';
  return 'application/octet-stream';
}
