import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'post_event.dart';
import 'post_state.dart';

// Domain Layer
import '../../domain/entities/post_entity.dart';
import '../../domain/usecases/get_post_usecase.dart';
import '../../domain/usecases/create_post_usecase.dart';
import '../../domain/usecases/toggle_like_usecase.dart';
import '../../../comment/domain/entities/comment_entity.dart';
import '../../../comment/domain/usecases/add_comment_usecase.dart';
import '../../../notifications/domain/entities/notification_entity.dart';

// Data Layer
import '../../data/models/post_model.dart';
import '../../data/datasources/post_local_data_source.dart';
import '../../../comment/data/models/comment_model.dart';

// Auth Layer
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart' as auth;

// Notifications Layer
import '../../../notifications/presentation/bloc/notification_bloc.dart';
import '../../../notifications/presentation/bloc/notification_event.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final GetPostsUseCase getPostsUseCase;
  final CreatePostUseCase createPostUseCase;
  final ToggleLikeUseCase toggleLikeUseCase;
  final AddCommentUseCase addCommentUseCase;
  final PostLocalDataSource localDataSource;
  final AuthBloc authBloc;
  final NotificationBloc notificationBloc;

  String?
      _currentUserId; // Lưu trữ userId hiện tại để reload đúng Wall sau khi đăng bài

  PostBloc({
    required this.getPostsUseCase,
    required this.createPostUseCase,
    required this.toggleLikeUseCase,
    required this.addCommentUseCase,
    required this.localDataSource,
    required this.authBloc,
    required this.notificationBloc,
  }) : super(PostInitial()) {
    on<LoadPosts>(_onLoadPosts);
    on<CreatePostRequested>(_onCreatePost);
    on<ToggleLike>(_onToggleLike);
    on<AddComment>(_onAddComment);
    on<DeletePost>(_onDeletePost);
    on<UpdatePost>(_onUpdatePost);
  }

  /// Helper để lấy thông tin người dùng hiện tại từ AuthBloc
  auth.AuthSuccess? get _currentAuth {
    final authState = authBloc.state;
    return authState is auth.AuthSuccess ? authState : null;
  }

  /// 1. Xử lý Load bài viết
  Future<void> _onLoadPosts(LoadPosts event, Emitter<PostState> emit) async {
    final authUser = _currentAuth?.user;

    // Nếu chuyển sang xem Feed chung (userId == null) hoặc Xem tường của chính mình,
    // ta cần kiểm tra xem có phải là đổi Account không.
    if (_currentUserId != authUser?.id && authUser != null) {
      debugPrint(
          "🔄 Phát hiện đổi tài khoản. Đang làm mới cache cho User: ${authUser.id}");
      getPostsUseCase.repository.clearCache();
    }

    _currentUserId = authUser?.id;
    emit(PostLoading());

    // Nếu event.userId là null (Home Feed), load từ phân vùng Global
    // Nếu event.userId != null (Wall), load từ phân vùng của User đó
    final localPosts = await localDataSource.getLastPosts(userId: event.userId);
    if (localPosts.isNotEmpty) {
      emit(PostLoaded(posts: List<PostEntity>.from(localPosts)));
    }

    final result = await getPostsUseCase(userId: event.userId);
    result.fold(
      (failure) {
        if (localPosts.isEmpty) emit(PostError(message: failure.toString()));
      },
      (posts) {
        emit(PostLoaded(posts: posts));
        // CHỈ cache khi đây là lần tải toàn bộ (event.userId == null)
        // và lưu vào phân vùng của người đang đăng nhập
        if (event.userId == null) {
          final models = posts.map((e) => PostModel.fromEntity(e)).toList();
          localDataSource.cachePosts(models, userId: authUser?.id);
        }
      },
    );
  }

  /// 2. Xử lý tạo bài viết mới
  Future<void> _onCreatePost(
      CreatePostRequested event, Emitter<PostState> emit) async {
    final user = _currentAuth?.user;
    if (user == null) return;

    // Hiển thị trạng thái đang tạo trên UI
    if (state is PostLoaded) {
      emit((state as PostLoaded).copyWith(isCreating: true));
    }

    final result = await createPostUseCase(
      content: event.content,
      userId: user.id,
      imagePath: event.imagePath,
      videoPath: event.videoPath,
      userName: user.name,
      userAvatarUrl: user.avatarUrl,
    );

    result.fold(
      (failure) {
        if (state is PostLoaded) {
          emit((state as PostLoaded).copyWith(isCreating: false));
        }
        emit(PostError(message: failure.toString()));
      },
      (_) {
        add(LoadPosts(
            userId:
                _currentUserId)); // Tải lại danh sách sau khi tạo thành công

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

  /// 3. Xử lý Like/Unlike bài viết (Optimistic UI)
  Future<void> _onToggleLike(ToggleLike event, Emitter<PostState> emit) async {
    final currentState = state;
    final user = _currentAuth?.user;

    if (currentState is PostLoaded && user != null) {
      final String userId = user.id;

      final List<PostEntity> updatedPosts = currentState.posts.map((post) {
        if (post.id == event.postId) {
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

      // Gọi UseCase để xử lý đồng bộ tầng Repository và Local Cache
      await toggleLikeUseCase(event.postId, userId);
    }
  }

  /// 4. Xử lý thêm bình luận mới (Optimistic UI)
  Future<void> _onAddComment(AddComment event, Emitter<PostState> emit) async {
    final currentState = state;
    final user = _currentAuth?.user;

    if (currentState is PostLoaded && user != null) {
      final List<PostEntity> updatedPosts = currentState.posts.map((post) {
        if (post.id == event.postId) {
          final newComment = CommentModel(
            id: "cmt_${DateTime.now().millisecondsSinceEpoch}",
            userId: user.id,
            userName: user.name,
            content: event.commentContent,
            timestamp: DateTime.now(),
            replies: const [],
          );

          final List<CommentEntity> updatedComments =
              List<CommentEntity>.from(post.comments)..add(newComment);

          return post.copyWith(comments: updatedComments);
        }
        return post;
      }).toList();

      emit(currentState.copyWith(posts: updatedPosts));

      // Gọi UseCase để Repository cập nhật Cache của chính nó và disk cache
      await addCommentUseCase(
        postId: event.postId,
        content: event.commentContent,
        userId: user.id,
        userName: user.name,
      );
    }
  }

  /// 5. Cập nhật một bài viết cụ thể
  void _onUpdatePost(UpdatePost event, Emitter<PostState> emit) {
    if (state is PostLoaded) {
      final currentState = state as PostLoaded;
      final List<PostEntity> updatedPosts = currentState.posts.map((post) {
        return post.id == event.post.id ? event.post : post;
      }).toList();
      emit(currentState.copyWith(posts: updatedPosts));
    }
  }

  /// 6. Xử lý xóa bài viết
  Future<void> _onDeletePost(DeletePost event, Emitter<PostState> emit) async {
    if (state is PostLoaded) {
      final currentState = state as PostLoaded;
      final updatedPosts =
          currentState.posts.where((post) => post.id != event.postId).toList();

      emit(currentState.copyWith(posts: updatedPosts));

      final modelsToCache =
          updatedPosts.map((e) => PostModel.fromEntity(e)).toList();
      await localDataSource.cachePosts(modelsToCache);
    }
  }
}
