import 'package:equatable/equatable.dart';
import '../../domain/entities/notification_entity.dart';

/// Lớp trừu tượng cơ sở cho mọi sự kiện liên quan đến Thông báo
abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

/// 1. Sự kiện tải danh sách thông báo
/// Được gọi khi mở App (main.dart) hoặc vào màn hình NotificationScreen
class LoadNotifications extends NotificationEvent {
  const LoadNotifications();
}

/// 2. Sự kiện đánh dấu một thông báo cụ thể là đã đọc
/// Thường dùng khi người dùng nhấn vào một Item trong danh sách
class MarkAsRead extends NotificationEvent {
  final String notificationId;

  const MarkAsRead(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

/// 3. Sự kiện đánh dấu TẤT CẢ thông báo trong danh sách là đã đọc
class MarkAllAsRead extends NotificationEvent {
  const MarkAllAsRead();
}

/// 4. Sự kiện xóa một thông báo khỏi danh sách (Tính năng vuốt để xóa)
class DeleteNotification extends NotificationEvent {
  final String notificationId;

  const DeleteNotification(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

/// 5. Sự kiện nhận thông báo mới theo thời gian thực (Real-time)
/// Dùng khi tích hợp với Firebase Cloud Messaging hoặc WebSockets
class NotificationReceived extends NotificationEvent {
  final NotificationEntity notification;

  const NotificationReceived(this.notification);

  @override
  List<Object?> get props => [notification];
}
