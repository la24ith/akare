import 'package:supabase_flutter/supabase_flutter.dart';

/// اختصار سريع: بدل ما تكتب Supabase.instance.client في كل مكان
/// تقدر تستخدم supabase مباشرة بعد استيراد هذا الملف.
final SupabaseClient supabase = Supabase.instance.client;
