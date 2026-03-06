import 'package:equatable/equatable.dart';
import '../../domain/entities/notification_entity.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

/// 1. Trạng thái khởi tạo ban đầu
class NotificationInitial extends NotificationState {}

/// 2. Trạng thái đang tải dữ liệu (Hiện Loading)
class NotificationLoading extends NotificationState {}

/// 3. Trạng thái đã tải dữ liệu thành công
class NotificationLoaded extends NotificationState {
  final List<NotificationEntity> notifications;

  // Tiện ích: Trả về số lượng thông báo chưa đọc ngay lập tức
  int get unreadCount => notifications.where((n) => !n.isRead).length;

  const NotificationLoaded(this.notifications);

  @override
  List<Object?> get props => [notifications];
}

/// 4. Trạng thái gặp lỗi khi tải hoặc cập nhật
class NotificationError extends NotificationState {
  final String message;

  const NotificationError(this.message);

  @override
  List<Object?> get props => [message];
}