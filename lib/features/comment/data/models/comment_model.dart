import '../../domain/entities/comment_entity.dart';

/// [CommentModel] là phiên bản cụ thể của [CommentEntity] tại tầng Data.
/// Nó cung cấp khả năng chuyển đổi dữ liệu (Serialization) để lưu trữ cục bộ.
class CommentModel extends CommentEntity {

  const CommentModel({
    required super.id,
    required super.userId,
    required super.userName,
    required super.content,
    required super.timestamp,
    required List<CommentModel> super.replies, // Ép kiểu cụ thể cho List replies
  });

  /// Chuyển đổi từ Entity sang Model chuẩn đệ quy.
  /// Đây là "chìa khóa" để dứt điểm lỗi TypeError (màn hình đỏ) khi cập nhật UI.
  factory CommentModel.fromEntity(CommentEntity entity) {
    return CommentModel(
      id: entity.id,
      userId: entity.userId,
      userName: entity.userName,
      content: entity.content,
      timestamp: entity.timestamp,
      // Đệ quy chuyển đổi toàn bộ cây replies sang Model để đồng nhất kiểu dữ liệu
      replies: entity.replies.map((e) => CommentModel.fromEntity(e)).toList(),
    );
  }

  /// Chuyển đổi từ JSON (SharedPreferences) sang Model.
  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      userName: json['userName'] as String? ?? 'Sinh viên PYU',
      content: json['content'] as String? ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
      // Đệ quy nạp các reply con từ JSON an toàn
      replies: (json['replies'] as List? ?? [])
          .map((e) => CommentModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Chuyển đổi từ Model sang JSON để lưu vào bộ nhớ máy.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      // Đảm bảo mọi phần tử trong cây đệ quy đều được gọi toJson()
      'replies': replies.map((e) {
        final model = e is CommentModel ? e : CommentModel.fromEntity(e);
        return model.toJson();
      }).toList(),
    };
  }
}