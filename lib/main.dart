import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'blocs/product/product_cubit.dart';
import 'blocs/cart/cart_cubit.dart';
import 'blocs/auth/auth_cubit.dart';
import 'models/user.dart';
import 'screens/product_list_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  final authService = AuthService();
  await authService.initialize();
  ApiService().initialize();
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final AuthService authService = AuthService();
  
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthCubit(authService),
        ),
        BlocProvider(
          create: (context) => CartCubit(authService),
        ),
        BlocProvider(
          create: (context) => ProductCubit(ApiService()),
        ),
      ],
      child: Builder(
        builder: (context) {
          final authCubit = context.read<AuthCubit>();
          final cartCubit = context.read<CartCubit>();
          authCubit.setCartCubit(cartCubit);

          return MaterialApp(
            title: 'Product Store',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: Colors.blue,
              visualDensity: VisualDensity.adaptivePlatformDensity,
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black87,
                elevation: 0,
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              outlinedButtonTheme: OutlinedButtonThemeData(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.blue),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            home: BlocBuilder<AuthCubit, AuthState>(
              builder: (context, state) {
                if (state.status == AuthStatus.initial || state.isLoading) {
                  return const Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                
                return const ProductListScreen();
              },
            ),
            routes: {
              '/login': (context) => const LoginScreen(),
              '/signup': (context) => const SignupScreen(),
              '/products': (context) => const ProductListScreen(),
            },
          );
        },
      ),
    );
  }
}




