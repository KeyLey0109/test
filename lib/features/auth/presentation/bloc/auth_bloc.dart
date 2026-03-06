import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;

  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
  }) : super(AuthInitial()) {

    // 1. Xử lý khởi động App: Fix lỗi màn hình đỏ khi vừa mở app
    on<AppStarted>((event, emit) async {
      emit(AuthLoading());
      // Việt có thể thêm logic kiểm tra Token lưu trong SharedPreferences ở đây
      await Future.delayed(const Duration(milliseconds: 500));
      emit(AuthInitial());
    });

    // 2. Xử lý Đăng nhập: Sử dụng Positional parameters
    on<LoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final result = await loginUseCase(event.email, event.password);

        result.fold(
              (failure) => emit(AuthFailure(failure)),
              (user) => emit(AuthSuccess(user)),
        );
      } catch (e) {
        emit(AuthFailure("Lỗi hệ thống: ${e.toString()}"));
      }
    });

    // 3. Xử lý Đăng ký: Sử dụng Named parameters khớp với RegisterUseCase
    on<RegisterRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final result = await registerUseCase(
          name: event.name,
          email: event.email,
          password: event.password,
        );

        result.fold(
              (failure) => emit(AuthFailure(failure)),
              (user) => emit(AuthSuccess(user)),
        );
      } catch (e) {
        emit(AuthFailure("Lỗi đăng ký: ${e.toString()}"));
      }
    });

    // 4. Xử lý Đăng xuất: Đưa trạng thái về Initial để quay lại màn hình Login
    on<LogoutRequested>((event, emit) {
      // Nếu Việt có dùng SharedPreferences, hãy xóa token ở đây trước khi emit
      emit(AuthInitial());
    });
  }
}