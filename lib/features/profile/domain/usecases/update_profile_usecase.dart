import 'package:dartz/dartz.dart';
import '../repositories/profile_repository.dart';

class UpdateProfileUseCase {
  final ProfileRepository repository;

  /// Khởi tạo UseCase với Repository Interface
  UpdateProfileUseCase(this.repository);

  /// Hàm thực thi cập nhật thông tin cá nhân
  ///
  /// Các tham số:
  /// - [name]: Tên mới của người dùng (Bắt buộc)
  /// - [birthDate]: Ngày tháng năm sinh mới (Tùy chọn)
  /// - [bio]: Tiểu sử hoặc giới thiệu bản thân (Tùy chọn)
  /// - [avatarPath]: Đường dẫn cục bộ của ảnh vừa chọn từ Image Picker (Tùy chọn)
  ///
  /// Trả về [Either]:
  /// - [Left]: Chuỗi thông báo lỗi nếu quá trình cập nhật thất bại
  /// - [Right]: Trả về void (null) nếu cập nhật thành công
  Future<Either<String, void>> call({
    required String userId,
    required String name,
    DateTime? birthDate,
    String? bio,
    String? avatarPath,
  }) async {
    return await repository.updateProfile(
      userId: userId,
      name: name,
      birthDate: birthDate,
      bio: bio,
      avatarPath: avatarPath,
    );
  }
}
