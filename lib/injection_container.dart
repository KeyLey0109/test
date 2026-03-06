import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- IMPORT AUTH ---
import 'features/auth/data/datasources/fake_auth_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/register_usecase.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

// --- IMPORT POST ---
import 'features/post/data/datasources/post_local_data_source.dart';
import 'features/post/data/repositories/post_repository_impl.dart';
import 'features/post/domain/repositories/post_repository.dart';
import 'features/post/domain/usecases/get_post_usecase.dart';
import 'features/post/domain/usecases/create_post_usecase.dart';
import 'features/post/domain/usecases/toggle_like_usecase.dart';
import 'features/post/presentation/bloc/post_bloc.dart';

import 'features/comment/domain/repositories/comment_repository.dart';
import 'features/comment/domain/usecases/add_comment_usecase.dart';
import 'features/comment/presentation/bloc/comment_bloc.dart';

// --- IMPORT PROFILE ---
import 'features/profile/data/datasources/profile_remote_data_source.dart';
import 'features/profile/data/repositories/profile_repository_impl.dart';
import 'features/profile/domain/repositories/profile_repository.dart';
import 'features/profile/domain/usecases/get_profile_usecase.dart';
import 'features/profile/domain/usecases/update_profile_usecase.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';

// --- IMPORT NOTIFICATIONS ---
import 'features/notifications/presentation/bloc/notification_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! 1. EXTERNAL (Khởi tạo trước để các lớp khác sử dụng)
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  //! 2. FEATURES - AUTH
  sl.registerFactory(() => AuthBloc(loginUseCase: sl(), registerUseCase: sl()));
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(fakeDataSource: sl()));
  sl.registerLazySingleton(() => FakeAuthDataSource());

  //! 3. FEATURES - POST
  // CẬP NHẬT: Đăng ký PostBloc nhận thêm localDataSource để dứt điểm lỗi lưu cache
  sl.registerFactoryParam<PostBloc, AuthBloc, void>(
    (authBloc, _) => PostBloc(
      getPostsUseCase: sl(),
      createPostUseCase: sl(),
      toggleLikeUseCase: sl(),
      addCommentUseCase: sl(),
      localDataSource: sl(),
      authBloc: authBloc,
    ),
  );

  sl.registerLazySingleton(() => GetPostsUseCase(sl()));
  sl.registerLazySingleton(() => CreatePostUseCase(sl()));
  sl.registerLazySingleton(() => ToggleLikeUseCase(sl()));

  // Ràng buộc Repository và DataSource cho Post
  sl.registerLazySingleton<PostRepository>(
      () => PostRepositoryImpl(localDataSource: sl()));
  sl.registerLazySingleton<PostLocalDataSource>(
      () => PostLocalDataSourceImpl(sharedPreferences: sl()));

  //! 4. FEATURES - COMMENT
  sl.registerFactory(() => CommentBloc(addCommentUseCase: sl()));
  sl.registerLazySingleton(() => AddCommentUseCase(sl()));

  // Dùng chung PostRepository cho Comment để đồng bộ Cache
  sl.registerLazySingleton<CommentRepository>(
      () => sl<PostRepository>() as CommentRepository);

  //! 5. FEATURES - PROFILE
  sl.registerFactoryParam<ProfileBloc, AuthBloc, void>(
    (authBloc, _) => ProfileBloc(
      getProfileUseCase: sl(),
      updateProfileUseCase: sl(),
      authBloc: authBloc,
    ),
  );
  sl.registerLazySingleton(() => GetProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProfileUseCase(sl()));
  sl.registerLazySingleton<ProfileRepository>(
      () => ProfileRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<ProfileRemoteDataSource>(
      () => ProfileRemoteDataSourceImpl(fakeAuthDataSource: sl()));

  //! 6. FEATURES - NOTIFICATIONS
  sl.registerFactory(() => NotificationBloc());
}
