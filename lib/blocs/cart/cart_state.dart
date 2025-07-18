part of 'cart_cubit.dart';

abstract class CartState extends Equatable {
  const CartState();

  @override
  List<Object?> get props => [];
}

class CartInitial extends CartState {}

class CartLoading extends CartState {}

class CartLoaded extends CartState {
  final Cart cart;

  const CartLoaded({required this.cart});

  @override
  List<Object?> get props => [cart];
}

class CartItemAdded extends CartState {
  final Product product;
  final int quantity;

  const CartItemAdded({
    required this.product,
    required this.quantity,
  });

  @override
  List<Object?> get props => [product, quantity];
}

class CartError extends CartState {
  final String message;

  const CartError(this.message);

  @override
  List<Object?> get props => [message];
} 