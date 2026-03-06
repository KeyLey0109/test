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
import 'features/post/presentation/bloc/post_bloc.dart';

// --- IMPORT COMMENT ---
import 'features/comment/data/repositories/comment_repository_impl.dart';
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
  //! 1. FEATURES - AUTH
  sl.registerFactory(() => AuthBloc(loginUseCase: sl(), registerUseCase: sl()));
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  // Ràng buộc interface AuthRepository với implementation AuthRepositoryImpl
  sl.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(fakeDataSource: sl()));
  sl.registerLazySingleton(() => FakeAuthDataSource());

  //! 2. FEATURES - POST
  sl.registerFactoryParam<PostBloc, AuthBloc, NotificationBloc>(
    (authBloc, notificationBloc) => PostBloc(
      getPostsUseCase: sl(),
      createPostUseCase: sl(),
      authBloc: authBloc,
      notificationBloc: notificationBloc,
    ),
  );
  sl.registerLazySingleton(() => GetPostsUseCase(sl()));
  sl.registerLazySingleton(() => CreatePostUseCase(sl()));
  // QUAN TRỌNG: Đảm bảo PostRepository được đăng ký đúng kiểu trừu tượng
  sl.registerLazySingleton<PostRepository>(
      () => PostRepositoryImpl(localDataSource: sl()));
  // Ràng buộc interface DataSource với implementation cụ thể
  sl.registerLazySingleton<PostLocalDataSource>(
      () => PostLocalDataSourceImpl(sharedPreferences: sl()));

  //! 3. FEATURES - COMMENT
  sl.registerFactory(() => CommentBloc(addCommentUseCase: sl()));
  sl.registerLazySingleton(() => AddCommentUseCase(sl()));
  // Đảm bảo CommentRepository cũng được đăng ký tương tự
  sl.registerLazySingleton<CommentRepository>(
      () => CommentRepositoryImpl(localDataSource: sl()));

  //! 4. FEATURES - PROFILE
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
      () => ProfileRemoteDataSourceImpl());

  //! 5. FEATURES - NOTIFICATIONS
  sl.registerFactory(() => NotificationBloc());

  //! 6. EXTERNAL
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
}
