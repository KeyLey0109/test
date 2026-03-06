import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// --- Domain ---
import '../../domain/entities/post_entity.dart';

// --- BLoC & Events ---
import '../bloc/post_bloc.dart';
import '../bloc/post_state.dart';
import '../widgets/post_card.dart';

class VideoPage extends StatelessWidget {
  const VideoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: const Text(
          "Video",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: BlocBuilder<PostBloc, PostState>(
        builder: (context, state) {
          if (state is PostLoading) {
            return const Center(
                child: CircularProgressIndicator(strokeWidth: 2));
          }

          if (state is PostLoaded) {
            // Lọc ra danh sách chỉ chứa các bài post có video (không màng có ảnh hay không)
            final List<PostEntity> videoPosts =
                state.posts.where((post) => post.hasVideo).toList();

            if (videoPosts.isEmpty) {
              return _buildEmptyState();
            }

            return ListView.builder(
              itemCount: videoPosts.length,
              itemBuilder: (context, index) {
                return PostCard(
                  key: ValueKey(videoPosts[index].id),
                  post: videoPosts[index],
                );
              },
            );
          }

          if (state is PostError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.video_library_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            "Chưa có video nào",
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
