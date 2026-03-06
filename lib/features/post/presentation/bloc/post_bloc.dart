import 'package:flutter_bloc/flutter_bloc.dart';
import 'post_event.dart';
import 'post_state.dart';

// Import Entities và UseCases từ tầng Domain
import '../../domain/entities/post_entity.dart';
import '../../domain/usecases/get_post_usecase.dart';
import '../../domain/usecases/create_post_usecase.dart';

// Import các dependencies từ các features khác
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../comment/domain/entities/comment_entity.dart';
import '../../../notifications/presentation/bloc/notification_bloc.dart';
import '../../../notifications/presentation/bloc/notification_event.dart';
import '../../../notifications/domain/entities/notification_entity.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final GetPostsUseCase getPostsUseCase;
  final CreatePostUseCase createPostUseCase;
  final AuthBloc authBloc;
  final NotificationBloc notificationBloc;

  PostBloc({
    required this.getPostsUseCase,
    required this.createPostUseCase,
    required this.authBloc,
    required this.notificationBloc,
  }) : super(PostInitial()) {
    // Đăng ký các sự kiện
    on<LoadPosts>(_onLoadPosts);
    on<CreatePostRequested>(_onCreatePost);
    on<ToggleLike>(_onToggleLike);
    on<AddComment>(_onAddComment);
    on<UpdatePost>(_onUpdatePost);
    on<DeletePost>(_onDeletePost);
  }

  /// Helper để lấy thông tin người dùng hiện tại từ AuthBloc
  AuthSuccess? get _currentAuth {
    final authState = authBloc.state;
    return authState is AuthSuccess ? authState : null;
  }

  /// Xử lý tải danh sách bài viết
  Future<void> _onLoadPosts(LoadPosts event, Emitter<PostState> emit) async {
    emit(PostLoading());
    final result = await getPostsUseCase();

    result.fold(
      (failure) => emit(PostError(message: failure.toString())),
      (posts) => emit(PostLoaded(posts: posts)),
    );
  }

  /// Xử lý tạo bài viết mới
  Future<void> _onCreatePost(
      CreatePostRequested event, Emitter<PostState> emit) async {
    final user = _currentAuth?.user;
    if (user == null) return;

    // Hiển thị trạng thái đang tạo trên UI (nếu đang ở màn hình danh sách)
    if (state is PostLoaded) {
      emit((state as PostLoaded).copyWith(isCreating: true));
    }

    final result = await createPostUseCase(
      content: event.content,
      image: event.image,
      video: event.video,
      userName: user.name,
    );

    result.fold(
      (failure) {
        if (state is PostLoaded) {
          emit((state as PostLoaded).copyWith(isCreating: false));
        }
        emit(PostError(message: failure.toString()));
      },
      (_) {
        add(const LoadPosts()); // Tải lại danh sách sau khi tạo thành công

        // Bắn thông báo ngay lập tức
        notificationBloc.add(NotificationReceived(NotificationEntity(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          senderId: 'system',
          senderName: 'Hệ thống',
          message: 'Bạn vừa đăng một bài viết mới.',
          type: NotificationType.postMention,
          timestamp: DateTime.now(),
        )));
      },
    );
  }

  /// Xử lý Like/Unlike bài viết (Cập nhật tức thì trên UI)
  Future<void> _onToggleLike(ToggleLike event, Emitter<PostState> emit) async {
    final currentState = state;
    final user = _currentAuth?.user;

    if (currentState is PostLoaded && user != null) {
      final String userId = user.id;

      final List<PostEntity> updatedPosts = currentState.posts.map((post) {
        if (post.id == event.postId) {
          // Tạo bản sao mới của danh sách likes để kích hoạt Equatable
          final List<String> newLikedByUsers =
              List<String>.from(post.likedByUsers);

          if (newLikedByUsers.contains(userId)) {
            newLikedByUsers.remove(userId);
          } else {
            newLikedByUsers.add(userId);
          }

          return post.copyWith(likedByUsers: newLikedByUsers);
        }
        return post;
      }).toList();

      emit(currentState.copyWith(posts: updatedPosts));

      // Chỗ này Việt có thể gọi thêm UseCase để lưu trạng thái Like vào Database/Local
    }
  }

  /// Xử lý thêm bình luận mới
  Future<void> _onAddComment(AddComment event, Emitter<PostState> emit) async {
    final currentState = state;
    final user = _currentAuth?.user;

    if (currentState is PostLoaded && user != null) {
      final List<PostEntity> updatedPosts = currentState.posts.map((post) {
        if (post.id == event.postId) {
          final newComment = CommentEntity(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            userId: user.id,
            userName: user.name,
            content: event.commentContent,
            timestamp: DateTime.now(),
            replies: const [],
          );

          // Cập nhật danh sách bình luận bằng cách tạo List mới
          final List<CommentEntity> updatedComments =
              List<CommentEntity>.from(post.comments)..add(newComment);

          return post.copyWith(comments: updatedComments);
        }
        return post;
      }).toList();

      emit(currentState.copyWith(posts: updatedPosts));
    }
  }

  /// Cập nhật một bài viết cụ thể
  void _onUpdatePost(UpdatePost event, Emitter<PostState> emit) {
    if (state is PostLoaded) {
      final currentState = state as PostLoaded;
      final List<PostEntity> updatedPosts = currentState.posts.map((post) {
        return post.id == event.post.id ? event.post : post;
      }).toList();
      emit(currentState.copyWith(posts: updatedPosts));
    }
  }

  /// Xóa bài viết khỏi danh sách hiển thị
  void _onDeletePost(DeletePost event, Emitter<PostState> emit) {
    if (state is PostLoaded) {
      final currentState = state as PostLoaded;
      final List<PostEntity> updatedPosts =
          currentState.posts.where((post) => post.id != event.postId).toList();
      emit(currentState.copyWith(posts: updatedPosts));
    }
  }
}
