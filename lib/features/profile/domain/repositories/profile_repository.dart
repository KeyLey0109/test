import 'package:dartz/dartz.dart';
import '../entities/profile_entity.dart';

abstract class ProfileRepository {
  /// Lấy thông tin chi tiết của một người dùng dựa trên ID
  /// Trả về [ProfileEntity] nếu thành công hoặc một thông báo lỗi [String]
  Future<Either<String, ProfileEntity>> getProfile(String userId);

  /// Cập nhật thông tin cá nhân của người dùng hiện tại
  /// Bao gồm: Tên hiển thị, Ngày sinh, Tiểu sử và đường dẫn ảnh đại diện mới
  Future<Either<String, void>> updateProfile({
    required String userId,
    required String name,
    DateTime? birthDate,
    String? bio,
    String? avatarPath,
  });

  /// Xử lý hành động Kết bạn hoặc Hủy kết bạn (Phong cách Facebook)
  /// Sử dụng [targetUserId] để xác định người nhận yêu cầu
  Future<Either<String, void>> toggleFriendRequest(String targetUserId);

  /// Lấy danh sách bạn bè của một người dùng
  Future<Either<String, List<ProfileEntity>>> getFriends(String userId);
}
