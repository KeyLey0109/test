import '../../domain/entities/profile_entity.dart';

class ProfileModel extends ProfileEntity {
  const ProfileModel({
    required super.userId,
    required super.userName,
    required super.email,
    super.birthDate,
    super.bio,
    super.avatarUrl,
    super.isFriend,
    super.isPending,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json, String currentUserId) {
    return ProfileModel(
      userId: json['id'] ?? '',
      userName: json['name'] ?? '',
      email: json['email'] ?? '',
      birthDate: json['birthDate'] != null ? DateTime.parse(json['birthDate']) : null,
      bio: json['bio'],
      avatarUrl: json['avatarUrl'],
      isFriend: (json['friends'] as List? ?? []).contains(currentUserId),
      isPending: (json['friendRequests'] as List? ?? []).contains(currentUserId),
    );
  }
}