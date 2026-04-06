import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    const configuredUrl = String.fromEnvironment('SUPABASE_URL');
    const configuredAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

    if (configuredUrl.isEmpty || configuredAnonKey.isEmpty) {
      throw StateError(
        'Missing Supabase configuration. Pass SUPABASE_URL and SUPABASE_ANON_KEY via --dart-define.',
      );
    }

    await Supabase.initialize(
      url: configuredUrl,
      anonKey: configuredAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
        autoRefreshToken: true,
      ),
    );
  }
}
