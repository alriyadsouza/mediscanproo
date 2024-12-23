import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class MedicationReminderPage extends StatefulWidget {
  final String initialMedicineName;
  MedicationReminderPage({this.initialMedicineName = ""});
  @override
  _MedicationReminderPageState createState() => _MedicationReminderPageState();
}

class _MedicationReminderPageState extends State<MedicationReminderPage> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  List<Map<String, String>> medications = [];
  final TextEditingController _medicationController = TextEditingController();
  final TextEditingController _doseController = TextEditingController();
  TimeOfDay selectedTime = TimeOfDay.now();
  List<Day> selectedDays = [];

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  void _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('app_icon');

    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    if (Theme.of(context).platform == TargetPlatform.android) {
      final bool? granted =
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
          ?.requestPermission();

      if (granted == false) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Notification permission denied. Enable it in settings.")),
        );
      }
    }
  }

  Future<void> _scheduleNotification(
      String title, String body, TimeOfDay time, List<Day> days) async {
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'med_alert',
      'Medication Alerts',
      channelDescription: 'Medication reminder notifications',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
    );

    final NotificationDetails notificationDetails =
    NotificationDetails(android: androidDetails);

    // Schedule notifications for each selected day
    for (var day in days) {
      final now = DateTime.now();
      final dayOffset = (day.code == 'Everyday') ? 0 : (day.code == 'Mon' ? 1 : 2); // Adjust for specific day (Mon-Sun) logic
      final notificationTime = DateTime(now.year, now.month, now.day + dayOffset, time.hour, time.minute);

      await flutterLocalNotificationsPlugin.schedule(
        0,
        title,
        body,
        notificationTime,
        notificationDetails,
        androidAllowWhileIdle: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MedAlert'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _medicationController,
              decoration: InputDecoration(labelText: 'Enter Medication Name'),
            ),
            TextField(
              controller: _doseController,
              decoration: InputDecoration(labelText: 'Enter Dose'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                final TimeOfDay? picked = await showTimePicker(
                  context: context,
                  initialTime: selectedTime,
                );

                if (picked != null) {
                  setState(() {
                    selectedTime = picked;
                  });

                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Select Days'),
                        content: MultiSelectDays(
                          selectedDays: selectedDays,
                          onSelectionChanged: (List<Day> days) {
                            setState(() {
                              selectedDays = days;
                            });
                          },
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              medications.add({
                                'name': _medicationController.text,
                                'dose': _doseController.text,
                                'time': selectedTime.format(context),
                                'days': selectedDays
                                    .map((day) => day.name)
                                    .join(', '),
                              });

                              // Schedule notifications for each selected day
                              _scheduleNotification(
                                'Medication Reminder',
                                'Time to take ${_medicationController.text}',
                                selectedTime,
                                selectedDays,
                              );

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      "Reminder set for ${_medicationController.text} at ${selectedTime.format(context)} on ${selectedDays.map((e) => e.name).join(', ')}"),
                                ),
                              );
                            },
                            child: Text('Set Reminder'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: Text('Set Reminder'),
            ),
            SizedBox(height: 20),
            // Display list of added medications
            Expanded(
              child: ListView.builder(
                itemCount: medications.length,
                itemBuilder: (context, index) {
                  final medication = medications[index];
                  final String name = medication['name'] ?? 'No Name Provided'; // Handle null case
                  final String dose = medication['dose'] ?? 'Unknown'; // Handle null case
                  final String? time = medication['time'];

                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name.isNotEmpty ? name : 'No Name Provided',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "Dose: $dose",
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "Time: ${time != null ? time : 'Not Set'}",
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),


          ],
        ),
      ),
    );
  }
}

class MedicationCard extends StatelessWidget {
  final String name;
  final String dose;
  final String time;
  final String days;

  MedicationCard({
    required this.name,
    required this.dose,
    required this.time,
    required this.days,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(dose, style: TextStyle(color: Colors.grey)),
                Text(time, style: TextStyle(color: Colors.green)),
                Text('Days: $days', style: TextStyle(color: Colors.blue)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MultiSelectDays extends StatefulWidget {
  final List<Day> selectedDays;
  final ValueChanged<List<Day>> onSelectionChanged;

  MultiSelectDays({
    required this.selectedDays,
    required this.onSelectionChanged,
  });

  @override
  _MultiSelectDaysState createState() => _MultiSelectDaysState();
}

class _MultiSelectDaysState extends State<MultiSelectDays> {
  List<Day> days = [
    Day('Mon', 'Monday'),
    Day('Tue', 'Tuesday'),
    Day('Wed', 'Wednesday'),
    Day('Thu', 'Thursday'),
    Day('Fri', 'Friday'),
    Day('Sat', 'Saturday'),
    Day('Sun', 'Sunday'),
    Day('Everyday', 'Everyday'),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: days.map((day) {
          return CheckboxListTile(
            title: Text(day.name),
            value: widget.selectedDays.contains(day),
            onChanged: (bool? selected) {
              setState(() {
                if (selected == true) {
                  widget.selectedDays.add(day);
                } else {
                  widget.selectedDays.remove(day);
                }
              });
              widget.onSelectionChanged(widget.selectedDays);
            },
          );
        }).toList(),
      ),
    );
  }
}

class Day {
  final String code;
  final String name;

  Day(this.code, this.name);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          (other is Day && runtimeType == other.runtimeType && code == other.code);

  @override
  int get hashCode => code.hashCode;
}
