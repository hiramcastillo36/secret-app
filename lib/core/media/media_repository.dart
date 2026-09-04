import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_exception.dart';
import '../api/dio_client.dart';
import 'media_models.dart';

/// Content kinds POST /uploads/sign accepts.
class MediaKind {
  static const datePhoto = 'date_photo';
  static const avatar = 'avatar';
}

/// The content types the backend signs uploads for (`allowedContentTypes` in
/// internal/media). Keep this in sync with the server list.
const _allowedContentTypes = {
  'jpg': 'image/jpeg',
  'jpeg': 'image/jpeg',
  'png': 'image/png',
  'webp': 'image/webp',
  'heic': 'image/heic',
  'heif': 'image/heic',
};

/// The MIME type the server will accept for a picked file, guessed from its
/// extension since `image_picker` doesn't reliably report one on every
/// platform. Null means "not a type the backend signs uploads for" — the
/// caller should reject it before ever calling [MediaRepository.upload].
String? mediaContentTypeForPath(String path) {
  final dot = path.lastIndexOf('.');
  if (dot < 0) return null;
  return _allowedContentTypes[path.substring(dot + 1).toLowerCase()];
}

/// Wraps sign -> PUT -> confirm behind one call.
class MediaRepository {
  MediaRepository(this._dio);
  final Dio _dio;

  Future<SignedUpload> sign({
    required String kind,
    required String contentType,
    required int bytes,
  }) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '/uploads/sign',
        data: {'kind': kind, 'content_type': contentType, 'bytes': bytes},
      );
      return SignedUpload.fromJson(res.data!);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<MediaView> confirm(String mediaId) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '/uploads/$mediaId/confirm',
      );
      return MediaView.fromJson(
        (res.data!['media'] as Map).cast<String, dynamic>(),
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// Signs, uploads and confirms [bytes] as one step, reporting 0.0-1.0
  /// progress for the PUT (sign and confirm are quick JSON round trips and
  /// aren't tracked separately). The PUT goes on a bare [Dio] — the presigned
  /// [SignedUpload.uploadUrl] is not under `/v1` and carries its own auth, so
  /// it must never see this app's bearer token or JSON headers.
  Future<MediaView> upload({
    required Uint8List bytes,
    required String contentType,
    required String kind,
    void Function(double progress)? onProgress,
  }) async {
    final signed = await sign(
      kind: kind,
      contentType: contentType,
      bytes: bytes.length,
    );
    try {
      await Dio(
        BaseOptions(
          sendTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 30),
        ),
      ).put<void>(
        signed.uploadUrl,
        data: bytes,
        options: Options(
          headers: {
            Headers.contentTypeHeader: contentType,
            Headers.contentLengthHeader: bytes.length,
          },
        ),
        onSendProgress: (sent, total) {
          if (total > 0) onProgress?.call(sent / total);
        },
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
    return confirm(signed.mediaId);
  }
}

final mediaRepositoryProvider = Provider<MediaRepository>((ref) {
  return MediaRepository(ref.watch(dioProvider));
});
