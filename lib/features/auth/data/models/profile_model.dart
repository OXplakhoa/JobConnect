// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/router/user_role.dart';
import '../../domain/entities/user_profile.dart';

part 'profile_model.freezed.dart';
part 'profile_model.g.dart';

@freezed
class ProfileModel with _$ProfileModel {
  const factory ProfileModel({
    required String id,
    required UserRole role,
    @JsonKey(name: 'full_name') required String fullName,
    @JsonKey(name: 'is_onboarding_complete') required bool isOnboardingComplete,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    String? headline,
    @JsonKey(name: 'is_banned') @Default(false) bool isBanned,
  }) = _ProfileModel;

  factory ProfileModel.fromJson(Map<String, dynamic> json) =>
      _$ProfileModelFromJson(json);

  const ProfileModel._();

  UserProfile toEntity() => UserProfile(
        id: id,
        role: role,
        fullName: fullName,
        isOnboardingComplete: isOnboardingComplete,
        avatarUrl: avatarUrl,
        headline: headline,
        isBanned: isBanned,
      );
}
