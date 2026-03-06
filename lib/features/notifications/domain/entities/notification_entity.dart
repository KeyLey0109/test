import 'package:equatable/equatable.dart';

// Phân loại các kiểu thông báo trong StudyHub
enum NotificationType {
  like,
  comment,
  friendRequest,
  friendAccepted,
  postMention,
}

class NotificationEntity extends Equatable {
  final String id;
  final String senderId;
  final String senderName;
  final String? senderAvatar;
  final String? postId; // Để điều hướng đến bài viết khi nhấn vào
  final String message;
  final NotificationType type;
  final DateTime timestamp;
  final bool isRead;

  const NotificationEntity({
    required this.id,
    required this.senderId,
    required this.senderName,
    this.senderAvatar,
    this.postId,
    required this.message,
    required this.type,
    required this.timestamp,
    this.isRead = false,
  });

  // Tạo bản sao để cập nhật trạng thái "Đã đọc" (Optimistic UI)
  NotificationEntity copyWith({bool? isRead}) {
    return NotificationEntity(
      id: id,
      senderId: senderId,
      senderName: senderName,
      senderAvatar: senderAvatar,
      postId: postId,
      message: message,
      type: type,
      timestamp: timestamp,
      isRead: isRead ?? this.isRead,
    );
  }

  @override
  List<Object?> get props => [id, isRead, timestamp];
}