/*import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class PaymentBody extends StatelessWidget {
  const PaymentBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const SizedBox(height: 10),
          Text("Payments",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const Text("Track your earnings and transactions"),

          const SizedBox(height: 16),

          // Balance Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                colors: [Colors.green, Colors.blue],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Current Balance",
                    style: TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 8),
                const Text("₹24,580",
                    style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text("Available for withdrawal",
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.green),
                  onPressed: () {},
                  child: const Text("Withdraw Funds"),
                )
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Earnings Overview
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Earnings Overview",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ToggleButtons(
                  isSelected: const [true, false],
                  onPressed: (index) {},
                  children: const [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text("This Week"),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text("Monthly"),
                    )
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: BarChart(
                    BarChartData(
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              switch (value.toInt()) {
                                case 0: return const Text("Mon");
                                case 1: return const Text("Tue");
                                case 2: return const Text("Wed");
                                case 3: return const Text("Thu");
                                case 4: return const Text("Fri");
                                case 5: return const Text("Sat");
                                case 6: return const Text("Sun");
                              }
                              return const Text("");
                            },
                          ),
                        ),
                      ),
                      barGroups: [
                        BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 1400, color: Colors.green)]),
                        BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 1800, color: Colors.green)]),
                        BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 1500, color: Colors.green)]),
                        BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 2000, color: Colors.green)]),
                        BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 1700, color: Colors.green)]),
                        BarChartGroupData(x: 5, barRods: [BarChartRodData(toY: 2800, color: Colors.green)]),
                        BarChartGroupData(x: 6, barRods: [BarChartRodData(toY: 2100, color: Colors.green)]),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Align(
                    alignment: Alignment.bottomRight,
                    child: Text("Total this week ₹13,700",
                        style: TextStyle(fontWeight: FontWeight.bold)))
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Today’s Earnings + Total Trips
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _smallCard("Today's Earnings", "₹1,650", Icons.attach_money, Colors.green),
              _smallCard("Total Trips", "142", Icons.calendar_month, Colors.blue),
            ],
          ),

          const SizedBox(height: 20),

          // Payment History
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text("Payment History", style: TextStyle(fontWeight: FontWeight.bold)),
              Icon(Icons.download),
            ],
          ),
          const SizedBox(height: 10),
          _historyItem("Trip to IGI Airport", "Priya Sharma", "Today, 2:30 PM", "₹450", "Paid", Colors.green),
          _historyItem("8-hour car rental", "Amit Patel", "Today, 9:00 AM", "₹1,200", "Paid", Colors.green),
          _historyItem("Trip to Cyber City", "Rahul Kumar", "Yesterday, 6:15 PM", "₹320", "Pending", Colors.orange),
          _historyItem("Trip to Red Fort", "Sneha Gupta", "Yesterday, 12:30 PM", "₹150", "Paid", Colors.green),
          _historyItem("Bank transfer", "", "2 days ago", "-₹5,000", "Completed", Colors.blue),
        ],
      ),
    );
  }

  Widget _smallCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _historyItem(String title, String name, String time, String amount, String status, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.directions_car, color: Colors.red),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                if (name.isNotEmpty) Text(name),
                Text(time, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(status, style: TextStyle(color: color, fontSize: 12)),
            ],
          )
        ],
      ),
    );
  }
}*/


import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class PaymentBody extends StatelessWidget {
  const PaymentBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const SizedBox(height: 10),
          Text("Payments",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const Text("Track your earnings and transactions"),

          const SizedBox(height: 16),

          // Balance Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                colors: [Colors.green, Colors.blue],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Current Balance",
                    style: TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 8),
                const Text("₹24,580",
                    style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text("Available for withdrawal",
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.green),
                  onPressed: () {},
                  child: const Text("Withdraw Funds"),
                )
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Earnings Overview FULL WIDTH
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Earnings Overview",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ToggleButtons(
                  isSelected: const [true, false],
                  onPressed: (index) {},
                  children: const [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text("This Week"),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text("Monthly"),
                    )
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: BarChart(
                    BarChartData(
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              switch (value.toInt()) {
                                case 0: return const Text("Mon");
                                case 1: return const Text("Tue");
                                case 2: return const Text("Wed");
                                case 3: return const Text("Thu");
                                case 4: return const Text("Fri");
                                case 5: return const Text("Sat");
                                case 6: return const Text("Sun");
                              }
                              return const Text("");
                            },
                          ),
                        ),
                      ),
                      barGroups: [
                        BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 1400, color: Colors.green)]),
                        BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 1800, color: Colors.green)]),
                        BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 1500, color: Colors.green)]),
                        BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 2000, color: Colors.green)]),
                        BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 1700, color: Colors.green)]),
                        BarChartGroupData(x: 5, barRods: [BarChartRodData(toY: 2800, color: Colors.green)]),
                        BarChartGroupData(x: 6, barRods: [BarChartRodData(toY: 2100, color: Colors.green)]),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Align(
                    alignment: Alignment.bottomRight,
                    child: Text("Total this week ₹13,700",
                        style: TextStyle(fontWeight: FontWeight.bold)))
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Today’s Earnings + Total Trips
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _smallCard("Today's Earnings", "₹1,650", Icons.attach_money, Colors.green),
              _smallCard("Total Trips", "142", Icons.calendar_month, Colors.blue),
            ],
          ),

          const SizedBox(height: 20),

          // Payment History
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text("Payment History", style: TextStyle(fontWeight: FontWeight.bold)),
              Icon(Icons.download),
            ],
          ),
          const SizedBox(height: 10),

          // History Items
          _historyItem("Trip to IGI Airport", "Priya Sharma", "Today, 2:30 PM", "₹450", "Paid", Colors.green),
          _historyItem("8-hour car rental", "Amit Patel", "Today, 9:00 AM", "₹1,200", "Paid", Colors.green),
          _historyItem("Trip to Cyber City", "Rahul Kumar", "Yesterday, 6:15 PM", "₹320", "Pending", Colors.orange),
          _historyItem("Trip to Red Fort", "Sneha Gupta", "Yesterday, 12:30 PM", "₹150", "Paid", Colors.green),
         // _historyItem("Bank transfer", "", "2 days ago", "-₹5,000", "Completed", Colors.blue),
        ],
      ),
    );
  }

  Widget _smallCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _historyItem(
      String title, String name, String time, String amount, String status, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.directions_car, color: Colors.red),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    if (name.isNotEmpty) Text(name),
                    Text(time, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(amount, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(status, style: TextStyle(color: color, fontSize: 12)),
                ],
              )
            ],
          ),

          // Action buttons depending on status
          if (status == "Pending") ...[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _actionButton(Icons.call, "Call", Colors.blue),
                const SizedBox(width: 8),
                _actionButton(Icons.chat, "Chat", Colors.green),
                const SizedBox(width: 8),
                _actionButton(Icons.alarm, "Reminder", Colors.orange),
              ],
            )
          ] else if (status == "Paid") ...[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _actionButton(Icons.download, "Receipt", const Color.fromARGB(255, 116, 197, 247)),
              ],
            )
          ]
        ],
      ),
    );
  }

  Widget _actionButton(IconData icon, String label, Color color) {
    return ElevatedButton.icon(
      onPressed: () {},
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
       // backgroundColor: color.withOpacity(0.1),
       // foregroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(fontSize: 12),
      ),
    );
  }
}