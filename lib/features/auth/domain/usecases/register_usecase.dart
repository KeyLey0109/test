import 'package:dartz/dartz.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  /// Thực thi logic đăng ký tài khoản mới.
  /// Trả về [Either]:
  /// - Left: String (Thông báo lỗi cụ thể)
  /// - Right: UserEntity (Dữ liệu người dùng vừa tạo)
  Future<Either<String, UserEntity>> call({
    required String name,
    required String email,
    required String password,
  }) async {
    // 1. Business Logic Validation (Kiểm tra nghiệp vụ)
    if (name.trim().length < 2) {
      return const Left("Tên phải có ít nhất 2 ký tự");
    }

    if (!email.contains('@') || !email.contains('.')) {
      return const Left("Định dạng email không hợp lệ");
    }

    if (password.length < 6) {
      return const Left("Mật khẩu phải có ít nhất 6 ký tự");
    }

    // 2. Gọi xuống tầng Repository để thực hiện lưu trữ (Mock hoặc API)
    return await repository.register(name, email, password);
  }
}