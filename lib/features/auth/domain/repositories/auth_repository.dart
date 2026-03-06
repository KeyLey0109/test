import 'package:dartz/dartz.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  /// Xử lý đăng nhập với Email và Mật khẩu
  /// Trả về [Either]: Left là thông báo lỗi (String), Right là thông tin người dùng (UserEntity)
  Future<Either<String, UserEntity>> login(String email, String password);

  /// Xử lý đăng ký tài khoản mới
  Future<Either<String, UserEntity>> register(
      String name,
      String email,
      String password
      );

  /// Xử lý đăng xuất
  Future<void> logout();
}