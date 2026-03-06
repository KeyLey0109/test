import 'package:equatable/equatable.dart';
import '../../domain/entities/profile_entity.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

/// Trạng thái khởi tạo khi vừa vào màn hình
class ProfileInitial extends ProfileState {}

/// Trạng thái đang xử lý (đang tải profile hoặc đang lưu cập nhật)
class ProfileLoading extends ProfileState {}

/// Trạng thái đã tải dữ liệu thành công
class ProfileLoaded extends ProfileState {
  final ProfileEntity profile;

  const ProfileLoaded(this.profile);

  @override
  List<Object?> get props => [profile];
}

/// Trạng thái cập nhật thông tin thành công
/// Dùng để thông báo cho người dùng hoặc quay lại màn hình trước đó
class ProfileUpdateSuccess extends ProfileState {}

/// Trạng thái khi có lỗi xảy ra (lỗi mạng, lỗi server, v.v.)
class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Trạng thái dành cho danh sách bạn bè
class FriendsLoaded extends ProfileState {
  final List<ProfileEntity> friends;

  const FriendsLoaded(this.friends);

  @override
  List<Object?> get props => [friends];
}