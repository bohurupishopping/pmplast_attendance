class SupabaseConfig {
  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://api-pmplst.nojor.de',
  );
  
  static const String anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJzdXBhYmFzZSIsImlhdCI6MTc1MTEwMjg4MCwiZXhwIjo0OTA2Nzc2NDgwLCJyb2xlIjoiYW5vbiJ9.l2DB1vheNToDkiRt_ghZV4DA2hbHOHb4-qMLU7mwEIA',
  );
}
