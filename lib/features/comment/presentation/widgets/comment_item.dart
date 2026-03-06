import 'package:flutter/material.dart';
import '../../domain/entities/comment_entity.dart';
import 'package:intl/intl.dart';

class CommentItem extends StatelessWidget {
  final CommentEntity comment;
  final Function(CommentEntity) onReply;
  final bool isReply; // Xác định đây là bình luận gốc hay phản hồi

  const CommentItem({
    super.key,
    required this.comment,
    required this.onReply,
    this.isReply = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: isReply ? 48.0 : 12.0, // Thụt lề nếu là phản hồi
        right: 12.0,
        top: 8.0,
        bottom: 4.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar người bình luận
              CircleAvatar(
                radius: isReply ? 14 : 18,
                backgroundColor: Colors.grey[200],
                child: Text(
                  comment.userName.isNotEmpty ? comment.userName[0].toUpperCase() : '?',
                  style: TextStyle(
                    fontSize: isReply ? 12 : 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Nội dung bình luận (Bọc trong bong bóng chat)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            comment.userName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            comment.content,
                            style: const TextStyle(fontSize: 14, height: 1.3),
                          ),
                        ],
                      ),
                    ),

                    // Các nút chức năng dưới bình luận (Thích, Phản hồi, Thời gian)
                    Padding(
                      padding: const EdgeInsets.only(left: 8, top: 4),
                      child: Row(
                        children: [
                          Text(
                            _formatTimestamp(comment.timestamp),
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          ),
                          const SizedBox(width: 16),
                          GestureDetector(
                            onTap: () {}, // Logic Like comment
                            child: Text(
                              "Thích",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[700],
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          GestureDetector(
                            onTap: () => onReply(comment),
                            child: Text(
                              "Phản hồi",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[700],
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Hiển thị danh sách các phản hồi (Đệ quy)
          if (comment.replies.isNotEmpty)
            ...comment.replies.map((reply) => CommentItem(
              comment: reply,
              onReply: onReply,
              isReply: true, // Đánh dấu là phản hồi để thụt lề
            )),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) return "Vừa xong";
    if (difference.inMinutes < 60) return "${difference.inMinutes} phút";
    if (difference.inHours < 24) return "${difference.inHours} giờ";
    return DateFormat('dd/MM').format(date);
  }
}