class ProductModel {
  const ProductModel({
    required this.id,
    required this.venueId,
    required this.name,
    required this.price,
    required this.isActive,
  });

  final int id;
  final int venueId;
  final String name;
  final double price;
  final bool isActive;

  String get formattedPrice {
    final bool hasDecimals = price % 1 != 0;
    return 'Rs. ${price.toStringAsFixed(hasDecimals ? 2 : 0)}';
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: _asInt(json['id'] ?? json['product_id']),
      venueId: _asInt(json['venue_id'] ?? json['venueId']),
      name: (json['name'] ?? json['title'] ?? '').toString().trim(),
      price: _asDouble(json['price'] ?? json['amount']),
      isActive: _asBool(
        json['is_active'] ?? json['isActive'] ?? json['active'],
      ),
    );
  }

  ProductModel copyWith({
    int? id,
    int? venueId,
    String? name,
    double? price,
    bool? isActive,
  }) {
    return ProductModel(
      id: id ?? this.id,
      venueId: venueId ?? this.venueId,
      name: name ?? this.name,
      price: price ?? this.price,
      isActive: isActive ?? this.isActive,
    );
  }
}

class ProductVenueModel {
  const ProductVenueModel({required this.id, required this.name});

  final int id;
  final String name;

  factory ProductVenueModel.fromJson(Map<String, dynamic> json) {
    return ProductVenueModel(
      id: _asInt(json['id'] ?? json['venue_id'] ?? json['futsal_id']),
      name: (json['name'] ?? json['venue_name'] ?? json['title'] ?? '')
          .toString()
          .trim(),
    );
  }
}

class ProductPayload {
  const ProductPayload({
    required this.venueId,
    required this.name,
    required this.price,
    required this.isActive,
  });

  final int venueId;
  final String name;
  final double price;
  final bool isActive;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'venue_id': venueId,
    'name': name,
    'price': price % 1 == 0 ? price.toInt() : price,
    'is_active': isActive,
  };
}

int _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

double _asDouble(dynamic value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

bool _asBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  final String normalized = value?.toString().trim().toLowerCase() ?? '';
  return normalized == 'true' || normalized == '1' || normalized == 'yes';
}
