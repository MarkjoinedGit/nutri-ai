import 'package:flutter/material.dart';
import '../models/medical_record_model.dart';

class EditMedicalRecordDialog extends StatefulWidget {
  final MedicalRecord record;
  final Function(MedicalRecord) onSave;

  const EditMedicalRecordDialog({
    super.key,
    required this.record,
    required this.onSave,
  });

  @override
  State<EditMedicalRecordDialog> createState() =>
      _EditMedicalRecordDialogState();
}

class _EditMedicalRecordDialogState extends State<EditMedicalRecordDialog> {
  late TextEditingController _patientNameController;
  late TextEditingController _ageController;
  late TextEditingController _genderController;
  late TextEditingController _admissionDateController;
  late TextEditingController _reasonController;
  late TextEditingController _preliminaryDiagnosisController;
  late TextEditingController _confirmedDiagnosisController;
  late TextEditingController _treatmentPlanController;

  final _formKey = GlobalKey<FormState>();
  static const Color customOrange = Color(0xFFE07E02);

  @override
  void initState() {
    super.initState();
    _patientNameController = TextEditingController(
      text: widget.record.patientName,
    );
    _ageController = TextEditingController(text: widget.record.age);
    _genderController = TextEditingController(text: widget.record.gender);
    _admissionDateController = TextEditingController(
      text: widget.record.admissionDatetime,
    );
    _reasonController = TextEditingController(
      text: widget.record.reasonForAdmission,
    );
    _preliminaryDiagnosisController = TextEditingController(
      text: widget.record.preliminaryDiagnosis,
    );
    _confirmedDiagnosisController = TextEditingController(
      text: widget.record.confirmedDiagnosis,
    );
    _treatmentPlanController = TextEditingController(
      text: widget.record.treatmentPlan,
    );
  }

  @override
  void dispose() {
    _patientNameController.dispose();
    _ageController.dispose();
    _genderController.dispose();
    _admissionDateController.dispose();
    _reasonController.dispose();
    _preliminaryDiagnosisController.dispose();
    _confirmedDiagnosisController.dispose();
    _treatmentPlanController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      final updatedRecord = widget.record.copyWith(
        patientName: _patientNameController.text,
        age: _ageController.text,
        gender: _genderController.text,
        admissionDatetime: _admissionDateController.text,
        reasonForAdmission: _reasonController.text,
        preliminaryDiagnosis: _preliminaryDiagnosisController.text,
        confirmedDiagnosis: _confirmedDiagnosisController.text,
        treatmentPlan: _treatmentPlanController.text,
      );

      widget.onSave(updatedRecord);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        constraints: const BoxConstraints(maxWidth: 500),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Edit Medical Record',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _patientNameController,
                  label: 'Patient Name',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter patient name';
                    }
                    return null;
                  },
                ),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _ageController,
                        label: 'Age',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter age';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        controller: _genderController,
                        label: 'Gender',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter gender';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                _buildTextField(
                  controller: _admissionDateController,
                  label: 'Admission Date',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter admission date';
                    }
                    return null;
                  },
                ),
                _buildTextField(
                  controller: _reasonController,
                  label: 'Reason for Admission',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter reason for admission';
                    }
                    return null;
                  },
                ),
                _buildTextField(
                  controller: _preliminaryDiagnosisController,
                  label: 'Preliminary Diagnosis',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter preliminary diagnosis';
                    }
                    return null;
                  },
                ),
                _buildTextField(
                  controller: _confirmedDiagnosisController,
                  label: 'Confirmed Diagnosis',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter confirmed diagnosis';
                    }
                    return null;
                  },
                ),
                _buildTextField(
                  controller: _treatmentPlanController,
                  label: 'Treatment Plan',
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter treatment plan';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: customOrange,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Save Changes',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        maxLines: maxLines,
        validator: validator,
      ),
    );
  }
}
