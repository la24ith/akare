import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://sowkmrqrmpciklebwqxy.supabase.co',
    anonKey: 'sowkmrqrmpciklebwqxy', // من Project Settings → API
  );

  runApp(const ProviderScope(child: RealEstateApp()));
}
