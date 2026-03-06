import 'package:flutter/material.dart';
import '../../domain/entities/profile_entity.dart';

class FriendListWidget extends StatelessWidget {
  final List<ProfileEntity> friends;

  const FriendListWidget({super.key, required this.friends});

  @override
  Widget build(BuildContext context) {
    // Nếu chưa có bạn bè, hiển thị dòng thông báo nhẹ
    if (friends.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        alignment: Alignment.center,
        child: Text(
          "Chưa có bạn bè nào để hiển thị",
          style: TextStyle(color: Colors.grey[500], fontStyle: FontStyle.italic),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true, // Quan trọng: Để GridView nằm gọn trong SingleChildScrollView
      physics: const NeverScrollableScrollPhysics(), // Không cho GridView tự cuộn riêng
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // Hiển thị 3 bạn bè trên một hàng
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.8, // Điều chỉnh tỉ lệ để tên không bị mất
      ),
      itemCount: friends.length > 6 ? 6 : friends.length, // Chỉ hiện tối đa 6 người ở trang chính
      itemBuilder: (context, index) {
        final friend = friends[index];
        return Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: friend.avatarUrl != null
                    ? Image.network(friend.avatarUrl!, fit: BoxFit.cover)
                    : Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.person, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              friend.userName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        );
      },
    );
  }
}