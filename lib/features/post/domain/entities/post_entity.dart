import 'package:equatable/equatable.dart';
import '../../../comment/domain/entities/comment_entity.dart';

/// [PostEntity] đại diện cho dữ liệu bài viết tại tầng Domain.
/// Tách biệt logic nghiệp vụ khỏi các chi tiết thực thi ở tầng Data.
class PostEntity extends Equatable {
  final String id;
  final String userId;
  final String userName;
  final String content;
  final String? imagePath;
  final String? videoPath;
  final String? userAvatarUrl; // URL ảnh đại diện của người đăng
  final DateTime timestamp;
  final List<String> likedByUsers; // Danh sách ID người dùng đã like bài viết
  final List<CommentEntity> comments; // Danh sách bình luận

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

  /// Trả về số lượng lượt thích
  int get likeCount => likedByUsers.length;

  /// Trả về số lượng bình luận
  int get commentCount => comments.length;

  /// Kiểm tra xem một người dùng cụ thể đã like bài viết chưa
  bool isLikedBy(String userId) => likedByUsers.contains(userId);

  /// Kiểm tra bài viết có đính kèm hình ảnh không
  bool get hasImage => imagePath != null && imagePath!.isNotEmpty;

  /// Kiểm tra bài viết có đính kèm video không
  bool get hasVideo => videoPath != null && videoPath!.isNotEmpty;

  // --- PHƯƠNG THỨC SAO CHÉP ---

  /// [copyWith] giúp tạo ra một bản sao mới của Entity với các giá trị thay đổi.
  /// Việc sử dụng List.from là cực kỳ quan trọng để tạo vùng nhớ mới,
  /// giúp Bloc nhận diện sự thay đổi trạng thái và cập nhật UI.
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
      // Đảm bảo tạo danh sách mới để phá vỡ tham chiếu cũ
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
