import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/profile_entity.dart';

class ProfileInfoCard extends StatelessWidget {
  final ProfileEntity profile;

  const ProfileInfoCard({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Thông tin chi tiết",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Dòng hiển thị Gmail
            _buildInfoRow(
              icon: Icons.email_outlined,
              label: "Email",
              value: profile.email,
            ),
            const Divider(height: 24),

            // Dòng hiển thị Ngày sinh
            _buildInfoRow(
              icon: Icons.cake_outlined,
              label: "Ngày sinh",
              value: profile.birthDate != null
                  ? DateFormat('dd/MM/yyyy').format(profile.birthDate!)
                  : "Chưa cập nhật",
            ),
            const Divider(height: 24),

            // Dòng hiển thị Tiểu sử (Bio)
            _buildInfoRow(
              icon: Icons.info_outline,
              label: "Giới thiệu",
              value: profile.bio ?? "Chưa có tiểu sử",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.blue, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }
}