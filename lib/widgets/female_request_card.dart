import 'package:flutter/material.dart';
import 'package:sehha_app/core/models/booking_appointment_model.dart';
import 'package:sehha_app/core/models/client_model.dart';
import 'package:sehha_app/core/utils/app_colors.dart';
import 'package:sehha_app/widgets/info_row.dart';

class FemaleRequestCard extends StatelessWidget {
  final ClientModel patient;
  final BookingAppointmentModel booking;
  final Color statusColor;
  final VoidCallback onStatusTap;
  final VoidCallback onDeleteTap;
  final VoidCallback onMessageTap;

  const FemaleRequestCard({
    super.key,
    required this.patient,
    required this.booking,
    required this.statusColor,
    required this.onStatusTap,
    required this.onDeleteTap,
    required this.onMessageTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [FemaleAppColors.primaryColor, FemaleAppColors.accentColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.white.withAlpha(25),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    margin: const EdgeInsets.all(12),
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      image: DecorationImage(
                        image: NetworkImage(
                          patient.profileImage.isNotEmpty
                              ? patient.profileImage
                              : 'https://via.placeholder.com/150',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 5,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                          InfoRow(icon: Icons.phone, text: patient.phoneNumber),
                          const SizedBox(height: 6),
                          InfoRow(
                            icon: Icons.calendar_today,
                            text: booking.date,
                          ),
                          const SizedBox(height: 6),
                          InfoRow(
                            icon: Icons.access_time,
                            text: 'دور: ${booking.turnNumber}',
                          ),
                          const SizedBox(height: 6),
                          InfoRow(
                            icon: Icons.notes,
                            text: booking.description,
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(color: Colors.white54, height: 1),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: onStatusTap,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        alignment: Alignment.center,
                        color: Colors.white.withAlpha(25),
                        child: Text(
                          booking.status,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: onDeleteTap,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        alignment: Alignment.center,
                        color: const Color(0xFF618CDC).withAlpha(50),
                        child: const Text(
                          'حذف',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: onMessageTap,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        alignment: Alignment.center,
                        color: Colors.orangeAccent.withAlpha(50),
                        child: const Icon(Icons.message, color: Colors.white),
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
  }
}
