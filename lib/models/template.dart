/// Mirrors `com.posterpro.api.template.TemplateSummaryDto`.
///
/// Note: the backend has no `sku` field and no separate `badge`/`tag` field.
/// The reference design's "Template · SKU {sku}" and card badge are
/// approximated using [planTierMin] (e.g. "FREE"/"PRO") and [isFestival].
class TemplateSummary {
  TemplateSummary({
    required this.id,
    required this.title,
    required this.thumbnailUrl,
    required this.price,
    required this.categoryId,
    required this.categoryName,
    required this.planTierMin,
    required this.isFestival,
    this.festivalDate,
    required this.isFavorited,
  });

  final int id;
  final String title;
  final String? thumbnailUrl;
  final double price;
  final int? categoryId;
  final String? categoryName;
  final String? planTierMin;
  final bool isFestival;
  final DateTime? festivalDate;
  final bool isFavorited;

  factory TemplateSummary.fromJson(Map<String, dynamic> json) {
    return TemplateSummary(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      thumbnailUrl: json['thumbnailUrl'] as String?,
      price: (json['price'] as num?)?.toDouble() ?? 0,
      categoryId: json['categoryId'] as int?,
      categoryName: json['categoryName'] as String?,
      planTierMin: json['planTierMin'] as String?,
      isFestival: json['isFestival'] as bool? ?? false,
      festivalDate: json['festivalDate'] != null
          ? DateTime.tryParse(json['festivalDate'] as String)
          : null,
      isFavorited: json['isFavorited'] as bool? ?? false,
    );
  }

  TemplateSummary copyWith({bool? isFavorited}) {
    return TemplateSummary(
      id: id,
      title: title,
      thumbnailUrl: thumbnailUrl,
      price: price,
      categoryId: categoryId,
      categoryName: categoryName,
      planTierMin: planTierMin,
      isFestival: isFestival,
      festivalDate: festivalDate,
      isFavorited: isFavorited ?? this.isFavorited,
    );
  }
}

/// Mirrors `com.posterpro.api.template.TemplateDetailDto`
/// (TemplateSummaryDto fields + schemaJson/createdAt/updatedAt).
class TemplateDetail {
  TemplateDetail({
    required this.summary,
    required this.schemaJson,
    this.createdAt,
    this.updatedAt,
  });

  final TemplateSummary summary;
  final String? schemaJson;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory TemplateDetail.fromJson(Map<String, dynamic> json) {
    return TemplateDetail(
      summary: TemplateSummary.fromJson(json),
      schemaJson: json['schemaJson'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
    );
  }
}
