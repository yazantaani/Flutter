import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'product.g.dart';

@JsonSerializable()
class Product extends Equatable {
  final int id;
  final String title;
  final String? description;
  final String category;
  final double price;
  final double? discountPercentage;
  final double? rating;
  final int stock;
  final List<String>? tags;
  final String? brand;
  final String? sku;
  final double? weight;
  final Dimensions? dimensions;
  final String? warrantyInformation;
  final String? shippingInformation;
  final String? availabilityStatus;
  final List<Review>? reviews;
  final String? returnPolicy;
  final int? minimumOrderQuantity;
  final Meta? meta;
  final String? thumbnail;
  final List<String>? images;

  const Product({
    required this.id,
    required this.title,
    this.description,
    required this.category,
    required this.price,
    this.discountPercentage,
    this.rating,
    required this.stock,
    this.tags,
    this.brand,
    this.sku,
    this.weight,
    this.dimensions,
    this.warrantyInformation,
    this.shippingInformation,
    this.availabilityStatus,
    this.reviews,
    this.returnPolicy,
    this.minimumOrderQuantity,
    this.meta,
    this.thumbnail,
    this.images,
  });

  factory Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);
  Map<String, dynamic> toJson() => _$ProductToJson(this);

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        category,
        price,
        discountPercentage,
        rating,
        stock,
        tags,
        brand,
        sku,
        weight,
        dimensions,
        warrantyInformation,
        shippingInformation,
        availabilityStatus,
        reviews,
        returnPolicy,
        minimumOrderQuantity,
        meta,
        thumbnail,
        images,
      ];
}

@JsonSerializable()
class Dimensions extends Equatable {
  final double? width;
  final double? height;
  final double? depth;

  const Dimensions({
    this.width,
    this.height,
    this.depth,
  });

  factory Dimensions.fromJson(Map<String, dynamic> json) => _$DimensionsFromJson(json);
  Map<String, dynamic> toJson() => _$DimensionsToJson(this);

  @override
  List<Object?> get props => [width, height, depth];
}

@JsonSerializable()
class Review extends Equatable {
  final int? rating;
  final String? comment;
  final String? date;
  final String? reviewerName;
  final String? reviewerEmail;

  const Review({
    this.rating,
    this.comment,
    this.date,
    this.reviewerName,
    this.reviewerEmail,
  });

  factory Review.fromJson(Map<String, dynamic> json) => _$ReviewFromJson(json);
  Map<String, dynamic> toJson() => _$ReviewToJson(this);

  @override
  List<Object?> get props => [rating, comment, date, reviewerName, reviewerEmail];
}

@JsonSerializable()
class Meta extends Equatable {
  final String? createdAt;
  final String? updatedAt;
  final String? barcode;
  final String? qrCode;

  const Meta({
    this.createdAt,
    this.updatedAt,
    this.barcode,
    this.qrCode,
  });

  factory Meta.fromJson(Map<String, dynamic> json) => _$MetaFromJson(json);
  Map<String, dynamic> toJson() => _$MetaToJson(this);

  @override
  List<Object?> get props => [createdAt, updatedAt, barcode, qrCode];
}

@JsonSerializable()
class ProductsResponse extends Equatable {
  final List<Product> products;
  final int total;
  final int skip;
  final int limit;

  const ProductsResponse({
    required this.products,
    required this.total,
    required this.skip,
    required this.limit,
  });

  factory ProductsResponse.fromJson(Map<String, dynamic> json) => _$ProductsResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ProductsResponseToJson(this);

  @override
  List<Object> get props => [products, total, skip, limit];
}

@JsonSerializable()
class Category extends Equatable {
  final String slug;
  final String name;
  final String url;

  const Category({
    required this.slug,
    required this.name,
    required this.url,
  });

  factory Category.fromJson(Map<String, dynamic> json) => _$CategoryFromJson(json);
  Map<String, dynamic> toJson() => _$CategoryToJson(this);

  @override
  List<Object> get props => [slug, name, url];
} 