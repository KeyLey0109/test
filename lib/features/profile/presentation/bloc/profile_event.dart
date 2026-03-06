import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

/// Sự kiện tải thông tin trang cá nhân
class FetchProfileEvent extends ProfileEvent {
  final String targetUserId;

  const FetchProfileEvent(this.targetUserId);

  @override
  List<Object?> get props => [targetUserId];
}

/// Sự kiện cập nhật chi tiết hồ sơ (Tên, Ngày sinh, Bio, Ảnh)
class UpdateProfileDetailEvent extends ProfileEvent {
  final String name;
  final DateTime? birthDate;
  final String? bio;
  final String? avatarPath; // Đường dẫn ảnh từ Image Picker

  const UpdateProfileDetailEvent({
    required this.name,
    this.birthDate,
    this.bio,
    this.avatarPath,
  });

  @override
  List<Object?> get props => [name, birthDate, bio, avatarPath];
}

/// Sự kiện xử lý Kết bạn hoặc Hủy kết bạn (Phong cách Facebook)
class ToggleFriendRequestEvent extends ProfileEvent {
  final String targetUserId;

  const ToggleFriendRequestEvent(this.targetUserId);

  @override
  List<Object?> get props => [targetUserId];
}

/// Sự kiện tải danh sách bạn bè
class FetchFriendsEvent extends ProfileEvent {
  final String userId;

  const FetchFriendsEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}