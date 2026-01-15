import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime selectedDate = DateTime(2025, 10, 6);
  DateTime currentMonth = DateTime(2025, 10);

  final Map<String, Map<String, dynamic>> events = {
    "2025-10-11": {
      "title": "Taj Mahal Tour",
      "location": "Agra",
      "time": "6:00 AM",
      "tourists": "4 tourists",
      "color": Colors.deepPurple,
    },
    "2025-10-13": {
      "title": "Delhi Heritage Walk",
      "location": "Old Delhi",
      "time": "10:00 AM",
      "tourists": "5 tourists",
      "color": Colors.green,
    },
    "2025-10-16": {
      "title": "Kerala Backwaters",
      "location": "Kerala",
      "time": "8:00 AM",
      "tourists": "3 tourists",
      "color": Colors.orange,
    },
  };

  void _changeMonth(int offset) {
    setState(() {
      currentMonth = DateTime(currentMonth.year, currentMonth.month + offset);
    });
  }

  List<DateTime> _getDaysInMonth(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);
    return List.generate(lastDay.day, (index) => DateTime(month.year, month.month, index + 1));
  }

  @override
  Widget build(BuildContext context) {
    final monthDays = _getDaysInMonth(currentMonth);
    final selectedKey = DateFormat('yyyy-MM-dd').format(selectedDate);
    final event = events[selectedKey];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Calendar", style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18), onPressed: () => _changeMonth(-1)),
                Text(DateFormat.yMMMM().format(currentMonth),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                IconButton(icon: const Icon(Icons.arrow_forward_ios_rounded, size: 18), onPressed: () => _changeMonth(1)),
              ],
            ),

            const SizedBox(height: 8),

            // Calendar Grid
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.grey.shade100,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text("Sun"), Text("Mon"), Text("Tue"),
                      Text("Wed"), Text("Thu"), Text("Fri"), Text("Sat"),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: monthDays.map((date) {
                      bool isSelected = date.day == selectedDate.day &&
                          date.month == selectedDate.month;
                      return GestureDetector(
                        onTap: () => setState(() => selectedDate = date),
                        child: Container(
                          width: 36,
                          height: 36,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.deepPurple : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? Colors.deepPurple : Colors.grey.shade300,
                            ),
                          ),
                          child: Text(
                            '${date.day}',
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Text(
              "Events on ${DateFormat('MMMM d').format(selectedDate)}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),

            if (event != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: event["color"],
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: event["color"].withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(event["title"],
                        style: const TextStyle(
                            color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, color: Colors.white, size: 16),
                        const SizedBox(width: 6),
                        Text(event["location"], style: const TextStyle(color: Colors.white)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.access_time, color: Colors.white, size: 16),
                        const SizedBox(width: 6),
                        Text(event["time"], style: const TextStyle(color: Colors.white)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.group, color: Colors.white, size: 16),
                        const SizedBox(width: 6),
                        Text(event["tourists"], style: const TextStyle(color: Colors.white)),
                      ],
                    ),
                  ],
                ),
              )
            else
              const Padding(
                padding: EdgeInsets.only(top: 40),
                child: Center(
                  child: Text("No events for this date",
                      style: TextStyle(color: Colors.grey, fontSize: 15)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
