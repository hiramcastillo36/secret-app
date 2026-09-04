// Plain hand-written models for the media upload flow (POST /uploads/sign,
// POST /uploads/{id}/confirm). Every fromJson tolerates a missing or null
// field rather than throwing.

/// A presigned upload slot: [uploadUrl] is a real bucket URL in production
/// and the backend's own dev store locally, either way already carrying its
/// own auth in the query string — never sent through the app's authenticated
/// dio client.
class SignedUpload {
  const SignedUpload({
    required this.mediaId,
    required this.uploadUrl,
    this.expiresAt,
  });

  final String mediaId;
  final String uploadUrl;
  final DateTime? expiresAt;

  factory SignedUpload.fromJson(Map<String, dynamic> json) => SignedUpload(
    mediaId: (json['media_id'] ?? '') as String,
    uploadUrl: (json['upload_url'] ?? '') as String,
    expiresAt: json['expires_at'] == null
        ? null
        : DateTime.tryParse(json['expires_at'] as String),
  );
}

/// The confirmed media row: `status` is "ready" once the upload is verified,
/// "failed" when the bytes didn't match what was signed for.
class MediaView {
  const MediaView({
    required this.id,
    required this.status,
    this.kind,
    this.width,
    this.height,
    this.blurhash,
  });

  final String id;
  final String status;
  final String? kind;
  final int? width;
  final int? height;
  final String? blurhash;

  bool get isReady => status == 'ready';

  factory MediaView.fromJson(Map<String, dynamic> json) => MediaView(
    id: (json['id'] ?? '') as String,
    status: (json['status'] ?? '') as String,
    kind: json['kind'] as String?,
    width: json['width'] as int?,
    height: json['height'] as int?,
    blurhash: json['blurhash'] as String?,
  );
}
