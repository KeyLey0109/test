import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Trạng thái ban đầu (Chưa thao tác gì)
class AuthInitial extends AuthState {}

/// Trạng thái đang xử lý (Hiển thị vòng xoay Loading)
class AuthLoading extends AuthState {}

/// Trạng thái thành công (Đã đăng nhập/đăng ký xong)
class AuthSuccess extends AuthState {
  final UserEntity user;

  const AuthSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

/// Trạng thái thất bại (Hiển thị thông báo lỗi)
class AuthFailure extends AuthState {
  final String message;

  const AuthFailure(this.message);

  @override
  List<Object?> get props => [message];
}