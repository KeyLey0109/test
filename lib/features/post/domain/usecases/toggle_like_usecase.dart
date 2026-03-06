import 'package:dartz/dartz.dart';
import '../repositories/post_repository.dart';

class ToggleLikeUseCase {
  final PostRepository repository;

  ToggleLikeUseCase(this.repository);

  Future<Either<String, void>> call(String postId, String userId) async {
    return await repository.toggleLike(postId, userId);
  }
}
