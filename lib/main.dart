import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'injection_container.dart' as di;

// Import các Bloc
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/post/presentation/bloc/post_bloc.dart';
import 'features/post/presentation/bloc/post_event.dart';
import 'features/comment/presentation/bloc/comment_bloc.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';
import 'features/notifications/presentation/bloc/notification_bloc.dart';
import 'features/notifications/presentation/bloc/notification_event.dart';

// Import các trang giao diện
import 'features/auth/presentation/pages/login_page.dart';
import 'features/post/presentation/pages/root_page.dart';

void main() async {
  // 1. Đảm bảo Flutter binding được khởi tạo
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Khóa hướng màn hình dọc
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // 3. Khởi tạo Dependency Injection (GetIt)
  await di.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MultiBlocProvider giúp các Widget con dễ dàng truy cập logic
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => di.sl<AuthBloc>()..add(AppStarted()),
        ),

        // Chú ý: Cần Đổi vị trí NotificationBloc lên trước PostBloc để có thể Inject param2
        BlocProvider<NotificationBloc>(
          create: (_) =>
              di.sl<NotificationBloc>()..add(const LoadNotifications()),
        ),

        // PostBloc nhận AuthBloc để biết "ai" đang tương tác bài viết và NotificationBloc để đẩy thông báo
        BlocProvider<PostBloc>(
          create: (context) => di.sl<PostBloc>(
            param1: BlocProvider.of<AuthBloc>(context),
            param2: BlocProvider.of<NotificationBloc>(context),
          )..add(const LoadPosts()),
        ),

        // ProfileBloc cũng cần AuthBloc để hiển thị thông tin sinh viên tương ứng
        BlocProvider<ProfileBloc>(
          create: (context) => di.sl<ProfileBloc>(
            param1: BlocProvider.of<AuthBloc>(context),
          ),
        ),

        BlocProvider<CommentBloc>(create: (_) => di.sl<CommentBloc>()),
      ],
      child: MaterialApp(
        title: 'StudyHub',
        debugShowCheckedModeBanner: false,
        theme: _buildTheme(context),
        home: const AuthenticationWrapper(),
      ),
    );
  }

  ThemeData _buildTheme(BuildContext context) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF1877F2),
        primary: const Color(0xFF1877F2),
      ),
      textTheme: GoogleFonts.robotoTextTheme(Theme.of(context).textTheme),
      scaffoldBackgroundColor: const Color(0xFFF0F2F5),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0.5,
        surfaceTintColor: Colors.white,
        centerTitle: false,
      ),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Lắng nghe trạng thái đăng nhập để điều hướng
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthSuccess) {
          return const RootPage();
        } else if (state is AuthLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return const LoginPage();
      },
    );
  }
}
