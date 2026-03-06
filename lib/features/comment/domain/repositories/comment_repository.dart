import 'package:dartz/dartz.dart';
import '../entities/comment_entity.dart';

abstract class CommentRepository {
  // Thêm bình luận hoặc câu trả lời (nếu có parentCommentId)
  Future<Either<String, void>> addComment({
    required String postId,
    required String content,
    required String userId,
    required String userName,
    String? parentCommentId,
  });

  // Lấy danh sách bình luận của một bài viết
  Future<Either<String, List<CommentEntity>>> getComments(String postId);
}