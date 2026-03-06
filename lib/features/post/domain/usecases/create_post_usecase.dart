import 'package:dartz/dartz.dart';
import '../repositories/post_repository.dart';

class CreatePostUseCase {
  final PostRepository repository;

  CreatePostUseCase(this.repository);

  /// Hàm call thực hiện nghiệp vụ đăng bài viết
  Future<Either<String, void>> call({
    required String content,
    required String userId,
    required String userName,
    String? imagePath,
    String? videoPath,
    String? userAvatarUrl,
  }) async {
    // 1. Kiểm tra nội dung trống
    if (content.trim().isEmpty && imagePath == null && videoPath == null) {
      return const Left("Vui lòng nhập nội dung hoặc chọn ảnh/video!");
    }

    // 2. Gọi xuống Repository để xử lý lưu trữ
    return await repository.createPost(
      content: content.trim(),
      userId: userId,
      userName: userName,
      imagePath: imagePath,
      videoPath: videoPath,
      userAvatarUrl: userAvatarUrl,
    );
  }
}
