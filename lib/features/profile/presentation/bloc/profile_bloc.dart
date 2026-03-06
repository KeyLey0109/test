import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfileUseCase getProfileUseCase;
  final UpdateProfileUseCase updateProfileUseCase;
  final AuthBloc authBloc;

  ProfileBloc({
    required this.getProfileUseCase,
    required this.updateProfileUseCase,
    required this.authBloc,
  }) : super(ProfileInitial()) {
    // 1. Tải thông tin Profile (Hết lỗi đỏ khi chuyển trang)
    on<FetchProfileEvent>((event, emit) async {
      emit(ProfileLoading());
      final result = await getProfileUseCase(event.targetUserId);

      result.fold(
        (failure) => emit(ProfileError(failure.toString())),
        (profile) => emit(ProfileLoaded(profile)),
      );
    });

    // 2. Cập nhật thông tin chi tiết
    on<UpdateProfileDetailEvent>((event, emit) async {
      final currentState = state;
      final authState = authBloc.state;

      if (currentState is ProfileLoaded && authState is AuthSuccess) {
        emit(ProfileLoading());

        final result = await updateProfileUseCase(
          userId: authState.user.id,
          name: event.name,
          birthDate: event.birthDate,
          bio: event.bio,
          avatarPath: event.avatarPath,
        );

        result.fold(
          (failure) => emit(ProfileError(failure.toString())),
          (_) {
            // Phát ra state thành công để UI biết đường pop/chuyển trang
            emit(ProfileUpdateSuccess());

            // Sau khi update thành công, tự reload bằng ID của trạng thái auth
            add(FetchProfileEvent(authState.user.id));
          },
        );
      }
    });

    // 3. Xử lý Kết bạn (Facebook Style)
    on<ToggleFriendRequestEvent>((event, emit) async {
      final currentState = state;
      if (currentState is ProfileLoaded) {
        // Cập nhật giao diện ngay lập tức (Optimistic UI)
        final updatedProfile = currentState.profile.copyWith(
          isPending: !currentState.profile.isPending,
        );
        emit(ProfileLoaded(updatedProfile));

        // Lưu ý cho Việt: Bạn nên gọi UseCase xử lý kết bạn thực tế ở đây
        // Tạm thời gọi Fetch để đồng bộ lại dữ liệu từ Server/Local
        add(FetchProfileEvent(event.targetUserId));
      }
    });
  }
}
