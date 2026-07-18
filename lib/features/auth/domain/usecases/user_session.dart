import 'package:akare/core/network/supabase_client.dart';
import 'package:flutter/material.dart';

class UserSession extends ChangeNotifier {
  String? role;
  bool isLoadingRole = false;

  // إذا فيه طلب شغّال أصلًا، أي نداء تاني لازم يستنى نفس النتيجة —
  // مش يبلش طلب مستقل جديد. هذا بالضبط اللي كان ناقص وسبب التذبذب.
  Future<void>? _inFlight;

  Future<void> loadRole() {
    if (_inFlight != null) return _inFlight!;

    final uid = supabase.auth.currentUser?.id;
    if (uid == null) {
      role = null;
      return Future.value();
    }

    _inFlight = _fetchRole(uid).whenComplete(() => _inFlight = null);
    return _inFlight!;
  }

  Future<void> _fetchRole(String uid) async {
    isLoadingRole = true;
    try {
      final row = await supabase
          .from('users')
          .select('role')
          .eq('id', uid)
          .single();
      role = row['role'] as String?;
    } finally {
      isLoadingRole = false;
      notifyListeners();
    }
  }

  void clear() {
    role = null;
    _inFlight = null;
    notifyListeners();
  }
}

final userSession = UserSession();
