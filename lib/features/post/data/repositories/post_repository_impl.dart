import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/post_entity.dart';
import '../../domain/repositories/post_repository.dart';
import '../../../comment/domain/repositories/comment_repository.dart';
import '../models/post_model.dart';
import '../datasources/post_local_data_source.dart';

import '../../../comment/domain/entities/comment_entity.dart';
import '../../../comment/data/models/comment_model.dart';

class PostRepositoryImpl implements PostRepository, CommentRepository {
  final PostLocalDataSource localDataSource;

  // Cache trên RAM để xử lý UI mượt mà
  List<PostModel> _postsCache = [];

  PostRepositoryImpl({required this.localDataSource});

  // Tối ưu: Đảm bảo dữ liệu luôn được tải từ máy trước khi xử lý
  Future<void> _ensurePostsLoaded({String? userId}) async {
    if (_postsCache.isEmpty) {
      debugPrint(
          "🔄 Cache trống, đang tải từ local storage cho User: $userId...");
      final cached = await localDataSource.getLastPosts(userId: userId);
      _postsCache = List<PostModel>.from(cached);
      debugPrint("✅ Đã tải ${_postsCache.length} bài viết vào cache.");
    }
    _ensureAdminPostExists();
  }

  @override
  void clearCache() {
    debugPrint("🧹 Đang xóa cache bài viết trong RAM.");
    _postsCache = [];
  }

  void _ensureAdminPostExists() {
    final hasAdminPost = _postsCache.any((p) => p.id == 'admin_welcome_1');
    if (!hasAdminPost) {
      _postsCache.add(
        PostModel(
          id: 'admin_welcome_1',
          userId: 'admin',
          userName: 'Admin StudyHub',
          content:
              'Chào mừng bạn đến với StudyHub! 🎉\n\nĐây là không gian kết nối, chia sẻ kiến thức và hỗ trợ học tập dành riêng cho sinh viên PYU. Hãy thử đăng bài viết đầu tiên của bạn nhé!',
          timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
          userAvatarUrl:
              'https://ui-avatars.com/api/?name=Admin+StudyHub&background=1877F2&color=fff&size=128',
          likedByUsers: const [],
          comments: const [],
        ),
      );
    }
  }

  @override
  Future<Either<String, List<PostEntity>>> getPosts({String? userId}) async {
    try {
      // Nếu userId là null, đây là Home Feed. Ta cần biết user hiện tại hoặc dùng legacy key.
      // Trong PostBloc ta sẽ đảm bảo clearCache khi chuyển user.
      await _ensurePostsLoaded(userId: userId);

      List<PostModel> filteredPosts = _postsCache;
      if (userId != null) {
        filteredPosts = _postsCache
            .where((p) => p.userId == userId || p.userId == 'admin')
            .toList();
      } else {
        // Lưu lại cache cho Home Feed (phân vùng theo user nếu biết)
        await localDataSource.cachePosts(_postsCache, userId: userId);
      }

      return Right(filteredPosts.map((e) => e as PostEntity).toList());
    } catch (e) {
      debugPrint("Lỗi nghiêm trọng tại getPosts: $e");
      return const Left("Không thể tải bài viết.");
    }
  }

  @override
  Future<Either<String, void>> createPost({
    required String content,
    required String userId,
    required String userName,
    String? imagePath,
    String? videoPath,
    String? userAvatarUrl,
  }) async {
    try {
      await _ensurePostsLoaded(userId: userId);
      final newPost = PostModel(
        id: "post_${DateTime.now().millisecondsSinceEpoch}",
        userId: userId,
        userName: userName,
        content: content,
        imagePath: imagePath,
        videoPath: videoPath,
        userAvatarUrl: userAvatarUrl,
        timestamp: DateTime.now(),
        likedByUsers: const [],
        comments: const [],
      );

      _postsCache.insert(0, newPost);
      // Lưu vào cả phân vùng của User và Feed chung để đồng bộ Home Feed
      await localDataSource.cachePosts(_postsCache, userId: userId);
      await localDataSource.cachePosts(_postsCache, userId: null);
      return const Right(null);
    } catch (e) {
      debugPrint("Lỗi khi lưu bài viết: $e");
      return const Left("Lỗi khi đăng bài viết.");
    }
  }

  @override
  Future<Either<String, void>> toggleLike(String postId, String userId) async {
    try {
      await _ensurePostsLoaded(userId: userId);
      final index = _postsCache.indexWhere((p) => p.id == postId);

      if (index != -1) {
        final post = _postsCache[index];
        List<String> newList = List.from(post.likedByUsers);

        newList.contains(userId) ? newList.remove(userId) : newList.add(userId);

        _postsCache[index] =
            PostModel.fromEntity(post.copyWith(likedByUsers: newList));
        await localDataSource.cachePosts(_postsCache, userId: post.userId);
      }
      return const Right(null);
    } catch (e) {
      return const Left("Lỗi cập nhật lượt thích.");
    }
  }

  @override
  Future<Either<String, void>> addComment({
    required String postId,
    required String content,
    required String userId,
    required String userName,
    String? parentCommentId,
  }) async {
    try {
      await _ensurePostsLoaded(userId: userId);
      final index = _postsCache.indexWhere((p) => p.id == postId);
      if (index == -1) return const Left("Không tìm thấy bài viết");

      final post = _postsCache[index];

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

      _postsCache[index] = PostModel.fromEntity(
        post.copyWith(comments: updatedComments),
      );

      await localDataSource.cachePosts(_postsCache, userId: post.userId);
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
