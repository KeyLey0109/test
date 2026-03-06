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

// Data Layer
import '../../data/models/post_model.dart';
import '../../data/datasources/post_local_data_source.dart';
import '../../../comment/data/models/comment_model.dart';

// Auth Layer
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final GetPostsUseCase getPostsUseCase;
  final CreatePostUseCase createPostUseCase;
  final ToggleLikeUseCase toggleLikeUseCase;
  final AddCommentUseCase addCommentUseCase;
  final PostLocalDataSource localDataSource;
  final AuthBloc authBloc;
  String?
      _currentUserId; // Lưu trữ userId hiện tại để reload đúng Wall sau khi đăng bài

  PostBloc({
    required this.getPostsUseCase,
    required this.createPostUseCase,
    required this.toggleLikeUseCase,
    required this.addCommentUseCase,
    required this.localDataSource,
    required this.authBloc,
  }) : super(PostInitial()) {
    on<LoadPosts>(_onLoadPosts);
    on<CreatePostRequested>(_onCreatePost);
    on<ToggleLike>(_onToggleLike);
    on<AddComment>(_onAddComment);
    on<DeletePost>(_onDeletePost);
  }

  AuthSuccess? get _currentAuth {
    final authState = authBloc.state;
    return authState is AuthSuccess ? authState : null;
  }

  /// 1. Xử lý Load bài viết (Dứt điểm lỗi dòng 60)
  Future<void> _onLoadPosts(LoadPosts event, Emitter<PostState> emit) async {
    _currentUserId = event.userId;
    emit(PostLoading());

    final localPosts = await localDataSource.getLastPosts();
    if (localPosts.isNotEmpty) {
      emit(PostLoaded(posts: localPosts));
    }

    final result = await getPostsUseCase(userId: event.userId);
    result.fold(
      (failure) {
        if (localPosts.isEmpty) emit(PostError(message: failure.toString()));
      },
      (posts) {
        emit(PostLoaded(posts: posts));
        // CHỈ cache khi đây là lần tải toàn bộ (userId == null)
        // Nếu tải theo userId (Trang cá nhân), việc cache sẽ làm mất các bài viết khác!
        if (event.userId == null) {
          final models = posts.map((e) => PostModel.fromEntity(e)).toList();
          localDataSource.cachePosts(models);
        }
      },
    );
  }

  /// 2. Xử lý Like (Dứt điểm lỗi dòng 93)
  Future<void> _onToggleLike(ToggleLike event, Emitter<PostState> emit) async {
    final currentState = state;
    final user = _currentAuth?.user;

    if (currentState is PostLoaded && user != null) {
      final String userId = user.id;

      final List<PostEntity> updatedPosts = currentState.posts.map((post) {
        if (post.id == event.postId) {
          final List<String> newLikes = List<String>.from(post.likedByUsers);
          newLikes.contains(userId)
              ? newLikes.remove(userId)
              : newLikes.add(userId);
          return post.copyWith(likedByUsers: newLikes);
        }
        return post;
      }).toList();

      emit(currentState.copyWith(posts: updatedPosts));

      // Gọi UseCase để xử lý đồng bộ tầng Repository và Local Cache
      await toggleLikeUseCase(event.postId, userId);
    }
  }

  /// 3. Xử lý Comment (Sửa lỗi mất Like bằng cách gọi UseCase chính thống)
  Future<void> _onAddComment(AddComment event, Emitter<PostState> emit) async {
    final currentState = state;
    final user = _currentAuth?.user;

    if (currentState is PostLoaded && user != null) {
      // 1. Cập nhật UI ngay lập tức (Optimistic UI)
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

      // 2. Gọi UseCase để Repository cập nhật Cache của chính nó và disk cache
      await addCommentUseCase(
        postId: event.postId,
        content: event.commentContent,
        userId: user.id,
        userName: user.name,
      );
    }
  }

  /// 4. Tạo bài viết
  Future<void> _onCreatePost(
      CreatePostRequested event, Emitter<PostState> emit) async {
    final user = _currentAuth?.user;
    if (user == null) return;

    final result = await createPostUseCase(
      content: event.content,
      userId: event.userId,
      imagePath: event.imagePath,
      videoPath: event.videoPath,
      userName: event.userName,
      userAvatarUrl: event.userAvatarUrl,
    );

    result.fold(
      (failure) => emit(PostError(message: failure.toString())),
      (_) => add(LoadPosts(userId: _currentUserId)), // Reload đúng filter cũ
    );
  }

  /// 5. Xóa bài viết (Dứt điểm lỗi dòng 158)
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
