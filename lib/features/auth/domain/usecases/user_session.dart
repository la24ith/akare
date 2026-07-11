import 'package:flutter/foundation.dart';
import '../../../../core/network/supabase_client.dart'; // أو المسار الصحيح عندك لـ `supabase`

class UserSession extends ChangeNotifier {
  String? role;
  bool isLoadingRole = false;

  Future<void> loadRole() async {
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) {
      role = null;
      return;
    }
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
    notifyListeners();
  }
}

// هاد السطر هو المفقود — بدونه ما في متغيّر اسمه userSession يقدر
// app_router.dart يشوفه، حتى لو الاستيراد نفسه صحيح.
final userSession = UserSession();
