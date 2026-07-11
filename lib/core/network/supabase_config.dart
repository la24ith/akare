class SupabaseConfig {
  SupabaseConfig._();

  static const String url = String.fromEnvironment(
    'SUPABASE_URL', // <-- اسم المتغيّر فقط، مش الرابط نفسه
    defaultValue: 'https://YOUR_PROJECT_REF.supabase.co',
  );

  static const String anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY', // <-- اسم المتغيّر فقط، مش المفتاح نفسه
    defaultValue: 'YOUR_ANON_KEY',
  );
}
