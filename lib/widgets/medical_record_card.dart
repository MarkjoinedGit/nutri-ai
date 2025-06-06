import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/medical_record_model.dart';
import '../providers/localization_provider.dart';
import '../utils/app_strings.dart';

class MedicalRecordCard extends StatelessWidget {
  final MedicalRecord record;
  final VoidCallback onEdit;
  static const Color customOrange = Color(0xFFE07E02);

  const MedicalRecordCard({
    super.key,
    required this.record,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<LocalizationProvider>(
      builder: (context, localizationProvider, child) {
        final strings = AppStrings.getStrings(
          localizationProvider.currentLanguage,
        );

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        record.patientName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: customOrange),
                      onPressed: onEdit,
                      tooltip: strings.editRecord,
                    ),
                  ],
                ),
                const Divider(),
                _buildInfoRow(strings.age, record.age),
                _buildInfoRow(strings.gender, record.gender),
                _buildInfoRow(strings.admissionDate, record.admissionDatetime),
                _buildInfoRow(strings.reason, record.reasonForAdmission),
                _buildInfoRow(
                  strings.preliminaryDiagnosis,
                  record.preliminaryDiagnosis,
                ),
                _buildInfoRow(
                  strings.confirmedDiagnosis,
                  record.confirmedDiagnosis,
                ),
                _buildInfoRow(strings.treatmentPlan, record.treatmentPlan),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
