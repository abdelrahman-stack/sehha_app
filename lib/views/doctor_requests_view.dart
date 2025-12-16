import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:sehha_app/core/tools/app_localizations%20.dart';
import 'package:sehha_app/core/utils/app_colors.dart';
import 'package:sehha_app/models/booking_appointment_model.dart';
import 'package:sehha_app/models/patient_model.dart';
import 'package:sehha_app/widgets/lottie_loading_Indicator.dart';

class DoctorRequestView extends StatefulWidget {
  const DoctorRequestView({super.key});

  @override
  State<DoctorRequestView> createState() => _DoctorRequestViewState();
}

class _DoctorRequestViewState extends State<DoctorRequestView> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final DatabaseReference requestDatabase = FirebaseDatabase.instance
      .ref()
      .child('Requests');

  List<BookingAppointmentModel> requests = [];
  bool isLoading = true;
  String filterStatus = 'All';

  @override
  void initState() {
    super.initState();
    fetchBookingRequests();

    // Listen for real-time updates
    requestDatabase.onValue.listen((event) {
      fetchBookingRequests();
    });
  }

  Future<void> fetchBookingRequests() async {
    String? currentUserId = auth.currentUser?.uid;

    if (currentUserId != null) {
      setState(() {
        isLoading = true;
        requests.clear();
      });

      final snapshot = await requestDatabase
          .orderByChild('reciver')
          .equalTo(currentUserId)
          .once();

      if (snapshot.snapshot.value != null) {
        Map<dynamic, dynamic> bookingMap =
            snapshot.snapshot.value as Map<dynamic, dynamic>;
        bookingMap.forEach((key, value) {
          requests.add(
            BookingAppointmentModel.fromMap(Map<String, dynamic>.from(value)),
          );
        });
      }

      setState(() {
        isLoading = false;
      });
    }
  }

  Future<PatientModel> fetchPatient(String patientId) async {
    final snapshot = await FirebaseDatabase.instance
        .ref('Patients/$patientId')
        .get();
    if (snapshot.exists && snapshot.value != null) {
      return PatientModel.fromMap(
        Map<String, dynamic>.from(snapshot.value as Map),
      );
    } else {
      return PatientModel(
        phoneNumber: '',
        address: '',
        isOnline: false,
        lastSeen: DateTime.now().millisecondsSinceEpoch,
        lastMessage: '',
        lastMessageTime: DateTime.now().millisecondsSinceEpoch,
        unreadMessages: 0,
        latitude: 0.0,
        longitude: 0.0,

        uid: patientId,
        firstName: 'Unknown',
        lastName: '',
        email: '',
        profileImage: '',
      );
    }
  }

  Future<void> updateRequestStatus(String id, String status) async {
    await requestDatabase.child(id).update({'status': status});
  }

  Future<void> deleteRequest(String id) async {
    await requestDatabase.child(id).remove();
  }

  void showStatusDialog(String id, String status) {
    List<String> statuses = ['Accepted', 'Rejected', 'Completed'];
    String selectedStatus = status;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Update Status'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: statuses.map((s) {
                  return RadioListTile(
                    title: Text(s),
                    value: s,
                    groupValue: selectedStatus,
                    onChanged: (value) {
                      setState(() {
                        selectedStatus = value!;
                      });
                    },
                  );
                }).toList(),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    await updateRequestStatus(id, selectedStatus);
                    Navigator.pop(context);
                  },
                  child: const Text('Update'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'Accepted':
        return Colors.green;
      case 'Rejected':
        return Colors.red;
      case 'Completed':
        return Colors.blue;
      case 'Pending':
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context);
    List<BookingAppointmentModel> filteredRequests = filterStatus == 'All'
        ? requests
        : requests
              .where(
                (r) => r.status.toLowerCase() == filterStatus.toLowerCase(),
              )
              .toList();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          local.translate('doctor_requests'),
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: AppColors.scondaryColor,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                filterStatus = value;
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'All', child: Text(local.translate('all'))),
              PopupMenuItem(
                value: 'Pending',
                child: Text(local.translate('pending')),
              ),
              PopupMenuItem(
                value: 'Accepted',
                child: Text(local.translate('accepted')),
              ),
              PopupMenuItem(
                value: 'Rejected',
                child: Text(local.translate('rejected')),
              ),
              PopupMenuItem(
                value: 'Completed',
                child: Text(local.translate('completed')),
              ),
            ],
            icon: const Icon(Icons.filter_list, color: Colors.white),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CustomCircularProgressIndicator())
          : filteredRequests.isEmpty
          ? Center(child: Text(local.translate('no_requests_found')))
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: filteredRequests.length,
              itemBuilder: (context, index) {
                final booking = filteredRequests[index];
                final statusColor = getStatusColor(booking.status);

                return FutureBuilder<PatientModel>(
                  future: fetchPatient(booking.sender),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return ListTile(title: Text(local.translate('loading')));
                    }
                    final patient = snapshot.data!;
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.lightBlue,
                            AppColors.scondaryColor,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Material(
                          color: Colors.white.withValues(alpha: 0.15),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  // Profile Picture
                                  Container(
                                    margin: const EdgeInsets.all(12),
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 3,
                                      ),
                                      image: DecorationImage(
                                        image: NetworkImage(
                                          patient.profileImage,
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  // Details
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 15,
                                        horizontal: 5,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${patient.firstName} ${patient.lastName}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            '${patient.email}\n${booking.date} • ${booking.time}',
                                            style: TextStyle(
                                              color: Colors.white.withValues(
                                                alpha: 0.9,
                                              ),
                                              fontSize: 15,
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            booking.description,
                                            style: TextStyle(
                                              color: Colors.white.withValues(
                                                alpha: 0.9,
                                              ),
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(color: Colors.white54, height: 1),
                              // Actions: Status & Delete
                              Row(
                                children: [
                                  Expanded(
                                    child: InkWell(
                                      onTap: () => showStatusDialog(
                                        booking.id,
                                        booking.status,
                                      ),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        alignment: Alignment.center,
                                        color: Colors.white.withValues(
                                          alpha: .1,
                                        ),
                                        child: Text(
                                          booking.status,
                                          style: TextStyle(
                                            color: getStatusColor(
                                              booking.status,
                                            ),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: InkWell(
                                      onTap: () => showDeleteDialog(booking.id),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        alignment: Alignment.center,
                                        color: const Color.fromARGB(
                                          255,
                                          133,
                                          200,
                                          223,
                                        ),
                                        child: Text(
                                          local.translate('delete'),
                                          style: const TextStyle(
                                            color: Colors.redAccent,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  void showDeleteDialog(String requestId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Request'),
          content: const Text('Are you sure you want to delete this request?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await requestDatabase.child(requestId).remove();

                setState(() {
                  requests.removeWhere((booking) => booking.id == requestId);
                });
                Navigator.pop(context);
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
        );
      },
    );
  }
}
