import 'package:equatable/equatable.dart';
import '../../../comment/domain/entities/comment_entity.dart';

/// [PostEntity] đại diện cho dữ liệu bài viết tại tầng Domain.
class PostEntity extends Equatable {
  final String id;
  final String userId;
  final String userName;
  final String content;
  final String? imagePath;
  final String? videoPath;
  final String? userAvatarUrl;
  final DateTime timestamp;
  final List<String> likedByUsers;
  final List<CommentEntity> comments;

  const PostEntity({
    required this.id,
    required this.userId,
    required this.userName,
    required this.content,
    this.imagePath,
    this.videoPath,
    this.userAvatarUrl,
    required this.timestamp,
    this.likedByUsers = const [],
    this.comments = const [],
  });

  // --- GETTERS TIỆN ÍCH ---

  int get likeCount => likedByUsers.length;
  int get commentCount => comments.length;
  bool isLikedBy(String userId) => likedByUsers.contains(userId);
  bool get hasImage => imagePath != null && imagePath!.isNotEmpty;
  bool get hasVideo => videoPath != null && videoPath!.isNotEmpty;

  // --- PHƯƠNG THỨC SAO CHÉP ---

  PostEntity copyWith({
    String? id,
    String? userId,
    String? userName,
    String? content,
    String? imagePath,
    String? videoPath,
    String? userAvatarUrl,
    DateTime? timestamp,
    List<String>? likedByUsers,
    List<CommentEntity>? comments,
  }) {
    return PostEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      content: content ?? this.content,
      imagePath: imagePath ?? this.imagePath,
      videoPath: videoPath ?? this.videoPath,
      userAvatarUrl: userAvatarUrl ?? this.userAvatarUrl,
      timestamp: timestamp ?? this.timestamp,
      likedByUsers: likedByUsers ?? List<String>.from(this.likedByUsers),
      comments: comments ?? List<CommentEntity>.from(this.comments),
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        userName,
        content,
        imagePath,
        videoPath,
        userAvatarUrl,
        timestamp,
        likedByUsers,
        comments,
      ];
}
