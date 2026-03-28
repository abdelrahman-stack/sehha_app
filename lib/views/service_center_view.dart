import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ServiceCenterView extends StatelessWidget {
  final List<Map<String, String>> centers = [
    {
      'name': 'مركز صيانة CURLY',
      'phone': '+201027658916',
      
    },
  
  ];

  ServiceCenterView({super.key});

  void callNumber(String number) async {
    final uri = Uri.parse('tel:$number');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'مراكز الصيانة',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.orange.shade500,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: centers.length,
        itemBuilder: (context, index) {
          final center = centers[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 6,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.orange.shade100,
                    child:  Icon(
                      Icons.support_agent,
                      color: Colors.orange.shade700,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          center['name']!,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () => callNumber(center['phone']!),
                          child: Row(
                            children: [
                              const Icon(Icons.phone, color: Colors.green),
                              const SizedBox(width: 8),
                              Text(
                                center['phone']!,
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
}
