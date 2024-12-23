import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'MedicationReminderPage.dart';
import 'ReminderPage.dart';
import 'qr_view_screen.dart';
 // Add the import for the Medication Reminder page

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MediScanPro'),
        backgroundColor: Colors.teal,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Welcome to MediScan',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Your health companion for easy and efficient QR code scanning of your medical records.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () {
                  // Navigate to QR code scanner screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QRViewScreen(),
                    ),
                  );
                },
                icon: Icon(Icons.qr_code_scanner),
                label: Text('Scan QR Code'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.teal, padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  textStyle: TextStyle(fontSize: 18),
                ),
              ),
              SizedBox(height: 20),
              // New button to navigate to the medication reminder page
              ElevatedButton.icon(
                onPressed: () {
                  // Navigate to Medication Reminder Page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MedicationReminderPage(),
                    ),
                  );
                },
                icon: Icon(Icons.alarm_add),
                label: Text('Set Medication Reminder'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.teal, padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  textStyle: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
