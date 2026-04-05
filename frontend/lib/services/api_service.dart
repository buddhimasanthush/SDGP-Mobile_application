import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../pages/prescription_medicine_list_page.dart';

class ApiService {
  static String get _baseUrl {
    if (kIsWeb) return 'http://127.0.0.1:8000/api';
    if (!kIsWeb && Platform.isAndroid) return 'http://10.0.2.2:8000/api';
    return 'http://127.0.0.1:8000/api';
  }

  static Future<Map<String, dynamic>> uploadPrescription(File imageFile) async {
    try {
      debugPrint('ApiService: uploading to $_baseUrl/ocr/upload');
      final request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/ocr/upload'));
      request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      final streamedResponse = await request.send().timeout(const Duration(seconds: 120));
      final respStr = await streamedResponse.stream.bytesToString();
      debugPrint('ApiService: response status = ${streamedResponse.statusCode}');
      debugPrint('ApiService: response body = $respStr');

      if (streamedResponse.statusCode == 200) {
        final jsonMap = jsonDecode(respStr) as Map<String, dynamic>;
        final data = jsonMap['data'] as Map<String, dynamic>;

        List<Medicine> parsedMedicines = [];
        final medsList = data['medications'] as List<dynamic>? ?? [];
        for (var med in medsList) {
          if (med == null) continue;
          final typeStr = (med['dosage_form'] ?? '').toString().toLowerCase();
          MedicineType mType = MedicineType.tablet;
          if (typeStr.contains('capsule')) mType = MedicineType.capsule;
          else if (typeStr.contains('syrup') || typeStr.contains('liquid')) mType = MedicineType.syrup;
          else if (typeStr.contains('vitamin')) mType = MedicineType.vitamin;

          final instructionParts = [
            med['instructions'], med['frequency'], med['duration']
          ].where((e) => e != null && e.toString().trim().isNotEmpty).toList();

          final instruction = instructionParts.join(' - ');
          final strength = (med['strength'] ?? '').toString().trim();
          final drugName = (med['drug_name'] ?? 'Unknown Medicine').toString().trim();

          parsedMedicines.add(Medicine(
            name: strength.isNotEmpty ? '$drugName $strength' : drugName,
            type: mType,
            instruction: instruction.isEmpty ? 'As directed by doctor' : instruction,
            quantity: (med['quantity'] ?? 'Qty as prescribed').toString(),
          ));
        }

        final String medicalHistory = (data['diagnosis_notes'] ?? '').toString();
        final String confidence = (data['confidence'] ?? 'high').toString();

        return {
          'medicines': parsedMedicines,
          'rawMedications': medsList,  // Keep raw data for pharmacy search
          'medicalHistory': medicalHistory,
          'confidence': confidence,
          'success': true,
        };
      } else {
        // Try to parse error detail from response
        String errorMsg = 'Server error (${streamedResponse.statusCode})';
        try {
          final errJson = jsonDecode(respStr);
          errorMsg = errJson['detail'] ?? errorMsg;
        } catch (_) {}
        return {'success': false, 'error': errorMsg};
      }
    } on SocketException {
      return {'success': false, 'error': 'Cannot connect to server. Please ensure the backend is running.'};
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
      debugPrint('ApiService: searching pharmacies at $_baseUrl/pharmacy/search-by-prescription');

      // Build medication list for the API
      final medList = medications.map((med) {
        if (med == null) return null;
        return {
          'drug_name': (med['drug_name'] ?? '').toString(),
          'quantity': (med['quantity'] ?? '1').toString(),
          'strength': (med['strength'] ?? '').toString(),
          'dosage_form': (med['dosage_form'] ?? '').toString(),
        };
      }).where((m) => m != null).toList();

      final response = await http.post(
        Uri.parse('$_baseUrl/pharmacy/search-by-prescription'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'latitude': latitude,
          'longitude': longitude,
          'medications': medList,
          'radius_meters': radiusMeters,
        }),
      ).timeout(const Duration(seconds: 30));

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
      return {'success': false, 'error': 'Pharmacy search failed: ${e.toString()}'};
    }
  }
}
