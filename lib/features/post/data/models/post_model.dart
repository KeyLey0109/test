import 'package:appstudyhub/features/post/domain/entities/post_entity.dart';
import 'package:appstudyhub/features/comment/data/models/comment_model.dart';
import 'package:appstudyhub/features/comment/domain/entities/comment_entity.dart';

class PostModel extends PostEntity {
  const PostModel({
    required super.id,
    required super.userId,
    required super.userName,
    required super.content,
    super.imagePath,
    super.videoPath,
    super.userAvatarUrl,
    required super.timestamp,
    super.likedByUsers,
    super.comments,
  });

  /// Chuyển đổi từ JSON (Map) sang PostModel
  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? 'user_id',
      userName: json['userName'] as String? ?? 'Người dùng',
      content: json['content'] as String? ?? '',
      imagePath: json['imagePath'] as String?,
      videoPath: json['videoPath'] as String?,
      userAvatarUrl: json['userAvatarUrl'] as String?,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
      likedByUsers: List<String>.from(json['likedByUsers'] ?? []),
      comments: (json['comments'] as List? ?? [])
          .map((e) => CommentModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Chuyển đổi PostModel sang JSON (Map) để lưu vào SharedPreferences
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'content': content,
      'imagePath': imagePath,
      'videoPath': videoPath,
      'userAvatarUrl': userAvatarUrl,
      'timestamp': timestamp.toIso8601String(),
      'likedByUsers': likedByUsers,
      'comments': comments.map((CommentEntity e) {
        if (e is CommentModel) return e.toJson();
        return CommentModel.fromEntity(e).toJson();
      }).toList(),
    };
  }

  /// Chuyển đổi từ PostEntity sang PostModel
  factory PostModel.fromEntity(PostEntity entity) {
    return PostModel(
      id: entity.id,
      userId: entity.userId,
      userName: entity.userName,
      content: entity.content,
      imagePath: entity.imagePath,
      videoPath: entity.videoPath,
      userAvatarUrl: entity.userAvatarUrl,
      timestamp: entity.timestamp,
      likedByUsers: entity.likedByUsers,
      comments: entity.comments.map<CommentModel>((CommentEntity e) {
        if (e is CommentModel) return e;
        return CommentModel.fromEntity(e);
      }).toList(),
    );
  }

  @override
  PostModel copyWith({
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
    return PostModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      content: content ?? this.content,
      imagePath: imagePath ?? this.imagePath,
      videoPath: videoPath ?? this.videoPath,
      userAvatarUrl: userAvatarUrl ?? this.userAvatarUrl,
      timestamp: timestamp ?? this.timestamp,
      likedByUsers: likedByUsers ?? this.likedByUsers,
      comments: comments ?? this.comments,
    );
  }
}
