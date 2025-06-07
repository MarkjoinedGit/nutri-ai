import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/user_provider.dart';
import '../providers/medical_record_provider.dart';
import '../providers/localization_provider.dart';
import '../models/medical_record_model.dart';
import '../widgets/medical_record_card.dart';
import '../widgets/edit_medical_record_dialog.dart';
import '../widgets/processing_medical_record_dialog.dart';
import '../utils/app_strings.dart';

class HealthMonitoringScreen extends StatefulWidget {
  const HealthMonitoringScreen({super.key});

  @override
  State<HealthMonitoringScreen> createState() => _HealthMonitoringScreenState();
}

class _HealthMonitoringScreenState extends State<HealthMonitoringScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  bool _isProcessing = false;
  static const Color customOrange = Color(0xFFE07E02);

  @override
  void initState() {
    super.initState();
    _fetchMedicalRecords();
  }

  Future<void> _fetchMedicalRecords() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userId = userProvider.currentUser?.id;

      if (userId == null) {
        final localizationProvider = Provider.of<LocalizationProvider>(
          context,
          listen: false,
        );
        final strings = AppStrings.getStrings(
          localizationProvider.currentLanguage,
        );
        throw Exception(strings.userNotLoggedIn);
      }

      final recordProvider = Provider.of<MedicalRecordProvider>(
        context,
        listen: false,
      );
      await recordProvider.fetchRecords(userId);

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        if (mounted) {
          setState(() {
            _selectedImage = File(pickedFile.path);
          });
        }
        await _uploadMedicalRecord();
      }
    } catch (e) {
      if (mounted) {
        final localizationProvider = Provider.of<LocalizationProvider>(
          context,
          listen: false,
        );
        final strings = AppStrings.getStrings(
          localizationProvider.currentLanguage,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${strings.errorPickingImage}: ${e.toString()}'),
          ),
        );
      }
    }
  }

  Future<void> _uploadMedicalRecord() async {
    if (_selectedImage == null) {
      if (mounted) {
        final localizationProvider = Provider.of<LocalizationProvider>(
          context,
          listen: false,
        );
        final strings = AppStrings.getStrings(
          localizationProvider.currentLanguage,
        );
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(strings.pleaseSelectImageFirst)));
      }
      return;
    }

    try {
      setState(() {
        _isProcessing = true;
      });

      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userId = userProvider.currentUser?.id;

      if (userId == null) {
        final localizationProvider = Provider.of<LocalizationProvider>(
          context,
          listen: false,
        );
        final strings = AppStrings.getStrings(
          localizationProvider.currentLanguage,
        );
        throw Exception(strings.userNotLoggedIn);
      }

      final recordProvider = Provider.of<MedicalRecordProvider>(
        context,
        listen: false,
      );
      final newRecord = await recordProvider.uploadMedicalRecord(
        _selectedImage!,
        userId,
      );

      if (newRecord != null && mounted) {
        _showConfirmationDialog(newRecord);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _selectedImage = null;
          _isProcessing = false;
        });
      }
    }
  }

  void _showConfirmationDialog(MedicalRecord record) {
    if (!mounted) return;

    final localizationProvider = Provider.of<LocalizationProvider>(
      context,
      listen: false,
    );
    final strings = AppStrings.getStrings(localizationProvider.currentLanguage);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(strings.medicalRecordProcessed),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${strings.patientName}: ${record.patientName}'),
                  Text('${strings.age}: ${record.age}'),
                  Text('${strings.gender}: ${record.gender}'),
                  Text('${strings.admissionDate}: ${record.admissionDatetime}'),
                  Text('${strings.reason}: ${record.reasonForAdmission}'),
                  Text(
                    '${strings.preliminaryDiagnosis}: ${record.preliminaryDiagnosis}',
                  ),
                  Text(
                    '${strings.confirmedDiagnosis}: ${record.confirmedDiagnosis}',
                  ),
                  Text('${strings.treatmentPlan}: ${record.treatmentPlan}'),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _showEditDialog(record);
                },
                child: Text(strings.edit),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _fetchMedicalRecords();
                },
                child: Text(strings.confirm),
              ),
            ],
          ),
    );
  }

  void _showEditDialog(MedicalRecord record) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder:
          (context) => EditMedicalRecordDialog(
            record: record,
            onSave: (updatedRecord) async {
              Navigator.of(context).pop();
              await _updateMedicalRecord(updatedRecord);
            },
          ),
    );
  }

  Future<void> _updateMedicalRecord(MedicalRecord record) async {
    try {
      final recordProvider = Provider.of<MedicalRecordProvider>(
        context,
        listen: false,
      );
      final success = await recordProvider.updateMedicalRecord(record);

      if (success && mounted) {
        final localizationProvider = Provider.of<LocalizationProvider>(
          context,
          listen: false,
        );
        final strings = AppStrings.getStrings(
          localizationProvider.currentLanguage,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(strings.medicalRecordUpdatedSuccessfully)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  void _cancelProcessing() {
    if (mounted) {
      setState(() {
        _isProcessing = false;
        _selectedImage = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<MedicalRecordProvider, LocalizationProvider>(
      builder: (context, recordProvider, localizationProvider, _) {
        final strings = AppStrings.getStrings(
          localizationProvider.currentLanguage,
        );
        final isLoading = recordProvider.isLoading;
        final records = recordProvider.records;
        final error = recordProvider.error;

        if (error != null && mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Error: $error')));
          });
        }

        return Stack(
          children: [
            Scaffold(
              appBar: AppBar(
                title: Text(
                  strings.healthMonitoringInLine,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                backgroundColor: Colors.white,
                elevation: 0.5,
                iconTheme: const IconThemeData(color: Colors.black87),
              ),
              body:
                  isLoading && records.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : Column(
                        children: [
                          Expanded(
                            child:
                                records.isEmpty
                                    ? Center(
                                      child: Text(
                                        strings.noMedicalRecordsFound,
                                        textAlign: TextAlign.center,
                                      ),
                                    )
                                    : ListView.builder(
                                      padding: const EdgeInsets.all(16),
                                      itemCount: records.length,
                                      itemBuilder: (context, index) {
                                        return MedicalRecordCard(
                                          record: records[index],
                                          onEdit:
                                              () => _showEditDialog(
                                                records[index],
                                              ),
                                        );
                                      },
                                    ),
                          ),
                        ],
                      ),
              floatingActionButton:
                  _isProcessing
                      ? null
                      : FloatingActionButton.extended(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(20),
                              ),
                            ),
                            builder:
                                (context) => SafeArea(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 4,
                                        margin: const EdgeInsets.only(
                                          top: 12,
                                          bottom: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          borderRadius: BorderRadius.circular(
                                            2,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Text(
                                          strings.selectImageSource,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      ListTile(
                                        leading: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: customOrange.withValues(
                                              alpha: 0.1,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.camera_alt,
                                            color: customOrange,
                                          ),
                                        ),
                                        title: Text(strings.takeAPhoto),
                                        subtitle: Text(
                                          strings.captureWithCamera,
                                        ),
                                        onTap: () {
                                          Navigator.pop(context);
                                          _pickImage(ImageSource.camera);
                                        },
                                      ),
                                      ListTile(
                                        leading: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: customOrange.withValues(
                                              alpha: 0.1,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.photo_library,
                                            color: customOrange,
                                          ),
                                        ),
                                        title: Text(strings.chooseFromGallery),
                                        subtitle: Text(
                                          strings.selectFromPhotos,
                                        ),
                                        onTap: () {
                                          Navigator.pop(context);
                                          _pickImage(ImageSource.gallery);
                                        },
                                      ),
                                      const SizedBox(height: 16),
                                    ],
                                  ),
                                ),
                          );
                        },
                        label: Text(
                          strings.uploadMedicalRecord,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        icon: const Icon(Icons.add),
                        backgroundColor: customOrange,
                        foregroundColor: Colors.white,
                      ),
            ),
            ProcessingMedicalRecordDialog(
              isVisible: _isProcessing,
              onCancel: _cancelProcessing,
            ),
          ],
        );
      },
    );
  }
}
