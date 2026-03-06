import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
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
      final posts = await localDataSource.getLastPosts();
      final index = posts.indexWhere((p) => p.id == postId);
      if (index == -1) return const Left("Không tìm thấy bài viết");

      final post = posts[index];

      final newComment = CommentModel(
        id: "cmt_${DateTime.now().millisecondsSinceEpoch}",
        userId: userId,
        userName: userName,
        content: content,
        timestamp: DateTime.now(),
        replies: const [],
      );

      final updatedComments = _getUpdatedComments(
        post.comments,
        parentCommentId,
        newComment,
      );

      posts[index] = PostModel.fromEntity(
        post.copyWith(comments: updatedComments),
      );

      await localDataSource.cachePosts(posts);
      return const Right(null);
    } catch (e) {
      debugPrint("Lỗi addComment: $e");
      return const Left("Lỗi khi gửi bình luận.");
    }
  }

  List<CommentEntity> _getUpdatedComments(
    List<CommentEntity> currentList,
    String? parentId,
    CommentEntity newComment,
  ) {
    if (parentId == null) {
      return [...currentList, newComment];
    }

    return currentList.map((comment) {
      if (comment.id == parentId) {
        return comment.copyWith(replies: [...comment.replies, newComment]);
      } else if (comment.replies.isNotEmpty) {
        return comment.copyWith(
          replies: _getUpdatedComments(comment.replies, parentId, newComment),
        );
      }
      return comment;
    }).toList();
  }

  @override
  Future<Either<String, List<CommentEntity>>> getComments(String postId) async {
    return const Right([]);
  }
}
