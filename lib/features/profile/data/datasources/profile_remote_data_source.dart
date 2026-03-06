import '../models/profile_model.dart';
import '../../../auth/data/datasources/fake_auth_data_source.dart';

abstract class ProfileRemoteDataSource {
  /// Lấy dữ liệu profile từ Server/Firebase
  Future<ProfileModel> getProfile(String userId);

  /// Cập nhật thông tin cá nhân: tên, ngày sinh, tiểu sử, ảnh
  Future<void> updateProfile({
    required String userId,
    required String name,
    DateTime? birthDate,
    String? bio,
    String? avatarUrl,
  });

  /// Xử lý gửi hoặc hủy lời mời kết bạn
  Future<void> toggleFriendRequest(String targetUserId);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final FakeAuthDataSource fakeAuthDataSource;

  ProfileRemoteDataSourceImpl({required this.fakeAuthDataSource});

  @override
  Future<ProfileModel> getProfile(String userId) async {
    try {
      // Tìm kiếm user từ nguồn danh sách đăng ký giả lập
      final users = fakeAuthDataSource.users;
      final existingUser = users.firstWhere(
        (u) => u['id'] == userId,
        orElse: () => {},
      );

      return ProfileModel(
        userId: userId,
        userName: existingUser['name'] ??
            (userId.startsWith('user_')
                ? "Người dùng ${userId.substring(5)}"
                : "Sinh viên PYU"),
        email: existingUser['email'] ?? "student.$userId@pyu.edu.vn",
        birthDate: existingUser['birthDate'] as DateTime?, // Lấy từ memory
        bio: existingUser['bio'] ?? // Lấy từ memory
            (existingUser['id'] == 'admin'
                ? "Quản trị viên hệ thống StudyHub"
                : "Đang học tại Đại học Phú Yên"),
        avatarUrl: existingUser['avatarUrl'] as String?, // Lấy từ memory
        isFriend: false,
        isPending: false,
      );
    } catch (e) {
      throw Exception("Lỗi khi kết nối Server: $e");
    }
  }

  @override
  Future<void> updateProfile({
    required String userId,
    required String name,
    DateTime? birthDate,
    String? bio,
    String? avatarUrl,
  }) async {
    try {
      fakeAuthDataSource.updateUser(
        userId,
        name: name,
        birthDate: birthDate,
        bio: bio,
        avatarUrl: avatarUrl,
      );
    } catch (e) {
      throw Exception("Không thể cập nhật thông tin cá nhân: $e");
    }
  }

  @override
  Future<void> toggleFriendRequest(String targetUserId) async {
    try {
      // Logic gửi lời mời kết bạn phong cách Facebook
      // Thêm userId của mình vào mảng friendRequests của đối phương
    } catch (e) {
      throw Exception("Lỗi thao tác kết bạn");
    }
  }
}
