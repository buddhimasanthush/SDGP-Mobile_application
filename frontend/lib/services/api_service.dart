import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../pages/prescription_medicine_list_page.dart';

class ApiService {
  static const String _productionBaseUrl =
      'https://sdgp-mobileapplication-production.up.railway.app/api';

  static String get _baseUrl {
    const definedBaseUrl = String.fromEnvironment('API_BASE_URL');
    if (definedBaseUrl.isNotEmpty) return _normalizeBaseUrl(definedBaseUrl);

    // By default, always hit production backend so mobile debug builds
    // don't silently point to localhost and appear to hang.
    const useLocalBackend = bool.fromEnvironment(
      'USE_LOCAL_BACKEND',
      defaultValue: false,
    );
    if (!useLocalBackend || kReleaseMode) return _productionBaseUrl;

    if (kIsWeb) return 'http://127.0.0.1:8000/api';
    if (Platform.isAndroid) return 'http://10.0.2.2:8000/api';
    return 'http://127.0.0.1:8000/api';
  }

  static String _normalizeBaseUrl(String baseUrl) {
    final trimmed = baseUrl.trim();
    if (trimmed.endsWith('/api')) return trimmed;
    if (trimmed.endsWith('/')) return '${trimmed}api';
    return '$trimmed/api';
  }

  static List<String> _authBaseUrls() {
    final urls = <String>[_baseUrl];
    if (_baseUrl != _productionBaseUrl) {
      urls.add(_productionBaseUrl);
    }
    return urls;
  }

  static Future<Map<String, dynamic>> uploadPrescription(File imageFile) async {
    try {
      debugPrint('ApiService: uploading to $_baseUrl/ocr/upload');
      final request =
          http.MultipartRequest('POST', Uri.parse('$_baseUrl/ocr/upload'));
      request.files
          .add(await http.MultipartFile.fromPath('file', imageFile.path));

      final streamedResponse =
          await request.send().timeout(const Duration(seconds: 180));
      final respStr = await streamedResponse.stream.bytesToString();
      debugPrint(
          'ApiService: response status = ${streamedResponse.statusCode}');
      debugPrint('ApiService: response body = $respStr');

      if (streamedResponse.statusCode == 200) {
        final jsonMap = jsonDecode(respStr) as Map<String, dynamic>;

        // Server returns 200 with success=false for OCR content failures
        // (unreadable image, no medicines detected) -- not a network error.
        if (jsonMap['success'] == false) {
          final errMsg =
              (jsonMap['error'] ?? 'Could not process prescription').toString();
          debugPrint('ApiService: OCR content failure: \$errMsg');
          return {'success': false, 'error': errMsg};
        }

        final data = jsonMap['data'] as Map<String, dynamic>;

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

          final instruction = instructionParts.join(' - ');
          final strength = (med['strength'] ?? '').toString().trim();
          final drugName =
              (med['drug_name'] ?? 'Unknown Medicine').toString().trim();

          parsedMedicines.add(Medicine(
            name: strength.isNotEmpty ? '$drugName $strength' : drugName,
            type: mType,
            instruction:
                instruction.isEmpty ? 'As directed by doctor' : instruction,
            quantity: (med['quantity'] ?? 'Qty as prescribed').toString(),
          ));
        }

        final String medicalHistory =
            (data['diagnosis_notes'] ?? '').toString();
        final String confidence = (data['confidence'] ?? 'high').toString();

        if (parsedMedicines.isEmpty) {
          final diagnosis = medicalHistory.trim();
          final message = diagnosis.isNotEmpty
              ? diagnosis
              : 'Could not detect medicines from this image. Please upload a clearer prescription photo.';
          return {
            'success': false,
            'error': message,
            'rawMedications': medsList,
            'confidence': confidence,
          };
        }

        return {
          'medicines': parsedMedicines,
          'rawMedications': medsList, // Keep raw data for pharmacy search
          'medicalHistory': medicalHistory,
          'confidence': confidence,
          'success': true,
        };
      } else {
        // Try to parse error detail from response
        String errorMsg = 'Server error (${streamedResponse.statusCode})';
        try {
          final errJson = jsonDecode(respStr) as Map<String, dynamic>;
          final detail = errJson['detail'];
          if (detail is String) {
            errorMsg = detail;
          } else if (detail is Map<String, dynamic>) {
            final msg = detail['message']?.toString();
            final stage = detail['stage']?.toString();
            final validation = detail['validation'];
            final v = validation is Map<String, dynamic>
                ? ' (${validation['field'] ?? 'field'}: ${validation['reason'] ?? validation.toString()})'
                : '';
            errorMsg = [
              if (msg != null && msg.isNotEmpty) msg,
              if (stage != null && stage.isNotEmpty) '[stage: $stage]',
            ].join(' ').trim();
            if (v.isNotEmpty) errorMsg = '$errorMsg$v';
            if (errorMsg.isEmpty) errorMsg = 'Validation failed.';
          } else if (errJson['validation_errors'] is List) {
            final errors = (errJson['validation_errors'] as List)
                .whereType<Map<String, dynamic>>()
                .map((e) => '${e['field']}: ${e['message']}')
                .join(', ');
            if (errors.isNotEmpty) {
              errorMsg = 'Request validation failed: $errors';
            }
          }
        } catch (_) {}
        return {'success': false, 'error': errorMsg};
      }
    } on SocketException {
      return {
        'success': false,
        'error':
            'Cannot connect to server. Please ensure the backend is running.'
      };
    } catch (e) {
      debugPrint('ApiService error: $e');
      return {'success': false, 'error': 'Upload failed: ${e.toString()}'};
    }
  }

  /// Search pharmacies using OCR-extracted medication names.
  /// [medications] should be the raw medications list from the OCR result.
  /// [latitude] and [longitude] are the user's current location.
  static Future<Map<String, dynamic>> searchPharmaciesByPrescription({
    required double latitude,
    required double longitude,
    required List<dynamic> medications,
    int radiusMeters = 7000,
  }) async {
    try {
      debugPrint(
          'ApiService: searching pharmacies at $_baseUrl/pharmacy/search-by-prescription');

      // Build medication list for the API
      final medList = medications
          .map((med) {
            if (med == null) return null;
            return {
              'drug_name': (med['drug_name'] ?? '').toString(),
              'quantity': (med['quantity'] ?? '1').toString(),
              'strength': (med['strength'] ?? '').toString(),
              'dosage_form': (med['dosage_form'] ?? '').toString(),
            };
          })
          .where((m) => m != null)
          .toList();

      final response = await http
          .post(
            Uri.parse('$_baseUrl/pharmacy/search-by-prescription'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'latitude': latitude,
              'longitude': longitude,
              'medications': medList,
              'radius_meters': radiusMeters,
            }),
          )
          .timeout(const Duration(seconds: 30));

      debugPrint('ApiService: pharmacy search status = ${response.statusCode}');
      debugPrint('ApiService: pharmacy search body = ${response.body}');

      if (response.statusCode == 200) {
        final jsonMap = jsonDecode(response.body) as Map<String, dynamic>;
        return {'success': true, ...jsonMap};
      } else {
        String errorMsg = 'Pharmacy search failed (${response.statusCode})';
        try {
          final errJson = jsonDecode(response.body);
          errorMsg = errJson['detail'] ?? errorMsg;
        } catch (_) {}
        return {'success': false, 'error': errorMsg};
      }
    } on SocketException {
      return {'success': false, 'error': 'Cannot connect to server.'};
    } catch (e) {
      debugPrint('ApiService pharmacy search error: $e');
      return {
        'success': false,
        'error': 'Pharmacy search failed: ${e.toString()}'
      };
    }
  }

  static Future<Map<String, dynamic>> requestPasswordResetOtp({
    required String identifier,
  }) async {
    String? lastError;
    for (final base in _authBaseUrls()) {
      try {
        final response = await http
            .post(
              Uri.parse('$base/auth/password-reset/request'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({'identifier': identifier}),
            )
            .timeout(const Duration(seconds: 30));

        final body = response.body.isNotEmpty
            ? jsonDecode(response.body) as Map<String, dynamic>
            : <String, dynamic>{};

        if (response.statusCode == 200) {
          return body;
        }

        lastError = body['detail']?.toString() ??
            'Failed to send OTP (${response.statusCode})';
      } on SocketException {
        lastError = 'Cannot connect to server.';
      } on TimeoutException {
        lastError = 'Server timeout while sending OTP.';
      } catch (e) {
        lastError = 'Failed to send OTP: $e';
      }
    }
    return {'success': false, 'error': lastError ?? 'Failed to send OTP.'};
  }

  static Future<Map<String, dynamic>> verifyPasswordResetOtp({
    required String identifier,
    required String otp,
    required String newPassword,
  }) async {
    String? lastError;
    for (final base in _authBaseUrls()) {
      try {
        final response = await http
            .post(
              Uri.parse('$base/auth/password-reset/verify'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'identifier': identifier,
                'otp': otp,
                'new_password': newPassword,
              }),
            )
            .timeout(const Duration(seconds: 30));

        final body = response.body.isNotEmpty
            ? jsonDecode(response.body) as Map<String, dynamic>
            : <String, dynamic>{};

        if (response.statusCode == 200) {
          return body;
        }

        lastError = body['detail']?.toString() ??
            'Failed to reset password (${response.statusCode})';
      } on SocketException {
        lastError = 'Cannot connect to server.';
      } on TimeoutException {
        lastError = 'Server timeout while resetting password.';
      } catch (e) {
        lastError = 'Failed to reset password: $e';
      }
    }
    return {
      'success': false,
      'error': lastError ?? 'Failed to reset password.'
    };
  }
}
