import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' as io;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/entities/profile_entity.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';

class EditProfileScreen extends StatefulWidget {
  final ProfileEntity profile;

  const EditProfileScreen({super.key, required this.profile});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _emailController; // Thêm controller cho email
  DateTime? _selectedDate;
  XFile? _imageFile;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.userName);
    _bioController = TextEditingController(text: widget.profile.bio ?? "");
    _emailController = TextEditingController(text: widget.profile.email);
    _selectedDate = widget.profile.birthDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (pickedFile != null) {
      setState(() => _imageFile = pickedFile);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Chỉnh sửa trang cá nhân",
            style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.read<ProfileBloc>().add(
                    UpdateProfileDetailEvent(
                      name: _nameController.text.trim(),
                      birthDate: _selectedDate,
                      bio: _bioController.text.trim(),
                      avatarPath: _imageFile?.path,
                    ),
                  );
            },
            child: const Text("LƯU",
                style: TextStyle(
                    color: Color(0xFF1877F2),
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
          ),
        ],
      ),
      body: BlocListener<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileUpdateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Đã cập nhật thông tin cá nhân")));
            Navigator.pop(context);
          } else if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(state.message), backgroundColor: Colors.red));
          }
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),

              // --- PHẦN 1: ẢNH ĐẠI DIỆN ---
              _buildSectionTitle("Ảnh đại diện", _pickImage),
              Center(
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey[200]!, width: 2),
                      ),
                      child: CircleAvatar(
                        radius: 70,
                        backgroundColor: Colors.grey[100],
                        // Sửa lỗi ép kiểu: ImageProvider
                        backgroundImage: _imageFile != null
                            ? (kIsWeb
                                ? NetworkImage(_imageFile!.path)
                                : FileImage(io.File(_imageFile!.path))
                                    as ImageProvider)
                            : (widget.profile.avatarUrl != null
                                ? NetworkImage(widget.profile.avatarUrl!)
                                    as ImageProvider
                                : null),
                        child: _imageFile == null &&
                                widget.profile.avatarUrl == null
                            ? Icon(Icons.person,
                                size: 70, color: Colors.grey[400])
                            : null,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 4,
                      child: CircleAvatar(
                        backgroundColor: Colors.grey[200],
                        radius: 18,
                        child: const Icon(Icons.camera_alt,
                            size: 20, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 40, thickness: 8, color: Color(0xFFF0F2F5)),

              // --- PHẦN 2: THÔNG TIN CHI TIẾT ---
              _buildSectionTitle("Thông tin chi tiết", null),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _buildCustomTextField(
                      controller: _nameController,
                      label: "Họ và tên",
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 20),
                    _buildCustomTextField(
                      controller: _emailController,
                      label: "Email (Không thể thay đổi)",
                      icon: Icons.email_outlined,
                      readOnly: true,
                    ),
                    const SizedBox(height: 20),
                    _buildDatePicker(),
                  ],
                ),
              ),
              const Divider(height: 40, thickness: 8, color: Color(0xFFF0F2F5)),

              // --- PHẦN 3: TIỂU SỬ ---
              _buildSectionTitle("Tiểu sử", null),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _bioController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: "Mô tả về bản thân bạn...",
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, VoidCallback? onAction) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          if (onAction != null)
            TextButton(
                onPressed: onAction,
                child: const Text("Chỉnh sửa",
                    style: TextStyle(color: Color(0xFF1877F2)))),
        ],
      ),
    );
  }

  Widget _buildCustomTextField(
      {required TextEditingController controller,
      required String label,
      required IconData icon,
      bool readOnly = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          readOnly: readOnly,
          style: TextStyle(color: readOnly ? Colors.grey : Colors.black),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xFF1877F2)),
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey[300]!)),
            focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF1877F2))),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _selectedDate ?? DateTime(2000),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (date != null) setState(() => _selectedDate = date);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Ngày sinh",
              style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.cake_outlined, color: Color(0xFF1877F2)),
              const SizedBox(width: 12),
              Text(
                _selectedDate == null
                    ? "Thêm ngày sinh"
                    : DateFormat('dd/MM/yyyy').format(_selectedDate!),
                style: const TextStyle(fontSize: 16),
              ),
              const Spacer(),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
          const Divider(),
        ],
      ),
    );
  }
}
