class AppConstants {
  const AppConstants._();

  // Environment — via --dart-define
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  // App
  static const appName = 'JobConnect';

  // Layout
  static const bottomNavHeight = 64.0;
  static const defaultPadding = 16.0;
  static const cardBorderRadius = 12.0;
}
