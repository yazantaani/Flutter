// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppUser _$AppUserFromJson(Map<String, dynamic> json) => AppUser(
  id: json['id'] as String,
  email: json['email'] as String,
  firstName: json['firstName'] as String,
  lastName: json['lastName'] as String,
  phoneNumber: json['phoneNumber'] as String?,
  photoURL: json['photoURL'] as String?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  lastLoginAt: json['lastLoginAt'] == null
      ? null
      : DateTime.parse(json['lastLoginAt'] as String),
  isEmailVerified: json['isEmailVerified'] as bool? ?? false,
  isGuest: json['isGuest'] as bool? ?? false,
);

Map<String, dynamic> _$AppUserToJson(AppUser instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'phoneNumber': instance.phoneNumber,
  'photoURL': instance.photoURL,
  'createdAt': instance.createdAt?.toIso8601String(),
  'lastLoginAt': instance.lastLoginAt?.toIso8601String(),
  'isEmailVerified': instance.isEmailVerified,
  'isGuest': instance.isGuest,
};

AuthState _$AuthStateFromJson(Map<String, dynamic> json) => AuthState(
  status: $enumDecode(_$AuthStatusEnumMap, json['status']),
  user: json['user'] == null
      ? null
      : AppUser.fromJson(json['user'] as Map<String, dynamic>),
  errorMessage: json['errorMessage'] as String?,
);

Map<String, dynamic> _$AuthStateToJson(AuthState instance) => <String, dynamic>{
  'status': _$AuthStatusEnumMap[instance.status]!,
  'user': instance.user,
  'errorMessage': instance.errorMessage,
};

const _$AuthStatusEnumMap = {
  AuthStatus.initial: 'initial',
  AuthStatus.loading: 'loading',
  AuthStatus.authenticated: 'authenticated',
  AuthStatus.unauthenticated: 'unauthenticated',
  AuthStatus.error: 'error',
};
