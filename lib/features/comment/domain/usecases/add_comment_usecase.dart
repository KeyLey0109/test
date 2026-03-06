import 'package:dartz/dartz.dart'; // Phải có để dùng Either
import '../repositories/comment_repository.dart';

class AddCommentUseCase {
  final CommentRepository repository;

  AddCommentUseCase(this.repository);

  // Hàm call giúp UseCase có thể gọi như một function: useCase(...)
  Future<Either<String, void>> call({
    required String postId,
    required String content,
    required String userId,
    required String userName,
    String? parentCommentId,
  }) {
    return repository.addComment(
      postId: postId,
      content: content,
      userId: userId,
      userName: userName,
      parentCommentId: parentCommentId,
    );
  }
}