// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProfileModelImpl _$$ProfileModelImplFromJson(Map<String, dynamic> json) =>
    _$ProfileModelImpl(
      id: json['id'] as String,
      role: $enumDecode(_$UserRoleEnumMap, json['role']),
      fullName: json['full_name'] as String,
      isOnboardingComplete: json['is_onboarding_complete'] as bool,
      avatarUrl: json['avatar_url'] as String?,
      headline: json['headline'] as String?,
      isBanned: json['is_banned'] as bool? ?? false,
    );

Map<String, dynamic> _$$ProfileModelImplToJson(_$ProfileModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'role': _$UserRoleEnumMap[instance.role]!,
      'full_name': instance.fullName,
      'is_onboarding_complete': instance.isOnboardingComplete,
      'avatar_url': instance.avatarUrl,
      'headline': instance.headline,
      'is_banned': instance.isBanned,
    };

const _$UserRoleEnumMap = {
  UserRole.seeker: 'seeker',
  UserRole.recruiter: 'recruiter',
  UserRole.admin: 'admin',
};
