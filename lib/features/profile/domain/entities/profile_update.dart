/// Plain data class for profile write operations.
///
/// All fields are nullable because updates can be partial:
/// only the changed fields need to be sent to the API.
class ProfileUpdate {
  const ProfileUpdate({
    this.fullName,
    this.headline,
    this.bio,
    this.location,
    this.avatarUrl,
  });

  final String? fullName;
  final String? headline;
  final String? bio;
  final String? location;
  final String? avatarUrl;

  ProfileUpdate copyWith({
    String? fullName,
    String? headline,
    String? bio,
    String? location,
    String? avatarUrl,
  }) =>
      ProfileUpdate(
        fullName: fullName ?? this.fullName,
        headline: headline ?? this.headline,
        bio: bio ?? this.bio,
        location: location ?? this.location,
        avatarUrl: avatarUrl ?? this.avatarUrl,
      );

  /// Converts non-null fields to a JSON map for Supabase update.
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (fullName != null) map['full_name'] = fullName;
    if (headline != null) map['headline'] = headline;
    if (bio != null) map['bio'] = bio;
    if (location != null) map['location'] = location;
    if (avatarUrl != null) map['avatar_url'] = avatarUrl;
    return map;
  }
}
