import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/cart/cart_cubit.dart';
import '../screens/cart_screen.dart';

class CartIconWidget extends StatelessWidget {
  const CartIconWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        int itemCount = 0;
        
        if (state is CartLoaded) {
          itemCount = state.cart.totalItems;
        }
        
        return IconButton(
          icon: Stack(
            children: [
              const Icon(
                Icons.shopping_cart_outlined,
                color: Colors.black54,
                size: 24,
              ),
              if (itemCount > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      itemCount > 99 ? '99+' : itemCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CartScreen(),
              ),
            );
          },
        );
      },
    );
  }
} 