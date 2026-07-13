import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/di/injection_container.dart' as di;
import 'core/network/supabase_config.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://sowkmrqrmpciklebwqxy.supabase.co',
    anonKey: 'sb_publishable_Hxr2XbRx3KYfimYu_h-QKw_BhQEzPp9',
  );

  await di.init();

  runApp(const RealEstateApp());
}

class RealEstateApp extends StatelessWidget {
  const RealEstateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: ' عقاري',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,

      // ---- دعم اللغة العربية ----
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations
            .delegate, // تعريب الأزرار/الحوارات الجاهزة (Material)
        GlobalWidgetsLocalizations
            .delegate, // اتجاه النص RTL/LTR للـ Widgets الأساسية
        GlobalCupertinoLocalizations
            .delegate, // تعريب مكونات Cupertino (لو استُخدمت)
      ],

      routerConfig: appRouter,
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
