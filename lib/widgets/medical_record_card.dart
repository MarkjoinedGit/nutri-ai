import 'package:flutter/material.dart';
import '../models/medical_record_model.dart';

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
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                  tooltip: 'Edit Record',
                ),
              ],
            ),
            const Divider(),
            _buildInfoRow('Age', record.age),
            _buildInfoRow('Gender', record.gender),
            _buildInfoRow('Admission Date', record.admissionDatetime),
            _buildInfoRow('Reason', record.reasonForAdmission),
            _buildInfoRow('Preliminary Diagnosis', record.preliminaryDiagnosis),
            _buildInfoRow('Confirmed Diagnosis', record.confirmedDiagnosis),
            _buildInfoRow('Treatment Plan', record.treatmentPlan),
          ],
        ),
      ),
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
