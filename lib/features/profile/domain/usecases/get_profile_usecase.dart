import 'package:dartz/dartz.dart';
import '../entities/profile_entity.dart';
import '../repositories/profile_repository.dart';

class GetProfileUseCase {
  final ProfileRepository repository;

  /// Khởi tạo UseCase với Repository Interface từ tầng Domain
  GetProfileUseCase(this.repository);

  /// Hàm thực thi lấy thông tin Profile dựa trên userId
  /// Trả về [Either]:
  /// - Bên trái (Left): Một chuỗi [String] chứa thông báo lỗi
  /// - Bên phải (Right): Đối tượng [ProfileEntity] chứa dữ liệu người dùng
  Future<Either<String, ProfileEntity>> call(String userId) async {
    return await repository.getProfile(userId);
  }
}