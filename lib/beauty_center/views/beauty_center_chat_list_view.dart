// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/material.dart';
// import 'package:sehha_app/core/utils/app_colors.dart';
// import '../../core/models/patient_model.dart';
// import '../../widgets/lottie_loading_Indicator.dart';
// import '../../core/utils/app_router.dart';
// import 'package:go_router/go_router.dart';

// class BeautyCenterChatListView extends StatefulWidget {
//   const BeautyCenterChatListView({super.key});

//   @override
//   State<BeautyCenterChatListView> createState() =>
//       BeautyCenterChatListViewState();
// }

// class BeautyCenterChatListViewState extends State<BeautyCenterChatListView> {
//   final FirebaseAuth auth = FirebaseAuth.instance;
//   final DatabaseReference chatListDB = FirebaseDatabase.instance.ref(
//     'chatList',
//   );
//   final DatabaseReference patientDB = FirebaseDatabase.instance.ref('Customers');

//   List<PatientModel> patients = [];
//   bool isLoading = true;
//   late String hairdresserId;

//   @override
//   void initState() {
//     super.initState();
//     final currentUser = auth.currentUser;
//     if (currentUser != null) {
//       hairdresserId = currentUser.uid;
//       fetchChatList();
//     } else {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   Future<void> fetchChatList() async {
//     try {
//       final DatabaseEvent event = await chatListDB.child(hairdresserId).once();
//       final snapshot = event.snapshot;

//       List<PatientModel> tempPatients = [];

//       if (snapshot.value != null) {
//         final Map<dynamic, dynamic> patientsMap =
//             snapshot.value as Map<dynamic, dynamic>;

//         for (var patientId in patientsMap.keys) {
//           final DatabaseEvent patientEvent = await patientDB
//               .child(patientId)
//               .once();
//           final patientSnapshot = patientEvent.snapshot;

//           if (patientSnapshot.value != null) {
//             final Map<dynamic, dynamic> patientMap =
//                 patientSnapshot.value as Map<dynamic, dynamic>;
//             tempPatients.add(
//               PatientModel.fromMap(Map<String, dynamic>.from(patientMap)),
//             );
//           }
//         }
//       }

//       setState(() {
//         patients = tempPatients;
//         isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         title: const Text('قائمة دردشة العملاء',
//             style: TextStyle(color: Colors.white)),
//         centerTitle: true,
//         backgroundColor: BeautyCenterAppColors.secondaryColor,
//       ),
//       body: isLoading
//           ? const Center(child: CustomCircularProgressIndicator())
//           : patients.isEmpty
//           ? const Center(child: Text('لا يوجد عملاء'))
//           : ListView.separated(
//               padding: const EdgeInsets.all(8),
//               itemCount: patients.length,
//               separatorBuilder: (_, __) => const SizedBox(height: 8),
//               itemBuilder: (context, index) {
//                 final patient = patients[index];
//                 return Card(
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                   elevation: 3,
//                   child: ListTile(
//                     leading: CircleAvatar(
//                       backgroundImage: NetworkImage(patient.profileImage),
//                     ),
//                     title: Text('${patient.firstName} ${patient.lastName}'),
//                     subtitle: Text(patient.email),
//                     trailing: const Icon(
//                       Icons.chat_bubble_outline,
//                       color: BeautyCenterAppColors.secondaryColor,
//                     ),
//                     onTap: () {
//                       final myId = FirebaseAuth.instance.currentUser!.uid;
//                       final otherUserId = patient.uid;
//                       final chatId = (myId.compareTo(otherUserId) < 0)
//                           ? "$myId-$otherUserId"
//                           : "$otherUserId-$myId";

//                       GoRouter.of(context).push(
//                         AppRouter.kChatView,
//                         extra: {
//                           'myId': myId,
//                           'otherUserId': otherUserId,
//                           'otherUserName': patient.firstName,
//                           'chatId': chatId,
//                         },
//                       );
//                     },
//                   ),
//                 );
//               },
//             ),
//     );
//   }
// }
