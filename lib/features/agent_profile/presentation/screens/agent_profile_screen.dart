import "package:akare/core/theme/app_colors.dart";
import "package:akare/core/di/injection_container.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:go_router/go_router.dart";

import "../cubit/agent_profile_cubit.dart";

class AgentProfileScreen extends StatelessWidget {
  const AgentProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AgentProfileCubit>()..loadProfile(),
      child: const _AgentProfileView(),
    );
  }
}

class _AgentProfileView extends StatefulWidget {
  const _AgentProfileView();

  @override
  State<_AgentProfileView> createState() => _AgentProfileViewState();
}

class _AgentProfileViewState extends State<_AgentProfileView> {
  final _nameController = TextEditingController();
  final _companyController = TextEditingController();
  final _licenseController = TextEditingController();
  final _bioController = TextEditingController();
  bool _initialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    _companyController.dispose();
    _licenseController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _confirmSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("تسجيل الخروج"),
        content: const Text("هل أنت متأكد من تسجيل الخروج؟"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("إلغاء"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final ok = await context.read<AgentProfileCubit>().signOut();
              if (ok && context.mounted) context.go("/login");
            },
            child: const Text(
              "تسجيل الخروج",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F8),
      appBar: AppBar(
        title: const Text("حسابي"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: BlocConsumer<AgentProfileCubit, AgentProfileState>(
        listenWhen: (p, c) => p.saveStatus != c.saveStatus,
        listener: (context, state) {
          if (state.saveStatus == AgentProfileSaveStatus.saved) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("تم حفظ التعديلات بنجاح")),
            );
          } else if (state.saveStatus == AgentProfileSaveStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? "تعذّر الحفظ")),
            );
          }
        },
        builder: (context, state) {
          if (state.status == AgentProfileStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == AgentProfileStatus.error) {
            return Center(child: Text(state.errorMessage ?? "حدث خطأ"));
          }
          final profile = state.profile!;
          if (!_initialized) {
            _nameController.text = profile.fullName;
            _companyController.text = profile.companyName ?? "";
            _licenseController.text = profile.licenseNumber ?? "";
            _bioController.text = profile.bio ?? "";
            _initialized = true;
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 44,
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      backgroundImage: profile.avatarUrl != null
                          ? NetworkImage(profile.avatarUrl!)
                          : null,
                      child: profile.avatarUrl == null
                          ? Icon(
                              Icons.person,
                              size: 44,
                              color: AppColors.primary,
                            )
                          : null,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          profile.fullName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (profile.isVerifiedAgent) ...[
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.verified,
                            color: Color(0xFF0E6E5C),
                            size: 18,
                          ),
                        ],
                      ],
                    ),
                    Text(
                      profile.email,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    Text(
                      profile.phone,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "الاسم الكامل",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _companyController,
                decoration: const InputDecoration(
                  labelText: "اسم الشركة",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _licenseController,
                decoration: const InputDecoration(
                  labelText: "رقم الترخيص",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _bioController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "نبذة عني",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: state.saveStatus == AgentProfileSaveStatus.saving
                    ? null
                    : () => context.read<AgentProfileCubit>().updateProfile(
                        fullName: _nameController.text.trim(),
                        companyName: _companyController.text.trim(),
                        licenseNumber: _licenseController.text.trim(),
                        bio: _bioController.text.trim(),
                      ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: state.saveStatus == AgentProfileSaveStatus.saving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text("حفظ التعديلات"),
              ),
              const SizedBox(height: 24),
              ListTile(
                tileColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                leading: const Icon(Icons.home_work_outlined),
                title: const Text("عقاراتي"),
                trailing: const Icon(Icons.arrow_back_ios, size: 14),
                onTap: () => context.push("/agent/properties"),
              ),
              const SizedBox(height: 10),
              ListTile(
                tileColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  "تسجيل الخروج",
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () => _confirmSignOut(context),
              ),
            ],
          );
        },
      ),
    );
  }
}
