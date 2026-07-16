// lib/features/profile/presentation/screens/profile_screen.dart
import 'package:akare/core/theme/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/di/injection_container.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ProfileCubit>()..load(),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatefulWidget {
  const _ProfileView();

  @override
  State<_ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<_ProfileView> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _controllersInitialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar(BuildContext context) async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null && context.mounted) {
      context.read<ProfileCubit>().uploadAvatar(picked.path);
    }
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل تريد تسجيل الخروج من حسابك؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'تسجيل الخروج',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<ProfileCubit>().logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('حسابي'),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listenWhen: (p, c) =>
            (p.saveSuccess != c.saveSuccess && c.saveSuccess) ||
            (p.errorMessage != c.errorMessage && c.errorMessage != null) ||
            (p.loggedOut != c.loggedOut && c.loggedOut),
        listener: (context, state) {
          if (state.saveSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('تم حفظ التعديلات')));
          }
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }
          if (state.loggedOut) {
            context.go('/login');
          }
        },
        builder: (context, state) {
          if (state.status == ProfileStatus.loading ||
              state.status == ProfileStatus.initial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == ProfileStatus.error && state.profile == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    state.errorMessage ?? 'حدث خطأ',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => context.read<ProfileCubit>().load(),
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          final profile = state.profile!;
          if (!_controllersInitialized) {
            _nameController.text = profile.fullName;
            _phoneController.text = profile.phone;
            _controllersInitialized = true;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.divider,
                        backgroundImage: profile.avatarUrl != null
                            ? CachedNetworkImageProvider(profile.avatarUrl!)
                            : null,
                        child: profile.avatarUrl == null
                            ? const Icon(
                                Icons.person_outline,
                                size: 40,
                                color: AppColors.textSecondary,
                              )
                            : null,
                      ),
                      if (state.isUploadingAvatar)
                        const Positioned.fill(
                          child: CircleAvatar(
                            backgroundColor: Colors.black38,
                            child: SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: state.isUploadingAvatar
                              ? null
                              : () => _pickAvatar(context),
                          child: Container(
                            padding: const EdgeInsets.all(7),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              size: 15,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'الاسم الكامل',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  enabled: false,
                  controller: TextEditingController(text: profile.email),
                  decoration: const InputDecoration(
                    labelText: 'البريد الإلكتروني',
                    border: OutlineInputBorder(),
                    helperText: 'لا يمكن تغيير البريد الإلكتروني',
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'رقم الهاتف',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: state.isSaving
                        ? null
                        : () => context.read<ProfileCubit>().save(
                            fullName: _nameController.text.trim(),
                            phone: _phoneController.text.trim(),
                          ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: state.isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('حفظ التعديلات'),
                  ),
                ),
                const SizedBox(height: 14),
                TextButton(
                  onPressed: () => context.push(
                    '/change-password',
                  ), // شاشة منفصلة، خارج نطاق هذا الرد
                  child: const Text('تغيير كلمة المرور'),
                ),
                const Divider(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _confirmLogout(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(Icons.logout_rounded, size: 18),
                    label: const Text('تسجيل الخروج'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
