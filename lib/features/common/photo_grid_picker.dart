import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/media/media_repository.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/tokens.dart';

enum _PhotoStatus { uploading, ready, failed }

class _PickedPhoto {
  _PickedPhoto({required this.bytes, required this.contentType});
  final Uint8List bytes;
  final String contentType;
  String? mediaId;
  double progress = 0;
  _PhotoStatus status = _PhotoStatus.uploading;
}

/// Up to [maxPhotos] photos, each uploaded (POST /uploads/sign -> PUT ->
/// POST .../confirm) the moment it's picked, with its own progress ring.
/// Reports the ready media ids via [onReadyChanged] on every change, and
/// whether anything is still uploading via [onBusyChanged] — a caller must
/// not submit its form while that is true.
class PhotoGridPicker extends ConsumerStatefulWidget {
  const PhotoGridPicker({
    super.key,
    required this.onReadyChanged,
    required this.onBusyChanged,
    this.kind = MediaKind.datePhoto,
    this.maxPhotos = 6,
  });

  final ValueChanged<List<String>> onReadyChanged;
  final ValueChanged<bool> onBusyChanged;
  final String kind;
  final int maxPhotos;

  @override
  ConsumerState<PhotoGridPicker> createState() => _PhotoGridPickerState();
}

class _PhotoGridPickerState extends ConsumerState<PhotoGridPicker> {
  final List<_PickedPhoto> _photos = [];

  void _notify() {
    widget.onReadyChanged([
      for (final p in _photos)
        if (p.status == _PhotoStatus.ready && p.mediaId != null) p.mediaId!,
    ]);
    widget.onBusyChanged(
      _photos.any((p) => p.status == _PhotoStatus.uploading),
    );
  }

  Future<void> _pick() async {
    final remaining = widget.maxPhotos - _photos.length;
    if (remaining <= 0) return;
    final l10n = AppLocalizations.of(context);
    List<XFile> picked;
    try {
      picked = await ImagePicker().pickMultiImage(
        limit: remaining,
        maxWidth: 2000,
        maxHeight: 2000,
        imageQuality: 85,
      );
    } catch (_) {
      return; // cancelled, or the platform declined — nothing to show
    }
    for (final file in picked.take(remaining)) {
      final contentType = mediaContentTypeForPath(file.path);
      if (contentType == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.photoUnsupportedType)),
          );
        }
        continue;
      }
      final bytes = await file.readAsBytes();
      final photo = _PickedPhoto(bytes: bytes, contentType: contentType);
      if (!mounted) return;
      setState(() => _photos.add(photo));
      _notify();
      unawaited(_upload(photo));
    }
  }

  Future<void> _upload(_PickedPhoto photo) async {
    try {
      final media = await ref
          .read(mediaRepositoryProvider)
          .upload(
            bytes: photo.bytes,
            contentType: photo.contentType,
            kind: widget.kind,
            onProgress: (p) {
              if (mounted) setState(() => photo.progress = p);
            },
          );
      photo.mediaId = media.id;
      photo.status = media.isReady ? _PhotoStatus.ready : _PhotoStatus.failed;
    } catch (_) {
      photo.status = _PhotoStatus.failed;
    }
    if (mounted) setState(() {});
    _notify();
  }

  void _remove(_PickedPhoto photo) {
    setState(() => _photos.remove(photo));
    _notify();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Wrap(
      spacing: RachaTokens.space2,
      runSpacing: RachaTokens.space2,
      children: [
        for (final p in _photos)
          _PhotoTile(
            photo: p,
            onRemove: () => _remove(p),
            onRetry: () => _upload(p),
          ),
        if (_photos.length < widget.maxPhotos)
          Tooltip(
            message: l10n.photoAdd,
            child: InkWell(
              onTap: _pick,
              borderRadius: RachaTokens.brM,
              child: Container(
                height: 88,
                width: 88,
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: RachaTokens.brM,
                  border: Border.all(
                    color: scheme.outlineVariant,
                    width: RachaTokens.borderHairline,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_photo_alternate_outlined,
                      color: scheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_photos.length}/${widget.maxPhotos}',
                      style: TextStyle(
                        fontSize: RachaType.micro,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _PhotoTile extends StatelessWidget {
  const _PhotoTile({
    required this.photo,
    required this.onRemove,
    required this.onRetry,
  });
  final _PickedPhoto photo;
  final VoidCallback onRemove;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SizedBox(
      height: 88,
      width: 88,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: RachaTokens.brM,
            child: Image.memory(photo.bytes, fit: BoxFit.cover),
          ),
          if (photo.status == _PhotoStatus.uploading)
            Container(
              color: Colors.black.withValues(alpha: 0.35),
              child: Center(
                child: SizedBox(
                  height: 28,
                  width: 28,
                  child: CircularProgressIndicator(
                    value: photo.progress > 0 ? photo.progress : null,
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          if (photo.status == _PhotoStatus.failed)
            Material(
              type: MaterialType.transparency,
              child: Tooltip(
                message: l10n.commonRetry,
                child: InkWell(
                  onTap: onRetry,
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.45),
                    child: const Center(
                      child: Icon(Icons.refresh, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          Positioned(
            top: 0,
            right: 0,
            child: Tooltip(
              message: l10n.photoRemove,
              child: InkWell(
                onTap: onRemove,
                customBorder: const CircleBorder(),
                child: Container(
                  margin: const EdgeInsets.all(2),
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
