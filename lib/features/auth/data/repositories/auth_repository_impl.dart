import 'package:dartz/dartz.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/user_entity.dart';
import '../datasources/fake_auth_data_source.dart'; // Dùng DataSource thay vì main.dart

class AuthRepositoryImpl implements AuthRepository {
  final FakeAuthDataSource fakeDataSource;

  // Constructor nhận fakeDataSource từ main.dart truyền vào
  AuthRepositoryImpl({required this.fakeDataSource});

  @override
  Future<Either<String, UserEntity>> login(
      String email, String password) async {
    try {
      // Gọi logic từ FakeAuthDataSource
      final userData = await fakeDataSource.login(email, password);

      // Chuyển đổi dữ liệu từ Map sang Entity (Giả sử bạn đã có UserEntity)
      return Right(UserEntity(
        id: userData['id'],
        name: userData['name'],
        email: userData['email'],
      ));
    } catch (e) {
      // Trả về thông báo lỗi cụ thể từ DataSource
      return Left(e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Future<Either<String, UserEntity>> register(
      String name, String email, String password) async {
    try {
      final newUser = await fakeDataSource.register(name, email, password);

      // Sau khi đăng ký thành công, trả về một Entity thực
      return Right(UserEntity(id: newUser['id']!, name: name, email: email));
    } catch (e) {
      return Left(e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
