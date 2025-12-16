import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sehha_app/core/tools/app_localizations%20.dart';
import 'package:sehha_app/core/utils/app_colors.dart';
import 'package:sehha_app/core/utils/app_router.dart';
import 'package:sehha_app/models/doctor_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:url_launcher/url_launcher.dart';

class DoctorDetailsView extends StatefulWidget {
  const DoctorDetailsView({super.key, required this.doctorModel});
  final DoctorModel doctorModel;

  @override
  State<DoctorDetailsView> createState() => _DoctorDetailsViewState();
}

class _DoctorDetailsViewState extends State<DoctorDetailsView>
    with SingleTickerProviderStateMixin {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final DatabaseReference database = FirebaseDatabase.instance.ref('Requests');
  TextEditingController descriptionController = TextEditingController();
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  late AnimationController _buttonController;
  late Animation<double> _buttonAnimation;

  @override
  void initState() {
    super.initState();
    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      lowerBound: 0.0,
      upperBound: 0.05,
    );
    _buttonAnimation =
        Tween<double>(begin: 1.0, end: 0.95).animate(_buttonController);
  }

  @override
  void dispose() {
    _buttonController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final gradient = const LinearGradient(
      colors: [AppColors.scondaryColor, Colors.lightBlueAccent],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(t.translate('doctor_details'),
            style: const TextStyle(color: Colors.white)),
        backgroundColor: AppColors.scondaryColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              context.pop();
            } else {
              GoRouter.of(context).pushReplacement('/DoctorListView');
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.shade100.withAlpha(50),
                    blurRadius: 15,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 12,
                            offset:  Offset(0, 6),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 55,
                        backgroundImage:
                            NetworkImage(widget.doctorModel.profileImage),
                        backgroundColor: Colors.grey.shade200,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${widget.doctorModel.firstName} ${widget.doctorModel.lastName}',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.doctorModel.category,
                      style: const TextStyle(fontSize: 18, color: Colors.white70),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildIconButton(
                          icon: Icons.phone,
                          color: Colors.greenAccent,
                          onPressed: () =>
                              makePhoneCall(widget.doctorModel.phoneNumber),
                        ),
                        const SizedBox(width: 24),
                        _buildIconButton(
                          icon: Icons.message,
                          color: Colors.orangeAccent,
                          onPressed: () {
                            final currentUser = auth.currentUser!;
                            final docName =
                                '${widget.doctorModel.firstName} ${widget.doctorModel.lastName}';
                            GoRouter.of(context).push(
                              AppRouter.kChatView,
                              extra: {
                                'doctorName': docName,
                                'doctorId': widget.doctorModel.uid,
                                'patientName': currentUser.displayName ??
                                    currentUser.email ??
                                    t.translate('user'),
                                'patientId': currentUser.uid,
                              },
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.location_on,
                            color: Colors.redAccent, size: 22),
                        const SizedBox(width: 4),
                        Text(
                          widget.doctorModel.address,
                          style: const TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            _animatedButton(
              label: t.translate('view_location_on_map'),
              icon: Icons.map_outlined,
              gradient: gradient,
              onPressed: openMap,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _animatedButton(
                    label: selectedDate == null
                        ? t.translate('select_date')
                        : DateFormat('dd/MM/yyyy').format(selectedDate!),
                    gradient: gradient,
                    onPressed: () => date(context),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _animatedButton(
                    label: selectedTime == null
                        ? t.translate('select_time')
                        : selectedTime!.format(context),
                    gradient: gradient,
                    onPressed: () => time(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: t.translate('enter_appointment_details'),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
            _animatedButton(
              label: t.translate('make_appointment'),
              gradient:
                 const  LinearGradient(colors: [AppColors.primaryColor, AppColors.scondaryColor]),
              onPressed: appointment,
            ),
          ],
        ),
      ),
    );
  }

  Widget _animatedButton({
    required String label,
    required VoidCallback onPressed,
    Gradient? gradient,
    IconData? icon,
  }) {
    return GestureDetector(
      onTapDown: (_) => _buttonController.forward(),
      onTapUp: (_) => _buttonController.reverse(),
      onTapCancel: () => _buttonController.reverse(),
      onTap: onPressed,
      child: AnimatedBuilder(
        animation: _buttonController,
        builder: (context, child) {
          double scale = 1 - _buttonController.value;
          return Transform.scale(
            scale: scale,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset:  Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: Colors.white),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(50),
      child: Ink(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: .2),
        ),
        padding: const EdgeInsets.all(12),
        child: Icon(icon, color: color, size: 28),
      ),
    );
  }

  Future<void> date(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null && mounted) {
      setState(() => selectedDate = pickedDate);
    }
  }

  Future<void> time(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null && mounted) {
      setState(() => selectedTime = pickedTime);
    }
  }

  Future<void> openMap() async {
    final lat = widget.doctorModel.latitude;
    final lng = widget.doctorModel.longitude;
    if (lat == 0 || lng == 0) return;

    final Uri googleMapUrl =
        Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');

    if (await canLaunchUrl(googleMapUrl)) {
      await launchUrl(googleMapUrl, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> makePhoneCall(String phoneNumber) async {
    final cleanNumber = phoneNumber.replaceAll(' ', '').replaceAll('-', '');
    final Uri phoneUri = Uri(scheme: 'tel', path: cleanNumber);

    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> appointment() async {
    if (selectedDate != null &&
        selectedTime != null &&
        descriptionController.text.isNotEmpty) {
      String date = DateFormat('dd/MM/yyyy').format(selectedDate!);
      String time = selectedTime!.format(context);
      String description = descriptionController.text;
      String requestId = database.push().key!;
      String currentUserId = auth.currentUser!.uid;

      final patientSnapshot = await FirebaseDatabase.instance
          .ref('Users/Patients/$currentUserId')
          .get();

      String currentUserName = auth.currentUser?.displayName ?? "Patient";
      String currentUserImage = "";

      if (patientSnapshot.exists) {
        final patientData = Map<String, dynamic>.from(
          patientSnapshot.value as Map,
        );
        currentUserName =
            '${patientData['firstName']} ${patientData['lastName']}';
        currentUserImage = patientData['profileImage'] ?? '';
      }

      String reciverId = widget.doctorModel.uid;

      database.child(requestId).set({
        'date': date,
        'time': time,
        'description': description,
        'id': requestId,
        'sender': currentUserId,
        'senderName': currentUserName,
        'senderImage': currentUserImage,
        'reciver': reciverId,
        'status': 'pending',
      }).then((_) {
        if (!mounted) return;
        setState(() {
          selectedDate = null;
          selectedTime = null;
          descriptionController.clear();
        });
        showCustomSnackBar(context, 'Request sent successfully!');
      });
    } else {
      showCustomSnackBar(context, 'Please fill all the fields', isError: true);
    }
  }

  void showCustomSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    final color = isError ? Colors.redAccent : Colors.green;
    final icon = isError ? Icons.error_outline : Icons.check_circle_outline;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
