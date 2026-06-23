// ignore_for_file: use_build_context_synchronously



import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddVehicleForm extends StatefulWidget {
  const AddVehicleForm({super.key});

  @override
  State<AddVehicleForm> createState() => _AddVehicleFormState();
}

class _AddVehicleFormState extends State<AddVehicleForm>
    with SingleTickerProviderStateMixin {
  int _currentStep = 0;
  bool _isActive = true;
  final picker = ImagePicker();
  List<XFile> vehicleImages = [];

  final nameCtrl = TextEditingController();
  final modelCtrl = TextEditingController();
  final typeCtrl = TextEditingController();
  final numberCtrl = TextEditingController();
  final rentHourCtrl = TextEditingController();
  final rentDayCtrl = TextEditingController();
  final descCtrl = TextEditingController();

  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
              color: Colors.black26.withValues(alpha:0.1),
              blurRadius: 20,
              spreadRadius: 3)
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            const SizedBox(height: 10),
            Flexible(child: _getStepContent()),
            const SizedBox(height: 20),
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Row(
          children: [
            Icon(Icons.directions_car, color: Colors.blue),
            SizedBox(width: 8),
            Text("Add New Vehicle",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _getStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildVehicleDetails();
      case 1:
        return _buildUploadPhotos();
      case 2:
        return _buildUploadDocs();
      default:
        return const SizedBox();
    }
  }

  Widget _buildVehicleDetails() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _inputField("Vehicle Name", "e.g., Maruti Swift Dzire", nameCtrl),
          _inputField("Model & Year", "e.g., 2022 Model", modelCtrl),
          _inputField("Vehicle Type", "e.g., SUV, Sedan, Hatchback", typeCtrl),
          _inputField("Vehicle Number", "e.g., DL 01 AB 1234", numberCtrl),
          Row(
            children: [
              Expanded(child: _inputField("Rent/Hour (â‚¹)", "100", rentHourCtrl)),
              const SizedBox(width: 10),
              Expanded(child: _inputField("Rent/Day (â‚¹)", "1500", rentDayCtrl)),
            ],
          ),
          _inputField("Description", "Brief vehicle description", descCtrl,
              maxLines: 3),
          SwitchListTile(
            title: const Text("Make vehicle active"),
            value: _isActive,
            onChanged: (val) => setState(() => _isActive = val),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadPhotos() {
    return Column(
      children: [
        GestureDetector(
          onTap: _pickImages,
          child: const DottedBorderContainer(
            icon: Icons.camera_alt_outlined,
            title: "Click to upload photos",
            subtitle: "Upload multiple photos of your vehicle",
          ),
        ),
        const SizedBox(height: 10),
        if (vehicleImages.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: vehicleImages.map((img) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(File(img.path),
                    height: 80, width: 80, fit: BoxFit.cover),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildUploadDocs() {
    return Column(
      children: [
        _docUploadCard("RC (Registration Certificate)"),
        _docUploadCard("Insurance"),
        _docUploadCard("Permit"),
      ],
    );
  }

  Widget _docUploadCard(String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 15)),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.upload, size: 16),
            label: const Text("Upload"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputField(String label, String hint, TextEditingController ctrl,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: ctrl,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (_currentStep != 0)
          OutlinedButton(
            onPressed: _previousStep,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              side: const BorderSide(color: Colors.grey),
              splashFactory: NoSplash.splashFactory,
              overlayColor: Colors.transparent,
            ),
            child: const Text("Previous"),
          ),
        ElevatedButton(
          onPressed: _isSaving ? null : _nextStep,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            splashFactory: NoSplash.splashFactory,
            overlayColor: Colors.transparent,
          ),
          child: _isSaving
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : Text(_currentStep == 2 ? "Add Vehicle" : "Next"),
        ),
      ],
    );
  }

  void _nextStep() async {
    if (_currentStep < 2) {
      setState(() => _currentStep++);
    } else {
      await _saveVehicleToFirestore();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) setState(() => _currentStep--);
  }

  Future<void> _pickImages() async {
    final pickedFiles = await picker.pickMultiImage();
    setState(() => vehicleImages = pickedFiles);
  }

  Future<void> _saveVehicleToFirestore() async {
    final vehicleName = nameCtrl.text.trim();
    if (vehicleName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter vehicle name")),
      );
      return;
    }

    try {
      setState(() => _isSaving = true);

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("User not logged in");
      }

      // Use email as parent document id; fallback to UID if email is null
      final parentDocId = (user.email?.trim().isNotEmpty ?? false) ? user.email!.trim() : user.uid;

      final firestore = FirebaseFirestore.instance;

      // Path: /Rental Driver/{parentDocId}/vehicle/{vehicleName}
      final vehicleDocRef = firestore
          .collection('Rental Driver')
          .doc(parentDocId)
          .collection('vehicle')
          .doc(vehicleName);

      final vehicleData = {
        'vehicleName': vehicleName,
        'model': modelCtrl.text.trim(),
        'type': typeCtrl.text.trim(),
        'vehicleNumber': numberCtrl.text.trim(),
        'rentPerHour': rentHourCtrl.text.trim(),
        'rentPerDay': rentDayCtrl.text.trim(),
        'description': descCtrl.text.trim(),
        'isActive': _isActive?'Active':'InActive',
        'createdAt': FieldValue.serverTimestamp(),
        'imagePaths': vehicleImages.map((e) => e.path).toList(),
        'addedByEmail': user.email ?? '',
        'addedByUid': user.uid,
      };

      await vehicleDocRef.set(vehicleData);

      setState(() => _isSaving = false);

      // Show success popup (preserves your existing UI behavior)
      _showSuccessPopup(context);
    } catch (e) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving vehicle: $e")),
      );
    }
  }

  void _showSuccessPopup(BuildContext context) {
    if (!mounted) return;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) {
        return const SizedBox();
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return Transform.scale(
          scale: Curves.easeOutBack.transform(anim1.value),
          child: Opacity(
            opacity: anim1.value,
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12.withValues(alpha:0.18),
                      blurRadius: 40,
                      spreadRadius: 6,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            Colors.green.shade400,
                            Colors.greenAccent.shade100
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withValues(alpha:0.18),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.check_circle_rounded,
                          color: Colors.white,
                          size: 60,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "Vehicle Added!",
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Your vehicle is now available for booking.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 16,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha:0.09),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.directions_car,
                              color: Colors.green, size: 22),
                          SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              "Ready for your next ride!",
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                color: Colors.green,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          splashFactory: NoSplash.splashFactory,
                          overlayColor: Colors.transparent,
                          elevation: 0,
                          textStyle: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w600,
                            fontSize: 17,
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context, rootNavigator: true).pop();
                          if (Navigator.of(context).canPop()) {
                            Navigator.of(context).pop();
                          }
                        },
                        child: const Text("Got it"),
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
}

class DottedBorderContainer extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const DottedBorderContainer({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: Colors.blueAccent.withValues(alpha:0.4), width: 1.5),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.blue, size: 36),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
            Text(subtitle,
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
