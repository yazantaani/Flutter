import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/user.dart';
import '../../services/auth_service.dart';
import '../cart/cart_cubit.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthService _authService;
  CartCubit? _cartCubit;
  
  AuthCubit(this._authService) : super(AuthState.initial()) {
    _authService.authStateChanges.listen(_onAuthStateChanged);
    _checkAuthState();
  }

  void setCartCubit(CartCubit cartCubit) {
    _cartCubit = cartCubit;
  }

  Future<void> _checkAuthState() async {
    try {
      
      final user = await _authService.getCurrentAppUser();
      if (user != null) {
        emit(AuthState.authenticated(user));
      } else {
        await signInAsGuest();
      }
    } catch (e) {
      emit(AuthState.unauthenticated());
    }
  }

  void _onAuthStateChanged(User? user) async {
    try {
      
      if (user != null) {
        final appUser = await _authService.getCurrentAppUser();
        if (appUser != null) {
          emit(AuthState.authenticated(appUser));
        } else {
          await signInAsGuest();
        }
      } else {
        await signInAsGuest();
      }
    } catch (e) {
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      emit(AuthState.loading());
      
      final user = await _authService.signUpWithEmailAndPassword(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
      );
      
      _cartCubit?.clearCart();

      emit(AuthState.authenticated(user));
    } catch (e) {
      emit(AuthState.error(e.toString()));
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      emit(AuthState.loading());
      
      final user = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      _cartCubit?.clearCart();

      emit(AuthState.authenticated(user));
    } catch (e) {
      emit(AuthState.error(e.toString()));
    }
  }

  Future<void> signInAsGuest() async {
    try {
      emit(AuthState.loading());
      
      final user = await _authService.signInAsGuest();
      
      emit(AuthState.authenticated(user));
    } catch (e) {
      emit(AuthState.error(e.toString()));
    }
  }

  Future<void> signOut() async {
    try {
      emit(AuthState.loading());
      
      await _authService.signOut();
      
      _cartCubit?.clearCart();
      
      emit(AuthState.unauthenticated());
    } catch (e) {
      emit(AuthState.error(e.toString()));
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      emit(AuthState.loading());
      
      await _authService.resetPassword(email);
      
      emit(AuthPasswordResetSent());
    } catch (e) {
      emit(AuthState.error(e.toString()));
    }
  }

  Future<void> convertGuestToUser({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      emit(AuthState.loading());
      
      final user = await _authService.convertGuestToUser(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
      );
      
      emit(AuthState.authenticated(user));
    } catch (e) {
      emit(AuthState.error(e.toString()));
    }
  }

  Future<void> updateProfile({
    String? firstName,
    String? lastName,
    String? photoURL,
  }) async {
    try {
      emit(AuthState.loading());
      
      final user = await _authService.updateUserProfile(
        firstName: firstName,
        lastName: lastName,
        photoURL: photoURL,
      );
      
      emit(AuthState.authenticated(user));
    } catch (e) {
      emit(AuthState.error(e.toString()));
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      emit(AuthState.loading());
      
      await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      
      emit(AuthPasswordChanged());
      
      final user = await _authService.getCurrentAppUser();
      if (user != null) {
        emit(AuthState.authenticated(user));
      } else {
        emit(AuthState.unauthenticated());
      }
    } catch (e) {
      emit(AuthState.error(e.toString()));
    }
  }

  Future<void> sendEmailVerification() async {
    try {
      emit(AuthState.loading());
      
      await _authService.sendEmailVerification();
      
      emit(AuthEmailVerificationSent());
      
      final user = await _authService.getCurrentAppUser();
      if (user != null) {
        emit(AuthState.authenticated(user));
      } else {
        emit(AuthState.unauthenticated());
      }
    } catch (e) {
      emit(AuthState.error(e.toString()));
    }
  }

  Future<void> deleteAccount() async {
    try {
      emit(AuthState.loading());
      
      await _authService.deleteAccount();
      
      emit(AuthState.unauthenticated());
    } catch (e) {
      emit(AuthState.error(e.toString()));
    }
  }

  Future<void> clearAllAuthData() async {
    try {
      emit(AuthState.loading());

      await _authService.clearAllAuthData();

      emit(AuthState.unauthenticated());
    } catch (e) {
      emit(AuthState.error(e.toString()));
    }
  }

  AppUser? get currentUser {
    if (state.isAuthenticated) {
      return state.user;
    }
    return null;
  }

  bool get isAuthenticated => state.isAuthenticated;

  bool get isGuest => state.isGuest;

  bool get isLoading => state.isLoading;

  bool get hasError => state.hasError;

  String? get errorMessage => state.errorMessage;

  void clearError() {
    if (state.hasError) {
      if (state.user != null) {
        emit(AuthState.authenticated(state.user!));
      } else {
        emit(AuthState.unauthenticated());
      }
    }
  }

  Future<void> refreshUser() async {
    await _checkAuthState();
  }

  void reset() {
    emit(AuthState.initial());
  }
} 