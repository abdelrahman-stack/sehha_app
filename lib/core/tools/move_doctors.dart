import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final DatabaseReference patientsRef =
      FirebaseDatabase.instance.ref().child("Patients");
  final DatabaseReference doctorsRef =
      FirebaseDatabase.instance.ref().child("Doctors");

  final DataSnapshot snapshot = await patientsRef.get();

  if (snapshot.value != null) {
    final Map<dynamic, dynamic> patientsMap =
        snapshot.value as Map<dynamic, dynamic>;

    for (var patientId in patientsMap.keys) {
      final patientData = patientsMap[patientId];

    
      if (patientData["isDoctor"] == true) {
        await doctorsRef.child(patientId).set(patientData);
      
    
      }
    }
  }

  
}
