import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/user_provider.dart';
import '../providers/medical_record_provider.dart';
import '../models/medical_record_model.dart';
import '../widgets/medical_record_card.dart';
import '../widgets/edit_medical_record_dialog.dart';

class HealthMonitoringScreen extends StatefulWidget {
  const HealthMonitoringScreen({super.key});

  @override
  State<HealthMonitoringScreen> createState() => _HealthMonitoringScreenState();
}

class _HealthMonitoringScreenState extends State<HealthMonitoringScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
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
        throw Exception('User not logged in');
      }

      final recordProvider = Provider.of<MedicalRecordProvider>(
        context,
        listen: false,
      );
      await recordProvider.fetchRecords(userId);

      if (mounted) {
        setState(() {}); // Ensure UI updates only if the widget is still mounted
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _uploadMedicalRecord() async {
    if (_selectedImage == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an image first')),
        );
      }
      return;
    }

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userId = userProvider.currentUser?.id;

      if (userId == null) {
        throw Exception('User not logged in');
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _selectedImage = null;
        });
      }
    }
  }

  void _showConfirmationDialog(MedicalRecord record) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Medical Record Processed'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Patient Name: ${record.patientName}'),
              Text('Age: ${record.age}'),
              Text('Gender: ${record.gender}'),
              Text('Admission Date: ${record.admissionDatetime}'),
              Text('Reason: ${record.reasonForAdmission}'),
              Text('Preliminary Diagnosis: ${record.preliminaryDiagnosis}'),
              Text('Confirmed Diagnosis: ${record.confirmedDiagnosis}'),
              Text('Treatment Plan: ${record.treatmentPlan}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showEditDialog(record);
            },
            child: const Text('Edit'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              final recordProvider = Provider.of<MedicalRecordProvider>(
                context,
                listen: false,
              );
              recordProvider.addRecord(record);
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(MedicalRecord record) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => EditMedicalRecordDialog(
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Medical record updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MedicalRecordProvider>(
      builder: (context, recordProvider, _) {
        final isLoading = recordProvider.isLoading;
        final records = recordProvider.records;
        final error = recordProvider.error;

        if (error != null && mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: $error')),
            );
          });
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Health Monitoring',
              style: TextStyle(color: Colors.black87),
            ),
            backgroundColor: Colors.white,
            elevation: 0.5,
            iconTheme: const IconThemeData(color: Colors.black87),
          ),
          body: isLoading && records.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Your Medical Records',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    Expanded(
                      child: records.isEmpty
                          ? const Center(
                              child: Text(
                                'No medical records found. Upload your first medical record.',
                                textAlign: TextAlign.center,
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: records.length,
                              itemBuilder: (context, index) {
                                return MedicalRecordCard(
                                  record: records[index],
                                  onEdit: () =>
                                      _showEditDialog(records[index]),
                                );
                              },
                            ),
                    ),
                  ],
                ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: isLoading
                ? null
                : () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => SafeArea(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: const Icon(Icons.camera_alt),
                              title: const Text('Take a photo'),
                              onTap: () {
                                Navigator.pop(context);
                                _pickImage(ImageSource.camera);
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.photo_library),
                              title: const Text('Choose from gallery'),
                              onTap: () {
                                Navigator.pop(context);
                                _pickImage(ImageSource.gallery);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
            label: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text('Upload Medical Record'),
            icon: isLoading ? Container() : const Icon(Icons.add),
            backgroundColor: customOrange,
          ),
        );
      },
    );
  }
}