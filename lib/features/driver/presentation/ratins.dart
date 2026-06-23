// lib/reviews_screen.dart

import 'package:flutter/material.dart';
class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  int _selectedFilterIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ratings & Reviews'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color.fromARGB(255, 16, 16, 16),
        automaticallyImplyLeading: true, // Shows back button if possible
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildHeader(),
              _buildRatingOverviewCard(),
              SizedBox(height: 16,),
              _buildAchievementsCard(),
              SizedBox(height: 16,),
             // _buildFilterReviewsCard(),
              _buildRecentReviewsSection(),
              SizedBox(height: 16,),
              _buildPerformanceInsightsCard(),
              SizedBox(height: 16,),
              buildRatingTipsCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.amber.withOpacity(0.1),
          child: const Icon(Icons.star_outline_rounded, color: Colors.amber, size: 30),
        ),
        const SizedBox(height: 12),
        const Text('Ratings & Reviews', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('Track your service quality & passenger feedback', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildRatingOverviewCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your Rating Overview', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                Column(
                  children: [
                    const Text('4.7', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
                    Row(
                      children: List.generate(5, (index) => Icon(
                        index < 4 ? Icons.star_rounded : Icons.star_half_rounded,
                        color: Colors.amber,
                        size: 20,
                      )),
                    ),
                    const SizedBox(height: 4),
                    const Text('Average Rating', style: TextStyle(color: Colors.grey)),
                  ],
                ),
                const Spacer(),
                Column(
                  children: [
                    const Text('1247', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
                    const Text('Total Reviews', style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 4),
                    const Row(
                      children: [
                        Icon(Icons.arrow_upward_rounded, color: Colors.green, size: 14),
                        Text('+12.5% from last month', style: TextStyle(color: Colors.green, fontSize: 12)),
                      ],
                    )
                  ],
                ),
              ],
            ), const Divider(height: 32),
            Text('Rating Distribution', style: TextStyle(color: Colors.green, fontSize: 12)),
           
            _buildRatingDistributionRow('5 ★', 856, 0.68),
            _buildRatingDistributionRow('4 ★', 248, 0.20),
            _buildRatingDistributionRow('3 ★', 93, 0.07),
            _buildRatingDistributionRow('2 ★', 31, 0.02),
            _buildRatingDistributionRow('1 ★', 19, 0.01),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingDistributionRow(String label, int count, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(width: 8),
          Expanded(
            child: LinearProgressIndicator(
              value: value,
              backgroundColor: Colors.grey.shade200,
              color: Colors.blue,
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          const SizedBox(width: 8),
          Text(count.toString(), style: TextStyle(color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  Widget _buildAchievementsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your Achievements', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _achievementItem(Icons.workspace_premium_outlined, 'Top Rated\nDriver', Colors.orange),
                _achievementItem(Icons.favorite_border_rounded, 'Customer\nFavorite', Colors.red),
                _achievementItem(Icons.verified_outlined, 'Consistent\nService', Colors.blue),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _achievementItem(IconData icon, String label, Color color) {
    return Column(
      children: [
        CircleAvatar(radius: 24, backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color)),
        const SizedBox(height: 8),
        Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildFilterReviewsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Row(
          children: [
            const Icon(Icons.filter_list_rounded, size: 20),
            const SizedBox(width: 8),
            const Text('Filter Reviews'),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _filterChip("All Reviews", 5, 0),
                    _filterChip("5 Stars", 3, 1),
                    _filterChip("4 Stars", 1, 2),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label, int count, int index) {
    final bool isSelected = _selectedFilterIndex == index;
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: ChoiceChip(
        label: Row(
          children: [
            Text(label),
            const SizedBox(width: 4),
            CircleAvatar(
              radius: 9,
              backgroundColor: isSelected ? Colors.white.withOpacity(0.5) : Colors.blue,
              child: Text(count.toString(), style: TextStyle(fontSize: 11, color: isSelected ? Colors.blue : Colors.white, fontWeight: FontWeight.bold)),
            )
          ],
        ),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            setState(() {
              _selectedFilterIndex = index;
            });
          }
        },
        selectedColor: Colors.blue,
        labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
      ),
    );
  }

  Widget _buildRecentReviewsSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Recent Reviews', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(20)),
              child: const Text('5 reviews', style: TextStyle(color: Colors.white, fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildReviewCard("PS", "Priya Sharma", "2 hours ago", 5, "Excellent service! Very punctual and polite driver. Clean car and smooth ride. Highly recommended!", "Connaught Place", "IGI Airport", 3),
        _buildReviewCard("AK", "Amit Kumar", "1 day ago", 4, "Good experience overall. Driver was professional and knew the routes well. Minor delay due to traffic but communicated well.", "Karol Bagh", "Gurgaon", 7),
        _buildReviewCard("SJ", "Sarah Johnson", "2 days ago", 5, "Amazing driver! Helped with luggage and was very courteous. Will definitely book again.", "Hotel", "Railway Station", 5),
      ],
    );
  }
  
  Widget _buildReviewCard(String initials, String name, String time, int rating, String review, String from, String to, int likes) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(child: Text(initials)),
                const SizedBox(width: 12),
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                Text(time, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 8),
            Row(children: List.generate(5, (index) => Icon(Icons.star, color: index < rating ? Colors.amber : Colors.grey.shade300, size: 18))),
            const SizedBox(height: 12),
            Text(review, style: const TextStyle(height: 1.4)),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                  child: Text("$from → $to", style: const TextStyle(fontSize: 12)),
                ),
                const Spacer(),
                const Icon(Icons.thumb_up_alt_outlined, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(likes.toString(), style: const TextStyle(color: Colors.grey)),
                const SizedBox(width: 16),
                const Icon(Icons.reply_outlined, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                const Text('Reply', style: TextStyle(color: Colors.grey)),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceInsightsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Performance Insights', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 2.5,
              children: [
                _insightItem('87%', 'Repeat Customers', Icons.groups_outlined, Colors.green),
                _insightItem('94%', 'On-Time work', Icons.track_changes_outlined, Colors.blue),
                _insightItem('4.8/5', 'Communication', Icons.chat_bubble_outline_rounded, Colors.purple),
                _insightItem('96%', 'Satisfaction Rate', Icons.sentiment_satisfied_outlined, Colors.orange),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _insightItem(String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
              Text(label, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
/*
  Widget _buildTipsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tips to Improve Your Rating', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildTipItem('Be punctual:', ' Arrive at pickup location on time and communicate any delays.'),
            _buildTipItem('Keep vehicle clean:', ' Maintain a clean and comfortable environment.'),
            _buildTipItem('Professional service:', ' Be polite, helpful, and follow safety guidelines.'),
            _buildTipItem('Know your routes:', ' Use GPS efficiently and know local shortcuts.'),
          ],
        ),
      ),
    );
  }

  Widget _buildTipItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6.0, right: 8.0),
            child: CircleAvatar(radius: 3, backgroundColor: Colors.blue),
          ),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: [
                  TextSpan(text: title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: description),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }*/
 
/// Builds a card that displays tips for improving a rating.
Widget buildRatingTipsCard() {
  return Card(
    elevation: 2.0,
    // Defines the shape of the card with rounded corners.
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0),
    ),
    // Ensures the content inside the card respects the rounded corners.
    clipBehavior: Clip.antiAlias,
    child: Container(
      // Sets the light blue background color.
      color: Colors.blue.shade50.withOpacity(0.5),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        // Aligns children to the start (left) of the column.
        crossAxisAlignment: CrossAxisAlignment.start,
        // Makes the column only as tall as its children.
        mainAxisSize: MainAxisSize.min,
        children: [
          // --- Title Row ---
          Row(
            children: [
              Icon(Icons.thumb_up_alt_outlined, color: Colors.blue.shade700),
              const SizedBox(width: 8.0),
              const Text(
                'Tips to Improve Your Rating',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),

          // --- Tip Items ---
          _buildTipRow(
            'Be punctual:',
            ' Arrive at pickup location on time and communicate any delays',
          ),
          const SizedBox(height: 10.0),
          _buildTipRow(
            'Keep vehicle clean:',
            ' Maintain a clean and comfortable environment',
          ),
          const SizedBox(height: 10.0),
          _buildTipRow(
            'Professional service:',
            ' Be polite, helpful, and follow safety guidelines',
          ),
          const SizedBox(height: 10.0),
          _buildTipRow(
            'Know your routes:',
            ' Use GPS efficiently and know local shortcuts',
          ),
        ],
      ),
    ),
  );
}

/// Helper function to build a single tip row to avoid code duplication.
Widget _buildTipRow(String title, String description) {
  return Row(
    // Aligns the bullet point with the top of the text.
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(top: 5.0),
        child: Icon(Icons.circle, size: 8.0, color: Colors.blue.shade700),
      ),
      const SizedBox(width: 12.0),
      // Expanded ensures the text wraps properly if it's too long.
      Expanded(
        child: Text.rich(
          TextSpan(
            // Default text style for this row.
            style: const TextStyle(fontSize: 14.0, color: Colors.black87),
            children: [
              TextSpan(
                text: title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(text: description),
            ],
          ),
        ),
      ),
    ],
  );
}
}