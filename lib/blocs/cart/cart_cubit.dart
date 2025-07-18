import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../models/cart.dart';
import '../../models/product.dart';
import '../../services/auth_service.dart';

part 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  final AuthService _authService;
  static const String _cartKey = 'cart_data';
  
  CartCubit(this._authService) : super(CartInitial()) {
    _loadCart();
  }

  Future<void> _loadCart() async {
    try {
      emit(CartLoading());
      
      final prefs = await SharedPreferences.getInstance();
      final cartData = prefs.getString(_cartKey);
      
      if (cartData != null) {
        final cartJson = json.decode(cartData);
        final cart = Cart.fromJson(cartJson);
        emit(CartLoaded(cart: cart));
      } else {
        emit(CartLoaded(cart: Cart.empty()));
      }
    } catch (e) {
      emit(CartError('Failed to load cart: ${e.toString()}'));
    }
  }

  Future<void> _saveCart(Cart cart) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = json.encode(cart.toJson());
      await prefs.setString(_cartKey, cartJson);
    } catch (e) {
      emit(CartError('Failed to save cart: ${e.toString()}'));
    }
  }

  Future<void> addToCart(Product product, {int quantity = 1}) async {
    try {
      if (state is CartLoaded) {
        final currentState = state as CartLoaded;
        final currentUser = await _authService.getCurrentAppUser();
        
        final updatedCart = currentState.cart.addItem(
          product,
          quantity: quantity,
        );
        
        final cartWithUserId = Cart(
          items: updatedCart.items,
          userId: currentUser?.id,
        );
        
        await _saveCart(cartWithUserId);
        emit(CartLoaded(cart: cartWithUserId));
        emit(CartItemAdded(product: product, quantity: quantity));
        
        emit(CartLoaded(cart: cartWithUserId));
      }
    } catch (e) {
      emit(CartError('Failed to add item to cart: ${e.toString()}'));
    }
  }

  Future<void> removeFromCart(int productId) async {
    try {
      if (state is CartLoaded) {
        final currentState = state as CartLoaded;
        final updatedCart = currentState.cart.removeItem(productId);
        
        await _saveCart(updatedCart);
        emit(CartLoaded(cart: updatedCart));
      }
    } catch (e) {
      emit(CartError('Failed to remove item from cart: ${e.toString()}'));
    }
  }

  Future<void> updateQuantity(int productId, int quantity) async {
    try {
      if (state is CartLoaded) {
        final currentState = state as CartLoaded;
        final updatedCart = currentState.cart.updateQuantity(productId, quantity);
        
        await _saveCart(updatedCart);
        emit(CartLoaded(cart: updatedCart));
      }
    } catch (e) {
      emit(CartError('Failed to update quantity: ${e.toString()}'));
    }
  }

  Future<void> increaseQuantity(int productId) async {
    try {
      if (state is CartLoaded) {
        final currentState = state as CartLoaded;
        final updatedCart = currentState.cart.increaseQuantity(productId);
        
        await _saveCart(updatedCart);
        emit(CartLoaded(cart: updatedCart));
      }
    } catch (e) {
      emit(CartError('Failed to increase quantity: ${e.toString()}'));
    }
  }

  Future<void> decreaseQuantity(int productId) async {
    try {
      if (state is CartLoaded) {
        final currentState = state as CartLoaded;
        final updatedCart = currentState.cart.decreaseQuantity(productId);
        
        await _saveCart(updatedCart);
        emit(CartLoaded(cart: updatedCart));
      }
    } catch (e) {
      emit(CartError('Failed to decrease quantity: ${e.toString()}'));
    }
  }

  Future<void> clearCart() async {
    try {
      if (state is CartLoaded) {
        final currentState = state as CartLoaded;
        final clearedCart = currentState.cart.clear();
        
        await _saveCart(clearedCart);
        emit(CartLoaded(cart: clearedCart));
      }
    } catch (e) {
      emit(CartError('Failed to clear cart: ${e.toString()}'));
    }
  }

  double getCartTotal() {
    if (state is CartLoaded) {
      final currentState = state as CartLoaded;
      return currentState.cart.totalDiscountedPrice;
    }
    return 0.0;
  }

  int getCartItemsCount() {
    if (state is CartLoaded) {
      final currentState = state as CartLoaded;
      return currentState.cart.totalItems;
    }
    return 0;
  }

  bool isProductInCart(int productId) {
    if (state is CartLoaded) {
      final currentState = state as CartLoaded;
      return currentState.cart.hasProduct(productId);
    }
    return false;
  }

  int getProductQuantity(int productId) {
    if (state is CartLoaded) {
      final currentState = state as CartLoaded;
      return currentState.cart.getProductQuantity(productId);
    }
    return 0;
  }

  Future<void> associateCartWithUser(String userId) async {
    try {
      if (state is CartLoaded) {
        final currentState = state as CartLoaded;
        final updatedCart = Cart(
          items: currentState.cart.items,
          userId: userId,
        );
        
        await _saveCart(updatedCart);
        emit(CartLoaded(cart: updatedCart));
      }
    } catch (e) {
      emit(CartError('Failed to associate cart with user: ${e.toString()}'));
    }
  }

  Future<void> clearUserAssociation() async {
    try {
      if (state is CartLoaded) {
        final currentState = state as CartLoaded;
        final updatedCart = Cart(
          items: currentState.cart.items,
          userId: null,
        );
        
        await _saveCart(updatedCart);
        emit(CartLoaded(cart: updatedCart));
      }
    } catch (e) {
      emit(CartError('Failed to clear user association: ${e.toString()}'));
    }
  }

  Future<void> mergeGuestCartWithUserCart(Cart userCart) async {
    try {
      if (state is CartLoaded) {
        final currentState = state as CartLoaded;
        final guestCart = currentState.cart;
        
        Cart mergedCart = userCart;
        for (final guestItem in guestCart.items) {
          mergedCart = mergedCart.addItem(
            guestItem.product,
            quantity: guestItem.quantity,
          );
        }
        
        await _saveCart(mergedCart);
        emit(CartLoaded(cart: mergedCart));
      }
    } catch (e) {
      emit(CartError('Failed to merge carts: ${e.toString()}'));
    }
  }

  Future<void> refreshCart() async {
    await _loadCart();
  }

  void resetCart() {
    emit(CartInitial());
  }
} 