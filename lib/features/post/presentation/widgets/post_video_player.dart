import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class PostVideoPlayer extends StatefulWidget {
  final String videoPath;

  // Sửa lỗi: Đảm bảo constructor có thể dùng const nếu cần,
  // nhưng lưu ý khi truyền File vào initState thì nó là biến động.
  const PostVideoPlayer({super.key, required this.videoPath});

  @override
  State<PostVideoPlayer> createState() => _PostVideoPlayerState();
}

class _PostVideoPlayerState extends State<PostVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    // Khởi tạo controller từ đường dẫn file trên máy sinh viên PYU hoặc URL mạng
    if (widget.videoPath.startsWith('http')) {
      _controller =
          VideoPlayerController.networkUrl(Uri.parse(widget.videoPath));
    } else {
      _controller = VideoPlayerController.file(File(widget.videoPath));
    }

    _controller.initialize().then((_) {
      // Đảm bảo widget vẫn còn tồn tại trong tree trước khi setState
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    }).catchError((error) {
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    });

    // Tùy chọn: Tự động lặp lại video
    _controller.setLooping(true);
  }

  @override
  void dispose() {
    // Giải phóng bộ nhớ là bắt buộc để App không bị lag
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Container(
        height: 250,
        decoration: const BoxDecoration(color: Colors.black),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.white54, size: 40),
              SizedBox(height: 8),
              Text("Không thể tải video",
                  style: TextStyle(color: Colors.white54)),
            ],
          ),
        ),
      );
    }

    if (!_isInitialized) {
      return Container(
        height: 250,
        decoration: const BoxDecoration(color: Colors.black),
        child: const Center(
          // Thêm const cho các widget tĩnh để sửa lỗi gạch đỏ
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _controller.value.isPlaying
              ? _controller.pause()
              : _controller.play();
        });
      },
      child: Container(
        color: Colors.black,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            ),
            // Hiển thị nút Play/Pause dựa trên trạng thái thực tế
            AnimatedOpacity(
              opacity: _controller.value.isPlaying ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 300),
              child: const Icon(
                Icons.play_circle_fill,
                color: Colors.white70,
                size: 64,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
