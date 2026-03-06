import 'package:dartz/dartz.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<String, ProfileEntity>> getProfile(String userId) async {
    try {
      // Gọi Data Source để lấy Model
      final profileModel = await remoteDataSource.getProfile(userId);
      // Trả về Entity (Model kế thừa từ Entity nên có thể trả về trực tiếp)
      return Right(profileModel);
    } catch (e) {
      return Left("Không thể tải thông tin: ${e.toString()}");
    }
  }

  @override
  Future<Either<String, void>> updateProfile({
    required String userId,
    required String name,
    DateTime? birthDate,
    String? bio,
    String? avatarPath,
  }) async {
    try {
      // Thực hiện cập nhật thông tin
      await remoteDataSource.updateProfile(
        userId: userId,
        name: name,
        birthDate: birthDate,
        bio: bio,
        avatarUrl: avatarPath, // Trong thực tế sẽ xử lý upload ảnh tại đây
      );
      return const Right(null);
    } catch (e) {
      return Left("Cập nhật thất bại: ${e.toString()}");
    }
  }

  @override
  Future<Either<String, void>> toggleFriendRequest(String targetUserId) async {
    try {
      // Xử lý gửi/hủy lời mời kết bạn phong cách Facebook
      await remoteDataSource.toggleFriendRequest(targetUserId);
      return const Right(null);
    } catch (e) {
      return Left("Lỗi thao tác bạn bè: ${e.toString()}");
    }
  }

  @override
  Future<Either<String, List<ProfileEntity>>> getFriends(String userId) async {
    try {
      // Giả lập lấy danh sách bạn bè (sau này Việt dùng RemoteDataSource để lấy thật)
      return const Right([]);
    } catch (e) {
      return const Left("Không thể lấy danh sách bạn bè");
    }
  }
}
