import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../services/storage_service.dart';
import '../theme/app_theme.dart';

/// The child's own picture on the home screen, with the bundled drawing until
/// they choose one.
///
/// The file the picker hands back lives in a cache the system is free to
/// empty, so it is copied into the app's documents folder and the copy is
/// what gets remembered. Nothing is uploaded: the picture only ever exists on
/// the phone it was chosen on.
class ChildAvatar extends StatefulWidget {
  final double size;
  const ChildAvatar({super.key, this.size = 40});

  @override
  State<ChildAvatar> createState() => _ChildAvatarState();
}

class _ChildAvatarState extends State<ChildAvatar> {
  bool _busy = false;

  Future<void> _pick() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        // A 40px avatar needs nothing like a full camera frame, and a smaller
        // copy keeps the app's folder from filling up with one.
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      if (picked == null) return;

      final dir = await getApplicationDocumentsDirectory();
      // A new name every time, because the old file may still be held by the
      // image cache and would otherwise go on being shown.
      final file = File(
        '${dir.path}/child_photo_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await file.writeAsBytes(await picked.readAsBytes());

      final previous = StorageService.getChildPhotoPath();
      await StorageService.setChildPhotoPath(file.path);
      if (previous != null && previous != file.path) {
        await File(previous).delete().catchError((_) => File(previous));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open that picture.')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ValueListenableBuilder(
      valueListenable: StorageService.childNameListenable(),
      builder: (context, _, __) {
        final path = StorageService.getChildPhotoPath();
        return Semantics(
          button: true,
          label: 'Choose your picture',
          child: GestureDetector(
            onTap: _pick,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: c.primary, width: 2),
              ),
              child: ClipOval(
                child: _busy
                    ? Center(
                        child: SizedBox(
                          width: widget.size * 0.4,
                          height: widget.size * 0.4,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: c.primary,
                          ),
                        ),
                      )
                    : path == null
                    ? Image.asset(
                        'assets/images/child_avatar.webp',
                        fit: BoxFit.cover,
                      )
                    : Image.file(
                        File(path),
                        fit: BoxFit.cover,
                        errorBuilder: (context, _, __) => Image.asset(
                          'assets/images/child_avatar.webp',
                          fit: BoxFit.cover,
                        ),
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}
