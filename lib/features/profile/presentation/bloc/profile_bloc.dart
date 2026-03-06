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
    // 1. Xử lý tải thông tin Profile
    on<FetchProfileEvent>((event, emit) async {
      emit(ProfileLoading());
      final result = await getProfileUseCase(event.targetUserId);

      result.fold(
        (failure) => emit(ProfileError(failure)),
        (profile) => emit(ProfileLoaded(profile)),
      );
    });

    // 2. Xử lý cập nhật thông tin (Tên, Ngày sinh, Bio, Ảnh)
    on<UpdateProfileDetailEvent>((event, emit) async {
      emit(ProfileLoading());
      final authState = authBloc.state;
      if (authState is AuthSuccess) {
        final result = await updateProfileUseCase(
          userId: authState.user.id,
          name: event.name,
          birthDate: event.birthDate,
          bio: event.bio,
          avatarPath: event.avatarPath,
        );

        result.fold(
          (failure) => emit(ProfileError(failure)),
          (_) {
            // Sau khi update thành công, tự động tải lại dữ liệu mới nhất
            add(FetchProfileEvent(authState.user.id));
          },
        );
      } else {
        emit(const ProfileError("Bạn cần đăng nhập để thực hiện thao tác này"));
      }
    });

    // 3. Xử lý Kết bạn / Hủy kết bạn (Phong cách Facebook)
    on<ToggleFriendRequestEvent>((event, emit) async {
      final currentState = state;
      if (currentState is ProfileLoaded) {
        // Tối ưu UI: Chuyển trạng thái nút bấm ngay lập tức (Optimistic UI)
        final updatedProfile = currentState.profile.copyWith(
          isPending: !currentState.profile.isPending,
        );
        emit(ProfileLoaded(updatedProfile));

        // Gọi Repository thực tế (thông qua UseCase nếu Việt đã tạo ManageFriendshipUseCase)
        // Ở đây mình tạm thời gọi reload để cập nhật từ Server
        add(FetchProfileEvent(event.targetUserId));
      }
    });
  }
}
