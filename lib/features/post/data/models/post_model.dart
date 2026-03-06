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
  /// Giúp đọc dữ liệu từ SharedPreferences một cách an toàn
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
      // Đảm bảo xử lý mảng likedByUsers để không bị lỗi null
      likedByUsers: List<String>.from(json['likedByUsers'] ?? []),
      // Ép kiểu đệ quy danh sách comments sang CommentModel
      comments: (json['comments'] as List? ?? [])
          .map((e) => CommentModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Chuyển đổi PostModel sang JSON (Map) để lưu vào SharedPreferences
  /// Đây là bước quan trọng để persist dữ liệu Like và Comment xuống máy
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
      // Đảm bảo mọi CommentEntity đều được convert sang Json thông qua Model
      'comments': comments.map((CommentEntity e) {
        if (e is CommentModel) return e.toJson();
        return CommentModel.fromEntity(e).toJson();
      }).toList(),
    };
  }

  /// Chuyển đổi từ PostEntity sang PostModel (Dùng trong Repository/Bloc)
  /// Hàm "cứu cánh" để dứt điểm lỗi "subtype" khi truyền dữ liệu giữa các tầng
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
      // Duyệt danh sách và ép kiểu toàn bộ phần tử sang Model trước khi trả về
      comments: entity.comments.map<CommentModel>((CommentEntity e) {
        if (e is CommentModel) return e;
        return CommentModel.fromEntity(e);
      }).toList(),
    );
  }
}
