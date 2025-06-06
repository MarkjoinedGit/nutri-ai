import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/medical_record_model.dart';
import '../providers/localization_provider.dart';
import '../utils/app_strings.dart';

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
    return Consumer<LocalizationProvider>(
      builder: (context, localizationProvider, child) {
        final strings = AppStrings.getStrings(
          localizationProvider.currentLanguage,
        );

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
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
                        Text(
                          strings.editMedicalRecord,
                          style: const TextStyle(
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
                      label: strings.patientName,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return strings.pleaseEnterPatientName;
                        }
                        return null;
                      },
                      strings: strings,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _ageController,
                            label: strings.age,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return strings.pleaseEnterAge;
                              }
                              return null;
                            },
                            strings: strings,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            controller: _genderController,
                            label: strings.gender,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return strings.pleaseEnterGender;
                              }
                              return null;
                            },
                            strings: strings,
                          ),
                        ),
                      ],
                    ),
                    _buildTextField(
                      controller: _admissionDateController,
                      label: strings.admissionDate,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return strings.pleaseEnterAdmissionDate;
                        }
                        return null;
                      },
                      strings: strings,
                    ),
                    _buildTextField(
                      controller: _reasonController,
                      label: strings.reasonForAdmission,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return strings.pleaseEnterReasonForAdmission;
                        }
                        return null;
                      },
                      strings: strings,
                    ),
                    _buildTextField(
                      controller: _preliminaryDiagnosisController,
                      label: strings.preliminaryDiagnosis,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return strings.pleaseEnterPreliminaryDiagnosis;
                        }
                        return null;
                      },
                      strings: strings,
                    ),
                    _buildTextField(
                      controller: _confirmedDiagnosisController,
                      label: strings.confirmedDiagnosis,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return strings.pleaseEnterConfirmedDiagnosis;
                        }
                        return null;
                      },
                      strings: strings,
                    ),
                    _buildTextField(
                      controller: _treatmentPlanController,
                      label: strings.treatmentPlan,
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return strings.pleaseEnterTreatmentPlan;
                        }
                        return null;
                      },
                      strings: strings,
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
                        child: Text(
                          strings.saveChanges,
                          style: const TextStyle(
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
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required dynamic strings,
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
