import 'package:equatable/equatable.dart';

class ProfileEntity extends Equatable {
  final String userId;
  final String userName;
  final String email;
  final DateTime? birthDate;
  final String? bio;
  final String? avatarUrl;
  final String? coverUrl; // <--- Thêm trường này để hết lỗi giao diện
  final List<String> friends;
  final List<String> friendRequests;
  final bool isFriend;
  final bool isPending;

  const ProfileEntity({
    required this.userId,
    required this.userName,
    required this.email,
    this.birthDate,
    this.bio,
    this.avatarUrl,
    this.coverUrl, // <--- Cập nhật Constructor
    this.friends = const [],
    this.friendRequests = const [],
    this.isFriend = false,
    this.isPending = false,
  });

  // Cập nhật copyWith đầy đủ để dùng cho cả chức năng Edit Profile
  ProfileEntity copyWith({
    String? userName,
    DateTime? birthDate,
    String? bio,
    String? avatarUrl,
    String? coverUrl,
    List<String>? friends,
    List<String>? friendRequests,
    bool? isFriend,
    bool? isPending,
  }) {
    return ProfileEntity(
      userId: userId, // ID không thay đổi
      userName: userName ?? this.userName,
      email: email, // Email thường cố định
      birthDate: birthDate ?? this.birthDate,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      coverUrl: coverUrl ?? this.coverUrl,
      friends: friends ?? this.friends,
      friendRequests: friendRequests ?? this.friendRequests,
      isFriend: isFriend ?? this.isFriend,
      isPending: isPending ?? this.isPending,
    );
  }

  @override
  // Thêm đầy đủ các trường vào props để Equatable so sánh chính xác trạng thái
  List<Object?> get props => [
    userId,
    userName,
    email,
    birthDate,
    bio,
    avatarUrl,
    coverUrl,
    friends,
    friendRequests,
    isFriend,
    isPending,
  ];
}