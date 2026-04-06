import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    const fallbackUrl = 'https://zdgugonfvsadghkijfnh.supabase.co';
    const fallbackAnonKey = 'sb_publishable_yFf517gDvREqKsR75e6Jxg_JLkl6Uu1';
    const configuredUrl = String.fromEnvironment('SUPABASE_URL');
    const configuredAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
    final resolvedUrl = configuredUrl.isNotEmpty ? configuredUrl : fallbackUrl;
    final resolvedAnonKey =
        configuredAnonKey.isNotEmpty ? configuredAnonKey : fallbackAnonKey;

    await Supabase.initialize(
      url: resolvedUrl,
      anonKey: resolvedAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
        autoRefreshToken: true,
      ),
    );
  }
}
