import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/notification_bloc.dart';
import '../bloc/notification_event.dart'; // Đảm bảo import file event riêng biệt
import '../bloc/notification_state.dart';
import '../widgets/notification_item.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    // Gọi tải lại thông báo khi vào màn hình để cập nhật dữ liệu mới nhất
    context.read<NotificationBloc>().add(const LoadNotifications()); // Thêm const
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Thông báo",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: false,
        actions: [
          // Nút đánh dấu tất cả đã đọc
          IconButton(
            icon: const Icon(Icons.done_all, color: Color(0xFF1877F2)),
            onPressed: () {
              context.read<NotificationBloc>().add(const MarkAllAsRead());
            },
          ),
        ],
      ),
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is NotificationLoaded) {
            if (state.notifications.isEmpty) {
              return _buildEmptyState();
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<NotificationBloc>().add(const LoadNotifications());
              },
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: state.notifications.length,
                itemBuilder: (context, index) {
                  final item = state.notifications[index];

                  // Thêm tính năng vuốt để xóa (Dismissible)
                  return Dismissible(
                    key: Key(item.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      color: Colors.red.withValues(alpha: 0.8), // Dùng withValues
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (direction) {
                      context.read<NotificationBloc>().add(DeleteNotification(item.id));
                    },
                    child: NotificationItem(
                      notification: item,
                      onTap: () {
                        // 1. Đánh dấu đã đọc
                        context.read<NotificationBloc>().add(MarkAsRead(item.id));

                        // 2. Logic điều hướng bài viết (Ví dụ)
                        if (item.postId != null) {
                          // Navigator.push...
                        }
                      },
                    ),
                  );
                },
              ),
            );
          }

          return const Center(child: Text("Có lỗi xảy ra khi tải thông báo"));
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none_outlined,
            size: 100,
            color: Colors.grey.withValues(alpha: 0.2), // withValues cho chuẩn UI
          ),
          const SizedBox(height: 16),
          const Text(
            "Bạn chưa có thông báo nào",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}