import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../../domain/entities/profile_entity.dart';
import '../pages/edit_profile_screen.dart';

class FriendActionButtons extends StatelessWidget {
  final ProfileEntity profile;
  final bool isCurrentUser;

  const FriendActionButtons({
    super.key,
    required this.profile,
    required this.isCurrentUser,
  });

  @override
  Widget build(BuildContext context) {
    // 1. GIAO DIỆN CHO CHÍNH CHỦ (Cá nhân Việt)
    if (isCurrentUser) {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => EditProfileScreen(profile: profile)),
                );
              },
              icon: const Icon(Icons.edit, size: 18),
              label: const Text("Chỉnh sửa trang cá nhân",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[200], // Màu xám nhạt FB cho nút chỉnh sửa
                foregroundColor: Colors.black,
                elevation: 0,
                minimumSize: const Size(0, 40),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
          const SizedBox(width: 8),
          _buildMoreButton(),
        ],
      );
    }

    // 2. GIAO DIỆN CHO KHÁCH (Khi xem Profile người khác)
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              context.read<ProfileBloc>().add(ToggleFriendRequestEvent(profile.userId));
            },
            icon: Icon(
              profile.isFriend
                  ? Icons.person_remove
                  : (profile.isPending ? Icons.close : Icons.person_add),
              size: 18,
              color: profile.isFriend || profile.isPending ? Colors.black : Colors.white,
            ),
            label: Text(
              profile.isFriend
                  ? "Hủy kết bạn"
                  : (profile.isPending ? "Hủy yêu cầu" : "Thêm bạn bè"),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: profile.isFriend || profile.isPending ? Colors.black : Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: profile.isFriend || profile.isPending
                  ? Colors.grey[300]
                  : const Color(0xFF1877F2), // Màu xanh FB chuẩn
              elevation: 0,
              minimumSize: const Size(0, 40),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              // Logic nhắn tin
            },
            icon: const Icon(Icons.messenger, size: 18),
            label: const Text("Nhắn tin", style: TextStyle(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[200],
              foregroundColor: Colors.black,
              elevation: 0,
              minimumSize: const Size(0, 40),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
        const SizedBox(width: 8),
        _buildMoreButton(),
      ],
    );
  }

  // Nút phụ "..." chuẩn phong cách Material 3 / FB
  Widget _buildMoreButton() {
    return Container(
      height: 40,
      width: 45,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.more_horiz, color: Colors.black),
    );
  }
}