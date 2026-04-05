import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../pages/prescription_medicine_list_page.dart';

class ApiService {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: _rawBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 20),
      headers: {'Content-Type': 'application/json'},
    ),
  )..interceptors.add(InterceptorsWrapper(
      onError: (DioException e, handler) {
        String message = 'An unexpected error occurred';
        if (e.type == DioExceptionType.connectionTimeout) {
          message = 'Connection timed out. Please check your internet.';
        } else if (e.type == DioExceptionType.receiveTimeout) {
          message = 'Server is taking too long to respond. Please try again.';
        } else if (e.type == DioExceptionType.badResponse) {
          message = e.response?.data?['detail'] ??
              'Server error: ${e.response?.statusCode}';
        } else if (e.error is SocketException) {
          message = 'Cannot reach the server. Is the backend running?';
        }

        // Wrap the error in a custom response so callers can handle it uniformly
        return handler.resolve(Response(
          requestOptions: e.requestOptions,
          data: {'success': false, 'error': message},
          statusCode: e.response?.statusCode ?? 500,
        ));
      },
    ));

  static String get _rawBaseUrl {
    const configuredBaseUrl =
        String.fromEnvironment('API_BASE_URL', defaultValue: '');
    final configured = configuredBaseUrl.trim();
    if (configured.isNotEmpty) {
      return _normalizeBaseUrl(configured);
    }

    if (kIsWeb) return 'http://127.0.0.1:8000/api';
    if (!kIsWeb && Platform.isAndroid) return 'http://10.0.2.2:8000/api';
    return 'http://127.0.0.1:8000/api';
  }

  static String _normalizeBaseUrl(String url) {
    final cleaned = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
    if (cleaned.endsWith('/api')) return cleaned;
    return '$cleaned/api';
  }

  /// Sends a 6-digit OTP for any purpose: 'signup', 'login', or 'password_reset'.
  /// Returns {'success': true} on 200/202 or {'success': false, 'error': '...'} on failure.
  static Future<Map<String, dynamic>> sendOtp(
      String email, String purpose) async {
    try {
      final response = await _dio.post(
        '/email/send-otp',
        data: {'email': email, 'purpose': purpose},
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200 || response.statusCode == 202) {
        return {
          'success': true,
          'message': 'Verification code queued successfully'
        };
      }
      return {
        'success': false,
        'error': response.data?['detail'] ??
            response.data?['error'] ??
            'Failed to send OTP',
      };
    } catch (e) {
      return {'success': false, 'error': 'Request failed: ${e.toString()}'};
    }
  }

  /// Sends a 6-digit reset code via the FastAPI background task system.
  static Future<Map<String, dynamic>> sendResetCode(String email) async {
    try {
      final response = await _dio.post(
        '/email/send-otp',
        data: {'email': email, 'purpose': 'password_reset'},
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200 || response.statusCode == 202) {
        return {'success': true, 'message': 'Reset code queued successfully'};
      }
      return response.data;
    } catch (e) {
      return {'success': false, 'error': 'Request failed: ${e.toString()}'};
    }
  }

  static Future<Map<String, dynamic>> uploadPrescription(File imageFile) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(imageFile.path,
            filename: 'upload.jpg'),
      });

      final response = await _dio.post(
        '/ocr/upload',
        data: formData,
        options: Options(receiveTimeout: const Duration(seconds: 120)),
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        List<Medicine> parsedMedicines = [];
        final medsList = data['medications'] as List<dynamic>? ?? [];

        for (var med in medsList) {
          if (med == null) continue;
          final typeStr = (med['dosage_form'] ?? '').toString().toLowerCase();
          MedicineType mType = MedicineType.tablet;
          if (typeStr.contains('capsule')) {
            mType = MedicineType.capsule;
          } else if (typeStr.contains('syrup') || typeStr.contains('liquid')) {
            mType = MedicineType.syrup;
          } else if (typeStr.contains('vitamin')) {
            mType = MedicineType.vitamin;
          }

          final instructionParts = [
            med['instructions'],
            med['frequency'],
            med['duration']
          ].where((e) => e != null && e.toString().trim().isNotEmpty).toList();

          final strength = (med['strength'] ?? '').toString().trim();
          final drugName =
              (med['drug_name'] ?? 'Unknown Medicine').toString().trim();

          parsedMedicines.add(Medicine(
            name: strength.isNotEmpty ? '$drugName $strength' : drugName,
            type: mType,
            instruction: instructionParts.join(' - '),
            quantity: (med['quantity'] ?? '1').toString(),
          ));
        }

        return {
          'medicines': parsedMedicines,
          'rawMedications': medsList,
          'success': true,
        };
      }
      return {
        'success': false,
        'error': response.data['error'] ?? 'Upload failed'
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> verifyOtp(
      String email, String otp, String purpose) async {
    try {
      final response = await _dio.post(
        '/email/verify-otp',
        data: {'email': email, 'otp': otp, 'purpose': purpose},
      );
      if (response.statusCode == 200 && response.data['valid'] == true) {
        return {'success': true, 'token': response.data['token']};
      }
      // Backend returns 'detail' on 4xx errors, 'message' on success body
      return {
        'success': false,
        'error': response.data['detail'] ??
            response.data['message'] ??
            'Verification failed',
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
    String? token, // Signed JWT for authorized reset
  }) async {
    if (token == null || token.isEmpty) {
      return {
        'success': false,
        'error': 'No reset token provided. Please verify your code again.'
      };
    }
    try {
      final response = await _dio.post(
        '/email/reset-password',
        data: {
          'email': email,
          'otp': otp,
          'new_password': newPassword,
          'token': token, // Send token in body as Pydantic model expects
        },
      );
      if (response.statusCode == 200) return {'success': true};
      return {
        'success': false,
        'error':
            response.data['detail'] ?? response.data['error'] ?? 'Reset failed'
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}
