import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' as io;
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/post_entity.dart';
import '../../../comment/domain/entities/comment_entity.dart';
import '../bloc/post_bloc.dart';
import '../bloc/post_event.dart';
import '../bloc/post_state.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

import 'post_video_player.dart';
import '../../../comment/presentation/widgets/comment_sheet.dart';
import '../../../../features/profile/presentation/pages/profile_screen.dart';

class PostCard extends StatefulWidget {
  final PostEntity post;

  const PostCard({super.key, required this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool _isExpanded = false;

  // Tính tổng số bình luận bao gồm cả các phản hồi (đệ quy)
  int _getTotalCommentsCount(List<CommentEntity> comments) {
    int total = comments.length;
    for (var comment in comments) {
      if (comment.replies.isNotEmpty) {
        total += _getTotalCommentsCount(comment.replies);
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    if (authState is! AuthSuccess) return const SizedBox.shrink();

    final String currentUserId = authState.user.id;

    return BlocBuilder<PostBloc, PostState>(
      // Chỉ rebuild khi danh sách posts thay đổi hoặc đúng bài viết này được cập nhật
      builder: (context, state) {
        PostEntity displayPost = widget.post;

        if (state is PostLoaded) {
          // Lấy dữ liệu mới nhất của bài viết này từ State của Bloc
          displayPost = state.posts.cast<PostEntity>().firstWhere(
                (p) => p.id == widget.post.id,
                orElse: () => widget.post,
              );
        }

        // Sử dụng getter isLikedBy và likeCount từ PostEntity mới
        final bool isMyLike = displayPost.isLikedBy(currentUserId);
        final int totalComments = _getTotalCommentsCount(displayPost.comments);

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 0.5)
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: _PostHeader(
                  post: displayPost,
                  currentUserId: currentUserId,
                  currentUserAvatarUrl: authState.user.avatarUrl,
                ),
              ),

              if (displayPost.content.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                  child: _buildExpandableText(displayPost.content),
                ),

              _buildMediaSection(displayPost),

              // Thống kê tương tác
              if (displayPost.likeCount > 0 || totalComments > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (displayPost.likeCount > 0)
                        Row(
                          children: [
                            _buildLikeIconStack(),
                            const SizedBox(width: 6),
                            Text('${displayPost.likeCount}',
                                style: TextStyle(
                                    color: Colors.grey[700], fontSize: 13)),
                          ],
                        )
                      else
                        const SizedBox.shrink(),
                      GestureDetector(
                        onTap: () => _openCommentSheet(context, displayPost.id),
                        child: Text(
                          totalComments == 0 ? '' : '$totalComments bình luận',
                          style:
                              TextStyle(color: Colors.grey[700], fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),

              const Divider(
                  height: 1, thickness: 0.2, indent: 12, endIndent: 12),

              // Nút Like, Bình luận, Chia sẻ
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                child: Row(
                  children: [
                    _PostButton(
                      iconData: isMyLike
                          ? Icons.thumb_up_rounded
                          : Icons.thumb_up_off_alt_rounded,
                      label: 'Thích',
                      color:
                          isMyLike ? const Color(0xFF1877F2) : Colors.black87,
                      onTap: () {
                        // Gọi sự kiện ToggleLike với postId
                        context
                            .read<PostBloc>()
                            .add(ToggleLike(postId: displayPost.id));
                      },
                    ),
                    _PostButton(
                      iconData: Icons.chat_bubble_outline_rounded,
                      label: 'Bình luận',
                      onTap: () => _openCommentSheet(context, displayPost.id),
                    ),
                    _PostButton(
                      iconData: Icons.share_outlined,
                      label: 'Chia sẻ',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  "Tính năng chia sẻ sẽ sớm có mặt trên StudyHub!")),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildExpandableText(String text) {
    const int limit = 160;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          maxLines: _isExpanded ? null : 4,
          overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
          style:
              const TextStyle(fontSize: 15, height: 1.4, color: Colors.black),
        ),
        if (text.length > limit && !_isExpanded)
          GestureDetector(
            onTap: () => setState(() => _isExpanded = true),
            child: const Padding(
              padding: EdgeInsets.only(top: 4.0),
              child: Text("Xem thêm",
                  style: TextStyle(
                      color: Color(0xFF1877F2), fontWeight: FontWeight.bold)),
            ),
          ),
      ],
    );
  }

  Widget _buildMediaSection(PostEntity post) {
    // Sử dụng imagePath và videoPath từ Entity mới
    if (post.hasImage) {
      final path = post.imagePath!;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: kIsWeb || path.startsWith('http')
            ? Image.network(path, width: double.infinity, fit: BoxFit.cover)
            : Image.file(io.File(path),
                width: double.infinity, fit: BoxFit.cover),
      );
    }
    if (post.hasVideo) {
      return PostVideoPlayer(videoPath: post.videoPath!);
    }
    return const SizedBox.shrink();
  }

  Widget _buildLikeIconStack() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1877F2), Color(0xFF3B5998)],
          ),
          shape: BoxShape.circle),
      child: const Icon(Icons.thumb_up, color: Colors.white, size: 10),
    );
  }

  void _openCommentSheet(BuildContext context, String postId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommentSheet(postId: postId),
    );
  }
}

class _PostHeader extends StatelessWidget {
  final PostEntity post;
  final String currentUserId;
  final String? currentUserAvatarUrl;

  const _PostHeader({
    required this.post,
    required this.currentUserId,
    this.currentUserAvatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    // Nếu là bài viết của chính mình, ưu tiên dùng ảnh từ authState (để cập nhật realtime)
    final String? displayAvatarUrl = (post.userId == currentUserId)
        ? currentUserAvatarUrl
        : post.userAvatarUrl;

    return Row(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfileScreen(
                  userId: post.userId,
                  isCurrentUser: post.userId == currentUserId,
                ),
              ),
            );
          },
          child: CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFF1877F2).withValues(alpha: 0.1),
            backgroundImage:
                displayAvatarUrl != null && displayAvatarUrl.isNotEmpty
                    ? NetworkImage(displayAvatarUrl)
                    : null,
            child: displayAvatarUrl == null || displayAvatarUrl.isEmpty
                ? Text(
                    post.userName.isNotEmpty
                        ? post.userName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                        color: Color(0xFF1877F2), fontWeight: FontWeight.bold),
                  )
                : null,
          ),
        ),
        const SizedBox(width: 10.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileScreen(
                        userId: post.userId,
                        isCurrentUser: post.userId == currentUserId,
                      ),
                    ),
                  );
                },
                child: Text(post.userName,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14)),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Text(
                    '${post.timestamp.day}/${post.timestamp.month} lúc ${post.timestamp.hour}:${post.timestamp.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 11.0),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.public, color: Colors.grey[600], size: 12.0),
                ],
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.more_horiz, color: Colors.grey),
          onPressed: () {},
        ),
      ],
    );
  }
}

class _PostButton extends StatelessWidget {
  final IconData iconData;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _PostButton({
    required this.iconData,
    required this.label,
    required this.onTap,
    this.color = Colors.black87,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(4.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(iconData, color: color, size: 18),
                const SizedBox(width: 6.0),
                Text(label,
                    style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w600,
                        fontSize: 13)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
