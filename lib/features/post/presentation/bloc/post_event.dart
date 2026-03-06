import 'package:equatable/equatable.dart';
import '../../domain/entities/post_entity.dart';

abstract class PostEvent extends Equatable {
  const PostEvent();

  @override
  List<Object?> get props => [];
}

/// 1. Tải danh sách bài viết
class LoadPosts extends PostEvent {
  final String? userId;
  const LoadPosts({this.userId});

  @override
  List<Object?> get props => [userId];
}

/// 2. Sự kiện đăng bài viết mới
class CreatePostRequested extends PostEvent {
  final String content;
  final String userId;
  final String userName;
  final String? imagePath;
  final String? videoPath;
  final String? userAvatarUrl;

  const CreatePostRequested({
    required this.content,
    required this.userId,
    required this.userName,
    this.imagePath,
    this.videoPath,
    this.userAvatarUrl,
  });

  @override
  List<Object?> get props =>
      [content, userId, userName, imagePath, videoPath, userAvatarUrl];
}

/// 3. Sự kiện Thích/Bỏ thích bài viết (Toggle Like)
class ToggleLike extends PostEvent {
  final String postId;

  const ToggleLike({required this.postId});

  @override
  List<Object?> get props => [postId];
}

/// 4. Sự kiện thêm bình luận
class AddComment extends PostEvent {
  final String postId;
  final String commentContent;

  const AddComment({
    required this.postId,
    required this.commentContent,
  });

  @override
  List<Object?> get props => [postId, commentContent];
}

/// 5. Cập nhật bài viết cục bộ (Local Update)
class UpdatePost extends PostEvent {
  final PostEntity post;

  const UpdatePost({required this.post});

  @override
  List<Object?> get props => [post];
}

/// 6. Xóa bài viết
class DeletePost extends PostEvent {
  final String postId;

  const DeletePost({required this.postId});

  @override
  List<Object?> get props => [postId];
}
