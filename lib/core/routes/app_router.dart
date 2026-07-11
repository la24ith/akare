import 'dart:async';
import 'package:akare/features/property_details/presentation/screens/property_details_screen.dart';
import 'package:akare/features/search/presentation/screens/search_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import '../network/supabase_client.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';

/// كل الروابط في مكان واحد. عند إضافة feature جديدة أضف الـ route هنا.
final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
  refreshListenable: GoRouterRefreshStream(supabase.auth.onAuthStateChange),
  redirect: (context, state) {
    final isLoggedIn = supabase.auth.currentSession != null;
    final isAuthRoute = ['/login', '/register', '/forgot-password']
        .contains(state.matchedLocation);

    // لو مش مسجل دخول وحاول يفتح صفحة محمية → رجّعه لصفحة الدخول
    if (!isLoggedIn && !isAuthRoute) return '/login';

    // لو مسجل دخول ومحاول يفتح صفحة تسجيل الدخول/التسجيل → رجّعه للرئيسية
    if (isLoggedIn && isAuthRoute) return '/home';

    return null; // لا يوجد إعادة توجيه
  },
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: '/search',
      builder: (context, state) => const SearchScreen(),
    ),
    GoRoute(
      path: '/property/:id',
      builder: (context, state) => PropertyDetailsScreen(
        propertyId: state.pathParameters['id']!,
      ),
    ),

    // TODO: أضف /agent/* لتطبيق الوكيل و /admin/* للوحة التحكم لاحقًا
    // TODO: أضف /agent/* لتطبيق الوكيل و /admin/* للوحة التحكم لاحقًا
  ],
);

/// يحوّل Stream الخاص بـ Supabase Auth إلى Listenable حتى يقدر go_router
/// يعيد تقييم الـ redirect تلقائيًا كلما تغيّرت حالة تسجيل الدخول
/// (مثلاً بعد Login أو Logout مباشرة، بدون الحاجة لأي setState يدوي)
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
