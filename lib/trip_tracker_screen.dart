import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class TripTrackerScreen extends StatefulWidget {
  const TripTrackerScreen({super.key});

  @override
  State<TripTrackerScreen> createState() => _TripTrackerScreenState();
}

class _TripTrackerScreenState extends State<TripTrackerScreen> {
  int completedSteps = 2;

  final List<Map<String, dynamic>> checkpoints = [
    {
      "title": "Hotel Pickup",
      "time": "5:30 AM",
      "location": "Tourist Hotel",
      "status": "completed",
    },
    {
      "title": "Taj Mahal Entry Gate",
      "time": "6:15 AM",
      "location": "East Gate",
      "status": "completed",
    },
    {
      "title": "Main Tomb Visit",
      "time": "6:45 AM",
      "location": "Central Mausoleum",
      "status": "ongoing",
    },
    {
      "title": "Garden Photography",
      "time": "7:30 AM",
      "location": "Charbagh Garden",
      "status": "pending",
    },
    {
      "title": "Breakfast",
      "time": "8:15 AM",
      "location": "Local Restaurant",
      "status": "pending",
    },
    {
      "title": "Return to Hotel",
      "time": "9:00 AM",
      "location": "Tourist Hotel",
      "status": "pending",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Trip Tracker",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12, top: 10, bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: Text(
                "Ongoing",
                style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600),
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Trip Info Card
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF5C6BC0), Color(0xFF7E57C2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 26,
                    backgroundImage: AssetImage("lib/assets/avatar_female.jpg"),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Taj Mahal Sunrise Tour",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Text(
                          "Sarah Johnson",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: const [
                            Icon(Iconsax.clock, color: Colors.white, size: 14),
                            SizedBox(width: 4),
                            Text("5:30 AM",
                                style:
                                    TextStyle(color: Colors.white70, fontSize: 12)),
                            SizedBox(width: 12),
                            Icon(Iconsax.user, color: Colors.white, size: 14),
                            SizedBox(width: 4),
                            Text("1 Tourist",
                                style:
                                    TextStyle(color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple.shade200,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    onPressed: () {},
                    icon: const Icon(Iconsax.call, color: Colors.white),
                    label: const Text("Call", style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                    ),
                    onPressed: () {},
                    icon: const Icon(Iconsax.location, color: Color(0xFF7E57C2)),
                    label: const Text("Navigate",
                        style: TextStyle(color: Color(0xFF7E57C2))),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Progress Section
            const Text(
              "Trip Progress",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 6),
            LinearProgressIndicator(
              value: completedSteps / checkpoints.length,
              backgroundColor: Colors.grey.shade200,
              color: Colors.deepPurple,
              minHeight: 8,
              borderRadius: BorderRadius.circular(8),
            ),
            const SizedBox(height: 6),
            Text(
              "${(completedSteps / checkpoints.length * 100).toStringAsFixed(0)}% Complete",
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),

            const SizedBox(height: 20),

            const Text(
              "Checkpoints",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 12),

            // Checkpoint List
            ...checkpoints.asMap().entries.map((entry) {
              final index = entry.key + 1;
              final checkpoint = entry.value;
              final status = checkpoint["status"];

              Color borderColor;
              Color textColor;
              Widget? trailingWidget;

              if (status == "completed") {
                borderColor = Colors.green.shade200;
                textColor = Colors.green;
                trailingWidget = Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12)),
                  child: const Text(
                    "Completed",
                    style: TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  ),
                );
              } else if (status == "ongoing") {
                borderColor = Colors.deepPurple;
                textColor = Colors.deepPurple;
                trailingWidget = ElevatedButton(
                  onPressed: () {
                    setState(() {
                      completedSteps++;
                      checkpoint["status"] = "completed";
                      final next = checkpoints.firstWhere(
                        (c) => c["status"] == "pending",
                        orElse: () => {},
                      );
                      if (next.isNotEmpty) next["status"] = "ongoing";
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  ),
                  child: const Text(
                    "Mark as Complete",
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                );
              } else {
                borderColor = Colors.grey.shade300;
                textColor = Colors.grey;
                trailingWidget = null;
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 26,
                          height: 26,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: status == "completed"
                                ? Colors.green.shade50
                                : status == "ongoing"
                                    ? Colors.deepPurple.shade100
                                    : Colors.grey.shade200,
                            shape: BoxShape.circle,
                            border: Border.all(color: borderColor, width: 1.5),
                          ),
                          child: status == "completed"
                              ? const Icon(Iconsax.tick_circle,
                                  color: Colors.green, size: 16)
                              : Text(
                                  index.toString(),
                                  style: TextStyle(
                                      color: textColor,
                                      fontWeight: FontWeight.w600),
                                ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                checkpoint["title"],
                                style: TextStyle(
                                    color: textColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Iconsax.clock,
                                      size: 14, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(
                                    checkpoint["time"],
                                    style: const TextStyle(
                                        color: Colors.grey, fontSize: 13),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Iconsax.location,
                                      size: 14, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(
                                    checkpoint["location"],
                                    style: const TextStyle(
                                        color: Colors.grey, fontSize: 13),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (trailingWidget != null) ...[
                      const SizedBox(height: 10),
                      trailingWidget,
                    ],
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
