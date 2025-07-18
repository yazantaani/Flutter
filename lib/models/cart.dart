import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
import 'product.dart';

part 'cart.g.dart';

@JsonSerializable()
class CartItem extends Equatable {
  final Product product;
  final int quantity;

  const CartItem({
    required this.product,
    required this.quantity,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) => _$CartItemFromJson(json);
  Map<String, dynamic> toJson() => _$CartItemToJson(this);

  double get totalPrice => product.price * quantity;
  double get discountedPrice => product.price * (1 - (product.discountPercentage ?? 0) / 100);
  double get totalDiscountedPrice => discountedPrice * quantity;

  CartItem copyWith({
    Product? product,
    int? quantity,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  List<Object> get props => [product, quantity];
}

@JsonSerializable()
class Cart extends Equatable {
  final List<CartItem> items;
  final String? userId;

  const Cart({
    required this.items,
    this.userId,
  });

  factory Cart.fromJson(Map<String, dynamic> json) => _$CartFromJson(json);
  Map<String, dynamic> toJson() => _$CartToJson(this);

  factory Cart.empty() => const Cart(items: []);

  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);
  
  double get totalPrice => items.fold(0.0, (sum, item) => sum + item.totalPrice);
  
  double get totalDiscountedPrice => items.fold(0.0, (sum, item) => sum + item.totalDiscountedPrice);
  
  double get totalSavings => totalPrice - totalDiscountedPrice;

  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;

  CartItem? findItem(int productId) {
    try {
      return items.firstWhere((item) => item.product.id == productId);
    } catch (e) {
      return null;
    }
  }

  bool hasProduct(int productId) {
    return items.any((item) => item.product.id == productId);
  }

  int getProductQuantity(int productId) {
    final item = findItem(productId);
    return item?.quantity ?? 0;
  }

  Cart addItem(Product product, {int quantity = 1}) {
    final existingItemIndex = items.indexWhere((item) => item.product.id == product.id);
    
    if (existingItemIndex >= 0) {
      final updatedItems = List<CartItem>.from(items);
      updatedItems[existingItemIndex] = updatedItems[existingItemIndex].copyWith(
        quantity: updatedItems[existingItemIndex].quantity + quantity,
      );
      return Cart(items: updatedItems, userId: userId);
    } else {
      return Cart(
        items: [...items, CartItem(product: product, quantity: quantity)],
        userId: userId,
      );
    }
  }

  Cart removeItem(int productId) {
    return Cart(
      items: items.where((item) => item.product.id != productId).toList(),
      userId: userId,
    );
  }

  Cart updateQuantity(int productId, int quantity) {
    if (quantity <= 0) {
      return removeItem(productId);
    }

    final updatedItems = items.map((item) {
      if (item.product.id == productId) {
        return item.copyWith(quantity: quantity);
      }
      return item;
    }).toList();

    return Cart(items: updatedItems, userId: userId);
  }

  Cart increaseQuantity(int productId) {
    final item = findItem(productId);
    if (item != null) {
      return updateQuantity(productId, item.quantity + 1);
    }
    return this;
  }

  Cart decreaseQuantity(int productId) {
    final item = findItem(productId);
    if (item != null && item.quantity > 1) {
      return updateQuantity(productId, item.quantity - 1);
    } else if (item != null) {
      return removeItem(productId);
    }
    return this;
  }

  Cart clear() {
    return Cart(items: [], userId: userId);
  }

  @override
  List<Object?> get props => [items, userId];
} 