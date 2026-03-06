import 'package:dartz/dartz.dart';
import '../entities/post_entity.dart';

/// [PostRepository] là Interface định nghĩa các hành động nghiệp vụ liên quan đến bài viết.
abstract class PostRepository {
  /// Lấy danh sách bài viết từ nguồn dữ liệu (Local Cache hoặc Remote API).
  /// Nếu cung cấp [userId], chỉ lấy bài viết của người dùng đó.
  Future<Either<String, List<PostEntity>>> getPosts({String? userId});

  /// Tạo một bài viết mới với nội dung và phương tiện đính kèm.
  Future<Either<String, void>> createPost({
    required String content,
    required String userId,
    required String userName,
    String? imagePath,
    String? videoPath,
    String? userAvatarUrl,
  });

  /// Xử lý hành động Thích (Like) hoặc Bỏ thích (Unlike) bài viết dựa trên ID.
  Future<Either<String, void>> toggleLike(String postId, String userId);

  /// Thêm một bình luận mới hoặc phản hồi cho bài viết.
  Future<Either<String, void>> addComment({
    required String postId,
    required String content,
    required String userId,
    required String userName,
    String? parentCommentId,
  });
}
