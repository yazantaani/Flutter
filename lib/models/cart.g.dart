// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CartItem _$CartItemFromJson(Map<String, dynamic> json) => CartItem(
  product: Product.fromJson(json['product'] as Map<String, dynamic>),
  quantity: (json['quantity'] as num).toInt(),
);

Map<String, dynamic> _$CartItemToJson(CartItem instance) => <String, dynamic>{
  'product': instance.product,
  'quantity': instance.quantity,
};

Cart _$CartFromJson(Map<String, dynamic> json) => Cart(
  items: (json['items'] as List<dynamic>)
      .map((e) => CartItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  userId: json['userId'] as String?,
);

Map<String, dynamic> _$CartToJson(Cart instance) => <String, dynamic>{
  'items': instance.items,
  'userId': instance.userId,
};
