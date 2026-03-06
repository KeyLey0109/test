import 'package:equatable/equatable.dart';

abstract class CommentState extends Equatable {
  const CommentState();

  @override
  List<Object?> get props => [];
}

/// Trạng thái ban đầu
class CommentInitial extends CommentState {
  const CommentInitial(); // Thêm const ở đây
}

/// Trạng thái đang gửi dữ liệu lên server
class CommentLoading extends CommentState {
  const CommentLoading(); // Thêm const ở đây
}

/// Khi gửi thành công
class CommentSuccess extends CommentState {
  final String? message;

  const CommentSuccess({this.message});

  @override
  List<Object?> get props => [message];
}

/// Khi xảy ra lỗi
class CommentError extends CommentState {
  final String message;
  const CommentError(this.message);

  @override
  List<Object?> get props => [message];
}