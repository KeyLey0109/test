import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// 1. Sự kiện kiểm tra trạng thái khi vừa mở App
/// Giúp HomePage biết nên hiện Profile hay quay về trang Login
class AppStarted extends AuthEvent {}

/// 2. Sự kiện Đăng nhập
class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

/// 3. Sự kiện Đăng ký
class RegisterRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;

  const RegisterRequested({
    required this.name,
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [name, email, password];
}

/// 4. Sự kiện Đăng xuất
/// Khi bấm nút Logout trên HomePage, sự kiện này sẽ kích hoạt
class LogoutRequested extends AuthEvent {}