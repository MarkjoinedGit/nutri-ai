class MedicalRecord {
  final String id;
  final String patientName;
  final String age;
  final String gender;
  final String admissionDatetime;
  final String reasonForAdmission;
  final String preliminaryDiagnosis;
  final String confirmedDiagnosis;
  final String treatmentPlan;
  final String userId;

  MedicalRecord({
    required this.id,
    required this.patientName,
    required this.age,
    required this.gender,
    required this.admissionDatetime,
    required this.reasonForAdmission,
    required this.preliminaryDiagnosis,
    required this.confirmedDiagnosis,
    required this.treatmentPlan,
    required this.userId,
  });

  factory MedicalRecord.fromJson(Map<String, dynamic> json) {
    return MedicalRecord(
      id: json['_id'] ?? '',
      patientName: json['patient_name'] ?? '',
      age: json['age'] ?? '',
      gender: json['gender'] ?? '',
      admissionDatetime: json['admission_datetime'] ?? '',
      reasonForAdmission: json['reason_for_admission'] ?? '',
      preliminaryDiagnosis: json['preliminary_diagnosis'] ?? '',
      confirmedDiagnosis: json['confirmed_diagnosis'] ?? '',
      treatmentPlan: json['treatment_plan'] ?? '',
      userId: json['user'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'patient_name': patientName,
      'age': age,
      'gender': gender,
      'admission_datetime': admissionDatetime,
      'reason_for_admission': reasonForAdmission,
      'preliminary_diagnosis': preliminaryDiagnosis,
      'confirmed_diagnosis': confirmedDiagnosis,
      'treatment_plan': treatmentPlan,
      'user': userId,
    };
  }

  MedicalRecord copyWith({
    String? patientName,
    String? age,
    String? gender,
    String? admissionDatetime,
    String? reasonForAdmission,
    String? preliminaryDiagnosis,
    String? confirmedDiagnosis,
    String? treatmentPlan,
  }) {
    return MedicalRecord(
      id: id,
      patientName: patientName ?? this.patientName,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      admissionDatetime: admissionDatetime ?? this.admissionDatetime,
      reasonForAdmission: reasonForAdmission ?? this.reasonForAdmission,
      preliminaryDiagnosis: preliminaryDiagnosis ?? this.preliminaryDiagnosis,
      confirmedDiagnosis: confirmedDiagnosis ?? this.confirmedDiagnosis,
      treatmentPlan: treatmentPlan ?? this.treatmentPlan,
      userId: userId,
    );
  }
}
