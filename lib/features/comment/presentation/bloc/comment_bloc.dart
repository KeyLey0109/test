import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/add_comment_usecase.dart';
import 'comment_event.dart';
import 'comment_state.dart';

class CommentBloc extends Bloc<CommentEvent, CommentState> {
  final AddCommentUseCase addCommentUseCase;

  CommentBloc({
    required this.addCommentUseCase,
  }) : super(const CommentInitial()) { // Thêm const ở trạng thái ban đầu

    on<SubmitComment>((event, emit) async {
      // 1. Chuyển sang trạng thái Loading (Dùng const vì constructor đã có const)
      emit(const CommentLoading());

      // 2. Gọi UseCase xử lý logic nghiệp vụ từ tầng Domain
      final result = await addCommentUseCase(
        postId: event.postId,
        content: event.content,
        userId: event.userId,
        userName: event.userName,
        parentCommentId: event.parentCommentId,
      );

      // 3. Xử lý kết quả trả về từ UseCase
      result.fold(
        // KHÔNG dùng const ở đây vì 'failure' là dữ liệu động
            (failure) => emit(CommentError(failure)),

            (_) {
          // Dùng const cho Success nếu không truyền message
          emit(const CommentSuccess());

          // Reset về Initial (Dùng const) để UI sẵn sàng cho lượt bình luận mới
          emit(const CommentInitial());
        },
      );
    });
  }
}