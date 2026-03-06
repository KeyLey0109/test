import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Pages
import 'home_page.dart';
import '../../../notifications/presentation/pages/notification_screen.dart';
import '../../../profile/presentation/pages/profile_screen.dart';

// Blocs
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../notifications/presentation/bloc/notification_bloc.dart';
import '../../../notifications/presentation/bloc/notification_state.dart';
import '../bloc/post_bloc.dart';
import '../bloc/post_event.dart';

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Đảm bảo mỗi khi vào RootPage (Đăng nhập mới), bẳng tin luôn được làm mới
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PostBloc>().add(const LoadPosts());
    });
  }

  @override
  Widget build(BuildContext context) {
    // 1. Lấy thông tin User ID từ AuthBloc (Dùng watch để UI tự rebuild khi user thay đổi)
    final authState = context.watch<AuthBloc>().state;
    String currentUserId = "";

    if (authState is AuthSuccess) {
      currentUserId = authState.user.id;
    }

    // 2. Khởi tạo danh sách các trang ngay trong hàm build.
    // Lưu ý: KHÔNG dùng từ khóa 'const' trước mảng này vì ProfileScreen nhận biến động.
    final List<Widget> pages = [
      const HomePage(),
      const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.video_library_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text("Tính năng Video đang phát triển",
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
      const NotificationScreen(),
      // Chỉ render Profile khi đã có ID, tránh lỗi truyền chuỗi rỗng
      currentUserId.isNotEmpty
          ? ProfileScreen(userId: currentUserId, isCurrentUser: true)
          : const Center(child: CircularProgressIndicator()),
    ];

    return Scaffold(
      // IndexedStack cực kỳ quan trọng: Nó giữ nguyên vị trí cuộn của HomePage
      // khi sinh viên PYU chuyển sang tab Thông báo rồi quay lại.
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  /// Widget thanh điều hướng dưới cùng
  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        border:
            Border(top: BorderSide(color: Colors.grey.shade200, width: 0.5)),
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          // Nếu nhấn lại vào tab đang chọn (Trang chủ), Việt có thể thêm logic scroll to top ở đây
          setState(() => _currentIndex = index);
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF1877F2), // Màu xanh thương hiệu
        unselectedItemColor: Colors.black54,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        elevation: 0,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_filled),
            label: "Trang chủ",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.ondemand_video_outlined),
            activeIcon: Icon(Icons.ondemand_video),
            label: "Video",
          ),
          BottomNavigationBarItem(
            icon: _buildNotificationBadge(isActive: _currentIndex == 2),
            label: "Thông báo",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: "Cá nhân",
          ),
        ],
      ),
    );
  }

  /// Widget hiển thị Badge số lượng thông báo chưa đọc
  Widget _buildNotificationBadge({required bool isActive}) {
    return BlocBuilder<NotificationBloc, NotificationState>(
      builder: (context, state) {
        int unreadCount = 0;
        if (state is NotificationLoaded) {
          unreadCount = state.notifications.where((n) => !n.isRead).length;
        }

        return Badge(
          isLabelVisible: unreadCount > 0,
          label: Text(unreadCount > 9 ? '9+' : '$unreadCount'),
          backgroundColor: Colors.red,
          child: Icon(isActive
              ? Icons.notifications
              : Icons.notifications_none_outlined),
        );
      },
    );
  }
}
