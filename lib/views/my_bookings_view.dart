import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:sehha_app/core/tools/app_localizations%20.dart';
import 'package:sehha_app/core/utils/app_colors.dart';
import 'package:sehha_app/core/models/booking_appointment_model.dart';
import 'package:sehha_app/widgets/lottie_loading_Indicator.dart';

class MyBookingsView extends StatefulWidget {
  const MyBookingsView({super.key});

  @override
  State<MyBookingsView> createState() => _MyBookingsViewState();
}

class _MyBookingsViewState extends State<MyBookingsView> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final DatabaseReference requestDB = FirebaseDatabase.instance.ref('Requests');

  List<BookingAppointmentModel> myBookings = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMyBookings();
    // Listen to real-time updates
    requestDB.onValue.listen((event) {
      fetchMyBookings();
    });
  }

  Future<void> fetchMyBookings() async {
    final currentUserId = auth.currentUser?.uid;
    if (currentUserId == null) return;

    setState(() {
      isLoading = true;
      myBookings.clear();
    });

    final snapshot = await requestDB
        .orderByChild('sender')
        .equalTo(currentUserId)
        .once();

    if (snapshot.snapshot.value != null) {
      final data = Map<String, dynamic>.from(snapshot.snapshot.value as Map);
      data.forEach((key, value) {
        myBookings.add(
          BookingAppointmentModel.fromMap(Map<String, dynamic>.from(value)),
        );
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'completed':
        return Colors.blue;
      case 'انتظار الرد':
        return Colors.orange;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.secondaryColor,
        title: Text(
          local.translate('my_bookings'),
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CustomCircularProgressIndicator())
          : myBookings.isEmpty
          ? Center(child: Text(local.translate('no_bookings_found')))
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              itemCount: myBookings.length,
              itemBuilder: (context, index) {
                final booking = myBookings[index];

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 3,
                  child: ListTile(
                    title: Text('${booking.date} • ${booking.time}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(booking.description),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: getStatusColor(booking.status),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            booking.status,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () => showDeleteDialog(booking.id),
                    ),
                  ),
                );
              },
            ),
    );
  }

  void showDeleteDialog(String bookingId) {
    final local = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(local.translate('delete_booking')),
        content: Text(local.translate('delete_booking_confirmation')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(local.translate('cancel')),
          ),
          TextButton(
            onPressed: () async {
              await requestDB.child(bookingId).remove();
              Navigator.pop(context);

              await fetchMyBookings();
            },
            child: Text(
              local.translate('delete'),
              style: const TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }
}
