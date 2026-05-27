import 'package:flutter/material.dart';

import 'file_picker.dart';

class FileDropZone extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return GestureDetector(onTap: onTap, child: child);
  }
}
