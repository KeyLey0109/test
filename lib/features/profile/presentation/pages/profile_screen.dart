import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../../domain/entities/profile_entity.dart';
import '../widgets/friend_list_widget.dart';
import 'edit_profile_screen.dart';

// Import Post Layer for the feed
import '../../../post/presentation/bloc/post_bloc.dart';
import '../../../post/presentation/bloc/post_event.dart';
import '../../../post/presentation/bloc/post_state.dart';
import '../../../post/presentation/widgets/post_card.dart';

class ProfileScreen extends StatelessWidget {
  final String userId;
  final bool isCurrentUser;

  const ProfileScreen({
    super.key,
    required this.userId,
    this.isCurrentUser = false,
  });

  @override
  Widget build(BuildContext context) {
    // Gọi fetch profile ngay khi vào màn hình
    context.read<ProfileBloc>().add(FetchProfileEvent(userId));
    // Tải bảng tin riêng của user này
    context.read<PostBloc>().add(LoadPosts(userId: userId));

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
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProfileLoaded) {
            final profile = state.profile;

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- PHẦN 1: HEADER ---
                  _buildHeader(context, profile),
                  const SizedBox(height: 8),

                  // --- PHẦN 2: THÔNG TIN CHI TIẾT ---
                  _buildInfoSection(profile),
                  const SizedBox(height: 8),

                  // --- PHẦN 3: BẠN BÈ ---
                  _buildFriendsSection(profile),
                  const SizedBox(height: 16),

                  // --- PHẦN 4: BẢNG TIN RIÊNG (WALL) ---
                  _buildPostFeedSection(profile),
                  const SizedBox(height: 20),
                ],
              ),
            );
          }

          if (state is ProfileError) {
            return Center(child: Text(state.message));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  // --- WIDGETS PHÂN TÁCH ---

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
                isCurrentUser
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
          // Sửa lỗi vàng: Thêm const cho phần tiêu đề tĩnh
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
          // Sửa lỗi đỏ List<Object> & lỗi vàng Null check
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

  Widget _buildPostFeedSection(ProfileEntity profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "Bài viết của ${profile.userName}",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 12),
        BlocBuilder<PostBloc, PostState>(
          builder: (context, state) {
            if (state is PostLoading) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            if (state is PostLoaded) {
              if (state.posts.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text("Cá nhân này chưa có bài viết nào."),
                  ),
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.posts.length,
                itemBuilder: (context, index) {
                  return PostCard(post: state.posts[index]);
                },
              );
            }
            if (state is PostError) {
              return Center(child: Text(state.message));
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }
}
