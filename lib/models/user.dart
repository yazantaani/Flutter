import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'user.g.dart';

@JsonSerializable()
class AppUser extends Equatable {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? phoneNumber;
  final String? photoURL;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;
  final bool isEmailVerified;
  final bool isGuest;

  const AppUser({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phoneNumber,
    this.photoURL,
    this.createdAt,
    this.lastLoginAt,
    this.isEmailVerified = false,
    this.isGuest = false,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) => _$AppUserFromJson(json);
  Map<String, dynamic> toJson() => _$AppUserToJson(this);

  factory AppUser.guest() => const AppUser(
        id: 'guest',
        email: '',
        firstName: 'Guest',
        lastName: 'User',
        isGuest: true,
      );

  String get fullName => '$firstName $lastName';
  String get displayName => isGuest ? 'Guest' : fullName;
  String get initials => '${firstName[0]}${lastName[0]}';

  AppUser copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? photoURL,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? isEmailVerified,
    bool? isGuest,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoURL: photoURL ?? this.photoURL,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isGuest: isGuest ?? this.isGuest,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        firstName,
        lastName,
        phoneNumber,
        photoURL,
        createdAt,
        lastLoginAt,
        isEmailVerified,
        isGuest,
      ];
}

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

@JsonSerializable()
class AuthState extends Equatable {
  final AuthStatus status;
  final AppUser? user;
  final String? errorMessage;

  const AuthState({
    required this.status,
    this.user,
    this.errorMessage,
  });

  factory AuthState.fromJson(Map<String, dynamic> json) => _$AuthStateFromJson(json);
  Map<String, dynamic> toJson() => _$AuthStateToJson(this);

  factory AuthState.initial() => const AuthState(status: AuthStatus.initial);
  
  factory AuthState.loading() => const AuthState(status: AuthStatus.loading);
  
  factory AuthState.authenticated(AppUser user) => AuthState(
        status: AuthStatus.authenticated,
        user: user,
      );
  
  factory AuthState.unauthenticated() => const AuthState(
        status: AuthStatus.unauthenticated,
      );
  
  factory AuthState.error(String errorMessage) => AuthState(
        status: AuthStatus.error,
        errorMessage: errorMessage,
      );

  bool get isAuthenticated => status == AuthStatus.authenticated && user != null;
  bool get isGuest => user?.isGuest ?? false;
  bool get isLoading => status == AuthStatus.loading;
  bool get hasError => status == AuthStatus.error;

  AuthState copyWith({
    AuthStatus? status,
    AppUser? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, user, errorMessage];
} 