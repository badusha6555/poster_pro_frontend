/// Mirrors `com.posterpro.api.poster.PosterResponse`.
class PosterResult {
  PosterResult({required this.url, required this.format, this.urlExpiresAt});

  final String url;
  final String format;
  final DateTime? urlExpiresAt;

  factory PosterResult.fromJson(Map<String, dynamic> json) {
    return PosterResult(
      url: json['url'] as String,
      format: json['format'] as String? ?? 'PNG',
      urlExpiresAt: json['urlExpiresAt'] != null
          ? DateTime.tryParse(json['urlExpiresAt'] as String)
          : null,
    );
  }
}
