/// Mirrors `com.posterpro.api.category.CategoryDto`.
class Category {
  Category({
    required this.id,
    required this.name,
    required this.slug,
    required this.iconUrl,
    required this.sortOrder,
  });

  final int id;
  final String name;
  final String slug;
  final String? iconUrl;
  final int sortOrder;

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String? ?? '',
      iconUrl: json['iconUrl'] as String?,
      sortOrder: json['sortOrder'] as int? ?? 0,
    );
  }
}
