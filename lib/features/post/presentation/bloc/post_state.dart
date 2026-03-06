import 'package:equatable/equatable.dart';
import 'package:appstudyhub/features/post/domain/entities/post_entity.dart';

abstract class PostState extends Equatable {
  const PostState();

  @override
  List<Object?> get props => [];
}

/// 1. Trạng thái khởi tạo
class PostInitial extends PostState {}

/// 2. Trạng thái đang tải dữ liệu (lần đầu hoặc làm mới toàn bộ)
class PostLoading extends PostState {}

/// 3. Trạng thái quan trọng nhất: Đã tải dữ liệu
/// Quản lý danh sách bài viết và các trạng thái phụ như đang đăng bài.
class PostLoaded extends PostState {
  final List<PostEntity> posts;
  final bool isCreating; // Để hiển thị LinearProgressIndicator khi đang upload

  const PostLoaded({
    this.posts = const [],
    this.isCreating = false,
  });

  /// Phương thức copyWith giúp cập nhật từng phần của State mà không mất dữ liệu cũ
  PostLoaded copyWith({
    List<PostEntity>? posts,
    bool? isCreating,
  }) {
    return PostLoaded(
      posts: posts ?? this.posts,
      isCreating: isCreating ?? this.isCreating,
    );
  }

  @override
  List<Object?> get props => [posts, isCreating];
}

/// 4. Trạng thái xảy ra lỗi
class PostError extends PostState {
  final String message;

  const PostError({required this.message});

  @override
  List<Object?> get props => [message];
}