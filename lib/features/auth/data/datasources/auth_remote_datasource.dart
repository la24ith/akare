import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/user_entity.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({required String email, required String password});

  Future<UserModel> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String role,
  });

  Future<void> forgotPassword({required String email});

  Future<UserModel?> getCurrentUser();

  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabaseClient;
  AuthRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final userId = response.user?.id;
      if (userId == null) {
        throw AuthException2('فشل تسجيل الدخول');
      }

      return _fetchProfile(userId);
    } on AuthException catch (e) {
      throw AuthException2(_mapAuthError(e.message));
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String role,
  }) async {
    try {
      final response = await supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'phone': phone,
          'role': role,
        },
      );

      final userId = response.user?.id;
      if (userId == null) {
        throw AuthException2('فشل إنشاء الحساب');
      }

      // ملاحظة: الـ Trigger في قاعدة البيانات (handle_new_user) بينشئ صف
      // public.users تلقائيًا. نحاول جلبه؛ لو لسه ما اتسجلش (سباق نادر جدًا)
      // نرجّع بيانات مبنية من المدخلات مباشرة بدل ما نفشل بالكامل.
      try {
        return await _fetchProfile(userId);
      } catch (_) {
        return UserModel(
          id: userId,
          fullName: fullName,
          email: email,
          phone: phone,
          role: role == 'agent' ? UserRole.agent : UserRole.user,
          isVerified: false,
        );
      }
    } on AuthException catch (e) {
      throw AuthException2(_mapAuthError(e.message));
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    try {
      await supabaseClient.auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      throw AuthException2(_mapAuthError(e.message));
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final userId = supabaseClient.auth.currentUser?.id;
    if (userId == null) return null;
    try {
      return await _fetchProfile(userId);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> logout() async {
    try {
      await supabaseClient.auth.signOut();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<UserModel> _fetchProfile(String userId) async {
    final row = await supabaseClient
        .from('users')
        .select()
        .eq('id', userId)
        .single();
    return UserModel.fromMap(row);
  }

  String _mapAuthError(String message) {
    // ترجمة أشهر رسائل Supabase الإنجليزية لرسائل عربية مفهومة للمستخدم
    if (message.contains('Invalid login credentials')) {
      return 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
    }
    if (message.contains('User already registered')) {
      return 'هذا البريد الإلكتروني مسجل بالفعل';
    }
    if (message.contains('Password should be at least')) {
      return 'كلمة المرور قصيرة جدًا';
    }
    return message;
  }
}
