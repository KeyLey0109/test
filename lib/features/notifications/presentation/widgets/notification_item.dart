import 'package:flutter/material.dart';
import '../../domain/entities/notification_entity.dart';
import 'package:intl/intl.dart';

class NotificationItem extends StatelessWidget {
  final NotificationEntity notification;
  final VoidCallback onTap;

  const NotificationItem({
    super.key,
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        // Thông báo chưa đọc sẽ có nền xanh nhạt cực nhẹ
        color: notification.isRead
            ? Colors.white
            : Colors.blue.withValues(alpha: 0.05),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar người gửi thông báo
            Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.grey[200],
                  child: Text(notification.senderName[0].toUpperCase()),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: _buildTypeIcon(),
                ),
              ],
            ),
            const SizedBox(width: 12),

            // Nội dung thông báo
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(color: Colors.black, fontSize: 14),
                      children: [
                        TextSpan(
                          text: notification.senderName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: " ${notification.message}"),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(notification.timestamp),
                    style: TextStyle(
                      color: notification.isRead ? Colors.grey : Colors.blue,
                      fontSize: 12,
                      fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Dấu chấm xanh cho thông báo chưa đọc
            if (!notification.isRead)
              Container(
                margin: const EdgeInsets.only(top: 15),
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Widget hiển thị icon nhỏ góc avatar dựa trên loại thông báo
  Widget _buildTypeIcon() {
    IconData icon;
    Color color;

    switch (notification.type) {
      case NotificationType.like:
        icon = Icons.thumb_up;
        color = const Color(0xFF1877F2);
        break;
      case NotificationType.comment:
        icon = Icons.comment;
        color = Colors.green;
        break;
      case NotificationType.friendRequest:
        icon = Icons.person_add;
        color = Colors.blue;
        break;
      default:
        icon = Icons.notifications;
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Icon(icon, size: 10, color: Colors.white),
    );
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 60) return "${diff.inMinutes} phút trước";
    if (diff.inHours < 24) return "${diff.inHours} giờ trước";
    return DateFormat('dd/MM').format(date);
  }
}