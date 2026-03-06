import 'package:flutter/material.dart';

void showPostOptions(BuildContext context) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (context) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
          _buildOption(Icons.bookmark_border, "Lưu bài viết", "Thêm vào danh sách mục lưu trữ của bạn"),
          _buildOption(Icons.notifications_none, "Bật thông báo cho bài viết này", ""),
          _buildOption(Icons.link, "Sao chép liên kết", ""),
          _buildOption(Icons.report_gmailerrorred, "Báo cáo bài viết", "Chúng tôi sẽ xem xét báo cáo này"),
          const SizedBox(height: 16),
        ],
      );
    },
  );
}

Widget _buildOption(IconData icon, String title, String sub) {
  return ListTile(
    leading: Icon(icon, color: Colors.black87),
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
    subtitle: sub.isNotEmpty ? Text(sub, style: const TextStyle(fontSize: 12)) : null,
    onTap: () {},
  );
}