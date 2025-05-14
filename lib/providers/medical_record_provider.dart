import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/medical_record_model.dart';
import '../services/medical_record_service.dart';

class MedicalRecordProvider with ChangeNotifier {
  final MedicalRecordService _service = MedicalRecordService();
  List<MedicalRecord> _records = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<MedicalRecord> get records => _records;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Fetch medical records
  Future<void> fetchRecords(String userId) async {
    _setLoading(true);
    _clearError();

    try {
      final fetchedRecords = await _service.fetchMedicalRecords(userId);
      _records = fetchedRecords;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Upload a new medical record
  Future<MedicalRecord?> uploadMedicalRecord(File image, String userId) async {
    _setLoading(true);
    _clearError();

    try {
      final newRecord = await _service.uploadMedicalRecord(image, userId);
      return newRecord;
    } catch (e) {
      _setError(e.toString());
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Update an existing medical record
  Future<bool> updateMedicalRecord(MedicalRecord record) async {
    _setLoading(true);
    _clearError();

    try {
      final updatedRecord = await _service.updateMedicalRecord(record);
      
      // Update the record in the local list
      final index = _records.indexWhere((r) => r.id == updatedRecord.id);
      if (index != -1) {
        _records[index] = updatedRecord;
      } else {
        _records.add(updatedRecord);
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Add a record to the local list (without API call)
  void addRecord(MedicalRecord record) {
    _records.add(record);
    notifyListeners();
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String errorMessage) {
    _error = errorMessage;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}