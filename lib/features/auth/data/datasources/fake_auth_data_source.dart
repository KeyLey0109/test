class FakeAuthDataSource {
  // Giả lập danh sách tài khoản trong hệ thống
  final List<Map<String, dynamic>> _fakeUsers = [
    {
      'id': 'user_viet',
      'email': 'viet@pyu.edu.vn',
      'password': '123',
      'name': 'Việt'
    },
    {
      'id': 'admin',
      'email': 'admin@studyhub.com',
      'password': 'admin',
      'name': 'Admin'
    },
  ];

  // Expose the getter to find a user by ID
  List<Map<String, dynamic>> get users => _fakeUsers;

  /// Giả lập việc gọi API đăng nhập
  Future<Map<String, dynamic>> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));

    for (var user in _fakeUsers) {
      if (user['email'] == email && user['password'] == password) {
        return {
          'id': user['id'],
          'name': user['name'],
          'email': user['email'],
          'token': 'fake_jwt_token_for_studyhub',
        };
      }
    }

    throw Exception('Email hoặc mật khẩu không chính xác!');
  }

  Future<Map<String, dynamic>> register(
      String name, String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));

    // Kiểm tra xem email đã tồn tại chưa
    if (_fakeUsers.any((u) => u['email'] == email)) {
      throw Exception('Email này đã được sử dụng!');
    }

    final newUser = {
      'id': 'user_${DateTime.now().millisecondsSinceEpoch}',
      'name': name,
      'email': email,
      'password': password,
    };

    _fakeUsers.add(newUser);
    return newUser;
  }

  void updateUser(String userId,
      {String? name, DateTime? birthDate, String? bio, String? avatarUrl}) {
    final index = _fakeUsers.indexWhere((u) => u['id'] == userId);
    if (index != -1) {
      if (name != null) _fakeUsers[index]['name'] = name;
      if (birthDate != null) _fakeUsers[index]['birthDate'] = birthDate;
      if (bio != null) _fakeUsers[index]['bio'] = bio;
      if (avatarUrl != null) _fakeUsers[index]['avatarUrl'] = avatarUrl;
    }
  }
}
