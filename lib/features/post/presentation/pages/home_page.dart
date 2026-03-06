import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

// --- BLoC & Events ---
import '../bloc/post_bloc.dart';
import '../bloc/post_event.dart';
import '../bloc/post_state.dart';
import '../widgets/post_card.dart';

// --- Domain ---
import '../../domain/entities/post_entity.dart'; // Đảm bảo import Entity

// --- Auth ---
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/presentation/bloc/auth_event.dart';

// --- Notifications ---
import '../../../notifications/presentation/pages/notification_screen.dart';
import '../../../notifications/presentation/bloc/notification_bloc.dart';
import '../../../notifications/presentation/bloc/notification_event.dart';
import '../../../notifications/presentation/bloc/notification_state.dart';

// --- Profile ---
import '../../../profile/presentation/pages/profile_screen.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final String uName =
        (authState is AuthSuccess) ? authState.user.name : "Sinh viên";

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      body: RefreshIndicator(
        onRefresh: () async {
          // Kích hoạt load lại dữ liệu
          context.read<PostBloc>().add(const LoadPosts());
          context.read<NotificationBloc>().add(const LoadNotifications());
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            _buildSliverAppBar(context, authState),
            SliverToBoxAdapter(child: _buildStatusHeader(context, uName)),
            _buildCreatingIndicator(),
            const SliverToBoxAdapter(child: SizedBox(height: 8)),
            _buildPostList(),
          ],
        ),
      ),
    );
  }

  // --- 1. AppBar Tối ưu ---
  Widget _buildSliverAppBar(BuildContext context, AuthState authState) {
    return SliverAppBar(
      floating: true,
      pinned: false,
      elevation: 0.5,
      backgroundColor: Colors.white,
      title: const Text(
        'StudyHub',
        style: TextStyle(
          color: Color(0xFF1877F2),
          fontWeight: FontWeight.bold,
          fontSize: 26,
          letterSpacing: -1,
        ),
      ),
      actions: [
        _buildNotificationAction(context),
        _buildUserMenu(context, authState),
      ],
    );
  }

  // --- 2. Danh sách bài viết (Sửa lỗi ép kiểu) ---
  Widget _buildPostList() {
    return BlocBuilder<PostBloc, PostState>(
      builder: (context, state) {
        if (state is PostLoading) {
          return const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }

        if (state is PostLoaded) {
          if (state.posts.isEmpty) {
            return _buildEmptyState();
          }

          // Đảm bảo kiểu dữ liệu truyền vào PostCard là PostEntity
          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final PostEntity post = state.posts[index];
                return PostCard(key: ValueKey(post.id), post: post);
              },
              childCount: state.posts.length,
            ),
          );
        }

        if (state is PostError) {
          return SliverFillRemaining(
            child: Center(
                child: Text(state.message,
                    style: const TextStyle(color: Colors.red))),
          );
        }

        return const SliverToBoxAdapter(child: SizedBox.shrink());
      },
    );
  }

  // --- 3. Thanh trạng thái tạo bài viết ---
  Widget _buildStatusHeader(BuildContext context, String userName) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border:
            Border(bottom: BorderSide(color: Color(0xFFE4E6EB), width: 0.5)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey[200],
            child: const Icon(Icons.person, color: Colors.grey),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () => _showCreatePostSheet(context, userName),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F2F5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "Bạn đang nghiên cứu gì thế, $userName?",
                  style: const TextStyle(color: Colors.black54, fontSize: 14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- 4. Logic UI phụ trợ ---
  Widget _buildEmptyState() {
    return const SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child:
            CircularProgressIndicator(), // Thay vì bẳng tin trống, hiện loading hoặc đơn giản là đợi admin post
      ),
    );
  }

  Widget _buildCreatingIndicator() {
    return BlocBuilder<PostBloc, PostState>(
      builder: (context, state) {
        if (state is PostLoaded && state.isCreating) {
          return const SliverToBoxAdapter(
            child:
                LinearProgressIndicator(minHeight: 2, color: Color(0xFF1877F2)),
          );
        }
        return const SliverToBoxAdapter(child: SizedBox.shrink());
      },
    );
  }

  Widget _buildUserMenu(BuildContext context, AuthState authState) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'profile' && authState is AuthSuccess) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => ProfileScreen(
                      userId: authState.user.id, isCurrentUser: true)));
        } else if (value == 'logout') {
          context.read<AuthBloc>().add(LogoutRequested());
        }
      },
      icon: const CircleAvatar(
        radius: 16,
        backgroundColor: Color(0xFF1877F2),
        child: Icon(Icons.person, color: Colors.white, size: 18),
      ),
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'profile', child: Text("Trang cá nhân")),
        const PopupMenuItem(
            value: 'logout',
            child: Text("Đăng xuất", style: TextStyle(color: Colors.red))),
      ],
    );
  }

  Widget _buildNotificationAction(BuildContext context) {
    return BlocBuilder<NotificationBloc, NotificationState>(
      builder: (context, state) {
        int count = 0;
        if (state is NotificationLoaded) {
          count = state.notifications.where((n) => !n.isRead).length;
        }
        return IconButton(
          icon: Badge(
            label: count > 0 ? Text('$count') : null,
            isLabelVisible: count > 0,
            child: const Icon(Icons.notifications_none_rounded,
                color: Colors.black87),
          ),
          onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const NotificationScreen())),
        );
      },
    );
  }

  void _showCreatePostSheet(BuildContext context, String uName) {
    final TextEditingController controller = TextEditingController();
    XFile? selectedImage;
    XFile? selectedVideo;
    final ImagePicker picker = ImagePicker();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Tạo bài viết",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: () {
                      if (controller.text.trim().isNotEmpty ||
                          selectedImage != null ||
                          selectedVideo != null) {
                        final authState = context.read<AuthBloc>().state;
                        if (authState is AuthSuccess) {
                          context.read<PostBloc>().add(CreatePostRequested(
                                content: controller.text.trim(),
                                userId: authState.user.id,
                                userName: authState.user.name,
                                imagePath: selectedImage?.path,
                                videoPath: selectedVideo?.path,
                                userAvatarUrl: authState.user.avatarUrl,
                              ));
                        }
                        Navigator.pop(context);
                      }
                    },
                    child: const Text("ĐĂNG",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1877F2))),
                  ),
                ],
              ),
              TextField(
                controller: controller,
                maxLines: 5,
                decoration: const InputDecoration(
                    hintText: "Bạn đang nghĩ gì?", border: InputBorder.none),
              ),
              if (selectedImage != null || selectedVideo != null)
                ListTile(
                  leading: const Icon(Icons.attach_file, color: Colors.blue),
                  title: const Text("File đã chọn",
                      style: TextStyle(fontSize: 12)),
                  trailing: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => setModalState(() {
                      selectedImage = null;
                      selectedVideo = null;
                    }),
                  ),
                ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.image, color: Colors.green),
                    onPressed: () async {
                      final XFile? file =
                          await picker.pickImage(source: ImageSource.gallery);
                      if (file != null) {
                        setModalState(() => selectedImage = file);
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.videocam, color: Colors.red),
                    onPressed: () async {
                      final XFile? file =
                          await picker.pickVideo(source: ImageSource.gallery);
                      if (file != null) {
                        setModalState(() => selectedVideo = file);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
