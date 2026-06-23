import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class PaymentHistoryScreen extends StatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  String selectedFilter = "All";

  final List<Map<String, dynamic>> payments = [
    {
      "tour": "Taj Mahal Sunrise Tour",
      "price": "â‚¹4,500",
      "date": "Oct 1, 2025",
      "guide": "Sarah Johnson",
      "status": "Completed",
      "transaction": "TXN001234567",
      "image": "https://upload.wikimedia.org/wikipedia/commons/d/da/Taj-Mahal.jpg",
    },
    {
      "tour": "Jaipur Pink City Heritage",
      "price": "â‚¹6,800",
      "date": "Sep 28, 2025",
      "guide": "Michael Chen",
      "status": "Completed",
      "transaction": "TXN001234568",
      "image": "https://upload.wikimedia.org/wikipedia/commons/3/3a/Amber_Fort_Jaipur_India.jpg",
    },
    {
      "tour": "Delhi Heritage Walk",
      "price": "â‚¹3,200",
      "date": "Sep 25, 2025",
      "guide": "Emma Williams",
      "status": "Pending",
      "transaction": "TXN001234569",
      "image": "https://upload.wikimedia.org/wikipedia/commons/3/3e/India_Gate_in_New_Delhi_03-2016_img3.jpg",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = selectedFilter == "All"
        ? payments
        : payments.where((p) => p['status'] == selectedFilter).toList();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Payment History"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCards(),
            const SizedBox(height: 16),
            _buildFilterTabs(),
            const SizedBox(height: 10),
            ...filtered.map((p) => _buildPaymentCard(p)),
          ],
        ),
      ),
    );
  }

  // ---------- SUMMARY CARDS ----------
  Widget _buildSummaryCards() {
    return Row(
      children: [
        Expanded(
          child: _summaryCard(
            "Total Earnings",
            "â‚¹23,300",
            "This month",
            Iconsax.wallet_1,
            Colors.green.shade100,
            Colors.green.shade700,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _summaryCard(
            "Pending",
            "â‚¹3,200",
            "Processing",
            Iconsax.clock,
            Colors.orange.shade100,
            Colors.orange.shade700,
          ),
        ),
      ],
    );
  }

  Widget _summaryCard(String title, String value, String subtitle, IconData icon,
      Color bgColor, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(
                      color: iconColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14)),
              Text(value,
                  style: TextStyle(
                      color: iconColor,
                      fontWeight: FontWeight.w900,
                      fontSize: 16)),
              Text(subtitle,
                  style: TextStyle(
                      color: iconColor.withValues(alpha: 0.7), fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  // ---------- FILTER TABS ----------
  Widget _buildFilterTabs() {
    final filters = ["All", "Completed", "Pending"];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: filters.map((f) {
        final selected = selectedFilter == f;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => selectedFilter = f),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: selected ? Colors.purple : Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                f,
                style: TextStyle(
                    color: selected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ---------- PAYMENT CARD ----------
  Widget _buildPaymentCard(Map<String, dynamic> p) {
    final isCompleted = p['status'] == "Completed";
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                p['image'],
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.broken_image,
                  size: 40,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p['tour'],
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  Text(p['guide'], style: const TextStyle(fontSize: 13)),
                  Text(p['date'], style: const TextStyle(fontSize: 12)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? Colors.green.shade100
                              : Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          p['status'],
                          style: TextStyle(
                              color: isCompleted
                                  ? Colors.green.shade700
                                  : Colors.orange.shade700,
                              fontWeight: FontWeight.w600,
                              fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          "Transaction ID: ${p['transaction']}",
                          style: const TextStyle(fontSize: 11),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isCompleted)
                        GestureDetector(
                          onTap: () {},
                          child: const Text(
                            "Receipt",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Colors.blueAccent),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              p['price'],
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
