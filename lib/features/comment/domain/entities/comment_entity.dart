import 'package:equatable/equatable.dart';

/// [CommentEntity] đại diện cho một bình luận hoặc phản hồi trong hệ thống StudyHub.
/// Lớp này hỗ trợ cấu trúc cây (đệ quy) để hiển thị các phản hồi lồng nhau của sinh viên PYU.
class CommentEntity extends Equatable {
  final String id;
  final String userId;
  final String userName;
  final String content;
  final DateTime timestamp;

  /// Danh sách các phản hồi (Cấu trúc đệ quy: Một bình luận chứa nhiều bình luận con)
  final List<CommentEntity> replies;

  const CommentEntity({
    required this.id,
    required this.userId,
    required this.userName,
    required this.content,
    required this.timestamp,
    this.replies = const [],
  });

  // --- PHƯƠNG THỨC SAO CHÉP (Cực kỳ quan trọng cho BLoC State Management) ---

  /// Tạo một bản sao của [CommentEntity] với các thuộc tính được cập nhật.
  /// Sử dụng [List.from] để tạo vùng nhớ mới, giúp Equatable nhận diện thay đổi danh sách.
  CommentEntity copyWith({
    String? id,
    String? userId,
    String? userName,
    String? content,
    DateTime? timestamp,
    List<CommentEntity>? replies,
  }) {
    return CommentEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      // Đảm bảo tạo ra một List mới để tránh lỗi tham chiếu bộ nhớ (Reference error)
      replies: replies ?? List<CommentEntity>.from(this.replies),
    );
  }

  // --- GETTERS TIỆN ÍCH CHO UI ---

  /// Kiểm tra xem đây có phải bình luận của người dùng hiện tại không.
  bool isMyComment(String currentUserId) => userId == currentUserId;

  /// Tính tổng số lượng phản hồi (bao gồm cả các tầng sâu hơn thông qua đệ quy).
  /// Dùng để hiển thị "Xem tất cả X phản hồi" trên StudyHub.
  int get totalRepliesCount {
    int count = replies.length;
    for (var reply in replies) {
      count += reply.totalRepliesCount;
    }
    return count;
  }

  /// Kiểm tra xem bình luận này có chứa phản hồi hay không.
  bool get hasReplies => replies.isNotEmpty;

  /// Định dạng thời gian tương đối (Ví dụ: "2 phút trước")
  /// Bạn có thể dùng thêm package 'timeago' để hỗ trợ phần này ở tầng UI.
  String get formattedDate => "${timestamp.day}/${timestamp.month}/${timestamp.year}";

  @override
  // Equatable so sánh các giá trị này để quyết định việc rebuild UI (tối ưu hiệu năng).
  List<Object?> get props => [
    id,
    userId,
    userName,
    content,
    timestamp,
    replies,
  ];
}