/// Application-level configuration constants.
///
/// Replace the placeholder values with real Supabase project credentials
/// before running the app.
class AppConfig {
  AppConfig._(); // prevent instantiation

  /// The URL of the Supabase project (e.g. https://xxxxx.supabase.co).
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';

  /// The anonymous (public) key for the Supabase project.
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

  /// Base URL for the PDR_AI_v2 backend API.
  static const String backendBaseUrl = 'YOUR_BACKEND_URL';
}
