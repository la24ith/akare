import 'dart:async';
import 'package:akare/features/agent_dashboard/presentation/screens/agent_dashboard_screen.dart';
import 'package:akare/features/agent_profile/presentation/screens/agent_profile_screen.dart';
import 'package:akare/features/auth/domain/usecases/user_session.dart';
import 'package:akare/features/my_properties/presentation/screens/agent_property_detail_screen.dart';
import 'package:akare/features/my_properties/presentation/screens/my_properties_screen.dart';
import 'package:akare/features/property_details/presentation/screens/property_details_screen.dart'
    hide PropertyDetailsScreen;
import 'package:akare/features/property_form/presentation/screens/property_form_screen.dart';
import 'package:akare/features/search/presentation/screens/search_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../network/supabase_client.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';

/// كل الروابط في مكان واحد. عند إضافة feature جديدة أضف الـ route هنا.
final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
  refreshListenable: GoRouterRefreshStream(supabase.auth.onAuthStateChange),
  redirect: (context, state) async {
    final isLoggedIn = supabase.auth.currentSession != null;
    final isAuthRoute = [
      '/login',
      '/register',
      '/forgot-password',
    ].contains(state.matchedLocation);

    if (!isLoggedIn) {
      userSession.clear();
      return isAuthRoute ? null : '/login';
    }

    // مسجل دخول وعلى صفحة auth (أو أول فتح للتطبيق بجلسة محفوظة) → حدّد وجهته حسب دوره
    if (isAuthRoute) {
      await userSession.loadRole(); // يجيب الدور مرة وحدة ويخزنه
      return userSession.role == 'agent' ? '/agent/dashboard' : '/home';
    }

    // حماية إضافية: لو مستخدم عادي حاول يفتح رابط وكيل يدويًا
    if (state.matchedLocation.startsWith('/agent') &&
        userSession.role != 'agent') {
      return '/home';
    }

    return null;
  },
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    GoRoute(path: '/search', builder: (context, state) => const SearchScreen()),
    GoRoute(
      path: '/property/:id',
      builder: (context, state) =>
          PropertyDetailsScreen(propertyId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: "/agent/dashboard",
      builder: (context, state) => const AgentDashboardScreen(),
    ),
    GoRoute(
      path: "/agent/properties",
      builder: (context, state) => const MyPropertiesScreen(),
    ),
    GoRoute(
      path: "/agent/properties/add",
      builder: (context, state) => const PropertyFormScreen(),
    ),
    GoRoute(
      path: "/agent/properties/edit/:id",
      builder: (context, state) =>
          PropertyFormScreen(propertyId: state.pathParameters["id"]),
    ),

    GoRoute(
      path: "/agent/profile",
      builder: (context, state) => const AgentProfileScreen(),
    ),

    GoRoute(
      path: "/agent/properties/:id",
      builder: (context, state) =>
          PropertyDetailsScreen(propertyId: state.pathParameters["id"]!),
    ),
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

Future<String?> agentRedirectLogic(
  BuildContext context,
  GoRouterState state,
  Session? session,
) async {
  final loggingIn = state.matchedLocation == "/login";
  if (session == null) {
    return loggingIn ? null : "/login";
  }

  // اجلب الدور من جدول users (يفضّل تخزينه بذاكرة مؤقتة/Cubit عام بعد تسجيل الدخول
  // بدل استعلامه بكل مرة redirect، لتفادي بطء التنقل)
  final client = Supabase.instance.client;
  final userRow = await client
      .from("users")
      .select("role")
      .eq("id", session.user.id)
      .single();
  final role = userRow["role"] as String;

  final isAgentRoute = state.matchedLocation.startsWith("/agent");

  if (loggingIn) {
    return role == "agent" ? "/agent/dashboard" : "/home";
  }

  // امنع مستخدم عادي من فتح روابط الوكيل، والعكس اختياري حسب رغبتك
  if (isAgentRoute && role != "agent") {
    return "/home";
  }

  return null;
}
