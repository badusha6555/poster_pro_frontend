/// Mirrors `com.posterpro.api.goldrate.GoldRateDto`.
///
/// Note: the backend stores exactly 4 flat karat rates, not the 6
/// karat/weight combinations (22K/1g, 22K/8g, 18K/1g, 18K/8g, 14K/1g, 9K/1g)
/// shown in the reference design. There is no per-weight breakdown and no
/// explicit unit field in the DTO.
class GoldRateProfile {
  GoldRateProfile({
    required this.rate22k916,
    required this.rate18k,
    required this.rate14k,
    required this.rate9k,
    this.updatedAt,
  });

  final double rate22k916;
  final double rate18k;
  final double rate14k;
  final double rate9k;
  final DateTime? updatedAt;

  factory GoldRateProfile.fromJson(Map<String, dynamic> json) {
    return GoldRateProfile(
      rate22k916: (json['rate22k916'] as num?)?.toDouble() ?? 0,
      rate18k: (json['rate18k'] as num?)?.toDouble() ?? 0,
      rate14k: (json['rate14k'] as num?)?.toDouble() ?? 0,
      rate9k: (json['rate9k'] as num?)?.toDouble() ?? 0,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rate22k916': rate22k916,
      'rate18k': rate18k,
      'rate14k': rate14k,
      'rate9k': rate9k,
    };
  }

  GoldRateProfile copyWith({
    double? rate22k916,
    double? rate18k,
    double? rate14k,
    double? rate9k,
  }) {
    return GoldRateProfile(
      rate22k916: rate22k916 ?? this.rate22k916,
      rate18k: rate18k ?? this.rate18k,
      rate14k: rate14k ?? this.rate14k,
      rate9k: rate9k ?? this.rate9k,
      updatedAt: updatedAt,
    );
  }
}
