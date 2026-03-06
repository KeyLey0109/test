import 'package:dartz/dartz.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  /// Hàm call cho phép gọi usecase như một hàm bình thường: loginUseCase(...)
  /// Trả về [Either]:
  /// - Left: String (Thông báo lỗi)
  /// - Right: UserEntity (Dữ liệu người dùng khi thành công)
  Future<Either<String, UserEntity>> call(String email, String password) async {
    // Bạn có thể thêm logic kiểm tra dữ liệu đầu vào (Validation) tại đây
    // trước khi gửi yêu cầu xuống tầng Repository.

    if (email.isEmpty || password.isEmpty) {
      return const Left("Email và mật khẩu không được để trống");
    }

    if (!email.contains('@')) {
      return const Left("Định dạng email không hợp lệ");
    }

    return await repository.login(email, password);
  }
}