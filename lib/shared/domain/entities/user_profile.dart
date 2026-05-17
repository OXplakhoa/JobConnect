import '../../../core/router/user_role.dart';

class UserProfile {
  const UserProfile({
    required this.id,
    required this.role,
    required this.fullName,
    required this.isOnboardingComplete,
    this.avatarUrl,
    this.headline,
    this.bio,
    this.location,
    this.isBanned = false,
  });

  final String id;
  final UserRole role;
  final String fullName;
  final bool isOnboardingComplete;
  final String? avatarUrl;
  final String? headline;
  final String? bio;
  final String? location;
  final bool isBanned;
}
