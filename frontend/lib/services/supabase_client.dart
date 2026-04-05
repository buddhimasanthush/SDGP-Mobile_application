import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: 'https://zdgugonfvsadghkijfnh.supabase.co',
      anonKey: 'sb_publishable_yFf517gDvREqKsR75e6Jxg_JLkl6Uu1',
    );
  }
}
