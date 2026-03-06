import 'package:appstudyhub/features/post/presentation/bloc/post_bloc.dart';
import 'package:appstudyhub/features/post/presentation/bloc/post_event.dart';
import 'package:appstudyhub/features/post/presentation/bloc/post_state.dart';
import 'package:appstudyhub/features/post/presentation/widgets/post_card.dart';
import 'package:image_picker/image_picker.dart';
import 'package:appstudyhub/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:appstudyhub/features/auth/presentation/bloc/auth_state.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../../domain/entities/profile_entity.dart';
import '../widgets/friend_list_widget.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;
  final bool isCurrentUser;

  const ProfileScreen({
    super.key,
    required this.userId,
    this.isCurrentUser = false,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Chỉ gọi fetch profile và bài viết ngay khi khởi tạo màn hình
    context.read<ProfileBloc>().add(FetchProfileEvent(widget.userId));
    context.read<PostBloc>().add(LoadPosts(userId: widget.userId));
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final String uName =
        (authState is AuthSuccess) ? authState.user.name : "Sinh viên";

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: const Text(
          "Trang cá nhân",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, profileState) {
          if (profileState is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (profileState is ProfileLoaded) {
            final profile = profileState.profile;

            return RefreshIndicator(
              onRefresh: () async {
                context
                    .read<ProfileBloc>()
                    .add(FetchProfileEvent(widget.userId));
                context.read<PostBloc>().add(LoadPosts(userId: widget.userId));
              },
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _buildHeader(context, profile)),
                  const SliverToBoxAdapter(child: SizedBox(height: 8)),
                  SliverToBoxAdapter(child: _buildInfoSection(profile)),
                  const SliverToBoxAdapter(child: SizedBox(height: 8)),
                  SliverToBoxAdapter(child: _buildFriendsSection(profile)),

                  // Chỉ hiện thanh đăng bài nếu là trang cá nhân của mình
                  if (widget.isCurrentUser) ...[
                    const SliverToBoxAdapter(child: SizedBox(height: 8)),
                    SliverToBoxAdapter(
                        child: _buildStatusHeader(context, uName)),
                  ],

                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text(
                        "Bài viết",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  _buildPostList(),

                  const SliverToBoxAdapter(child: SizedBox(height: 20)),
                ],
              ),
            );
          }

          if (profileState is ProfileError) {
            return Center(child: Text(profileState.message));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  // --- WIDGETS PHÂN TÁCH ---
  // ... (giữ nguyên các phương thức helper nhưng cập nhật tham chiếu widget.userId nếu cần)
  // Thực tế các phương thức helper bên dưới đa số dùng tham số truyền vào hoặc context.

  Widget _buildPostList() {
    return BlocBuilder<PostBloc, PostState>(
      builder: (context, state) {
        if (state is PostLoading) {
          return const SliverToBoxAdapter(
            child: Center(
                child: Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(strokeWidth: 2),
            )),
          );
        }

        if (state is PostLoaded) {
          if (state.posts.isEmpty) {
            return const SliverToBoxAdapter(
              child: Center(
                  child: Padding(
                padding: EdgeInsets.all(40.0),
                child: Text("Chưa có bài viết nào",
                    style: TextStyle(color: Colors.grey)),
              )),
            );
          }

          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final post = state.posts[index];
                return PostCard(key: ValueKey(post.id), post: post);
              },
              childCount: state.posts.length,
            ),
          );
        }

        return const SliverToBoxAdapter(child: SizedBox.shrink());
      },
    );
  }

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
                  "Bạn đang nghĩ gì, $userName?",
                  style: const TextStyle(color: Colors.black54, fontSize: 14),
                ),
              ),
            ),
          ),
        ],
      ),
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

  Widget _buildHeader(BuildContext context, ProfileEntity profile) {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  image: profile.coverUrl != null
                      ? DecorationImage(
                          image: NetworkImage(profile.coverUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
              ),
              Positioned(
                bottom: -50,
                left: 16,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: profile.avatarUrl != null
                        ? NetworkImage(profile.avatarUrl!)
                        : null,
                    child: profile.avatarUrl == null
                        ? const Icon(Icons.person,
                            size: 60, color: Colors.white)
                        : null,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 55),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.userName,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  profile.bio ?? "Chưa có tiểu sử",
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
                const SizedBox(height: 16),
                widget.isCurrentUser
                    ? _buildCurrentUserActions(context, profile)
                    : _buildOtherUserActions(context, profile),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(ProfileEntity profile) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _infoRow(Icons.email, "Email", profile.email),
          if (profile.birthDate != null)
            _infoRow(
              Icons.cake,
              "Ngày sinh",
              DateFormat('dd/MM/yyyy').format(profile.birthDate!),
            ),
          _infoRow(Icons.school, "Học tại", "Đại học Phú Yên (PYU)"),
        ],
      ),
    );
  }

  Widget _buildFriendsSection(ProfileEntity profile) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Bạn bè",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text("Xem tất cả", style: TextStyle(color: Colors.blue)),
            ],
          ),
          const SizedBox(height: 12),
          FriendListWidget(
            friends: profile.friends.cast<ProfileEntity>(),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          const SizedBox(width: 12),
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.w500)),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.black87)),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentUserActions(BuildContext context, ProfileEntity profile) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EditProfileScreen(profile: profile),
              ),
            ),
            icon: const Icon(Icons.edit, size: 18),
            label: const Text("Chỉnh sửa trang cá nhân"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[200],
              foregroundColor: Colors.black,
              elevation: 0,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.more_horiz),
        )
      ],
    );
  }

  Widget _buildOtherUserActions(BuildContext context, ProfileEntity profile) {
    return const SizedBox.shrink(); // Thêm logic kết bạn sau
  }
}
