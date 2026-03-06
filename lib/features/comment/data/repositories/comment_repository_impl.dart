import 'package:dartz/dartz.dart';
import '../../domain/entities/comment_entity.dart';
import '../../domain/repositories/comment_repository.dart';
import '../models/comment_model.dart';
import '../../../post/data/datasources/post_local_data_source.dart';
import '../../../post/data/models/post_model.dart';

class CommentRepositoryImpl implements CommentRepository {
  final PostLocalDataSource localDataSource;

  CommentRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<String, void>> addComment({
    required String postId,
    required String content,
    required String userId,
    required String userName,
    String? parentCommentId,
  }) async {
    try {
      // SỬA LỖI TẠI ĐÂY: Đổi thành getLastPosts() cho khớp với DataSource của Việt
      final posts = await localDataSource.getLastPosts();

      final postIndex = posts.indexWhere((p) => p.id == postId);
      if (postIndex == -1) return const Left("Không tìm thấy bài viết");

      final newComment = CommentModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        userName: userName,
        content: content,
        timestamp: DateTime.now(),
        replies: const [],
      );

      final currentPost = posts[postIndex];
      List<CommentEntity> updatedComments = List.from(currentPost.comments);

      if (parentCommentId == null) {
        updatedComments.add(newComment);
      } else {
        // Thuật toán đệ quy tìm cha để chèn Reply
        _findAndAddReply(updatedComments, parentCommentId, newComment);
      }

      // Cập nhật lại bài viết và lưu xuống SharedPreferences
      posts[postIndex] = PostModel.fromEntity(currentPost.copyWith(comments: updatedComments));
      await localDataSource.cachePosts(posts);

      return const Right(null);
    } catch (e) {
      return Left("Lỗi khi gửi bình luận: $e");
    }
  }

  // Hàm đệ quy xử lý đa tầng
  void _findAndAddReply(List<CommentEntity> list, String parentId, CommentEntity reply) {
    for (int i = 0; i < list.length; i++) {
      if (list[i].id == parentId) {
        list[i] = list[i].copyWith(replies: [...list[i].replies, reply]);
        return;
      }
      if (list[i].replies.isNotEmpty) {
        _findAndAddReply(list[i].replies, parentId, reply);
      }
    }
  }

  @override
  Future<Either<String, List<CommentEntity>>> getComments(String postId) async {
    return const Right([]);
  }
}