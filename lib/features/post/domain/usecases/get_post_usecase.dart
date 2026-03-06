import 'package:dartz/dartz.dart';
import '../entities/post_entity.dart';
import '../repositories/post_repository.dart';

class GetPostsUseCase {
  final PostRepository repository;

  GetPostsUseCase(this.repository);

  /// Hàm thực thi lấy danh sách bài viết
  /// [userId]: Nếu có, chỉ lấy bài viết của user này (dùng cho trang cá nhân)
  Future<Either<String, List<PostEntity>>> call({String? userId}) async {
    return await repository.getPosts(userId: userId);
  }
}
