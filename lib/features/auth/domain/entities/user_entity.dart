import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl; // Thêm trường này cho mạng xã hội học tập StudyHub

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
  });

  /// Hàm copyWith giúp tạo một bản sao của User với một vài thông tin thay đổi
  /// mà không làm ảnh hưởng đến tính bất biến (Immutability).
  UserEntity copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
  }) {
    return UserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  @override
  List<Object?> get props => [id, name, email, avatarUrl];
}