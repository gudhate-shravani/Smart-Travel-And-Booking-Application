import 'package:flutter/material.dart';

// A simple data model for a journal entry.
class JournalEntry {
  final String title;
  final String date;
  final String time;
  final String location;
  final String locationDetail;
  final String moodEmoji;
  final String content;
  final List<String> imageUrls;
  final String weather;
  final String temperature;
  final List<String> tags;

  JournalEntry({
    required this.title,
    required this.date,
    required this.time,
    required this.location,
    required this.locationDetail,
    required this.moodEmoji,
    required this.content,
    required this.imageUrls,
    required this.weather,
    required this.temperature,
    required this.tags,
  });
}

// Main screen widget for the Trip Journal.
class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  // Mock data that matches the content from the screenshots.
  final List<JournalEntry> _journalEntries = [
    JournalEntry(
      title: 'The Famous Shibuya Scramble',
      date: '2024-01-20',
      time: '6:30 PM',
      location: 'Shibuya Crossing',
      locationDetail: 'Tokyo',
      moodEmoji: '🤩',
      content:
          'Today we experienced the iconic Shibuya crossing! The energy here is absolutely incredible. Thousands of people crossing from all directions, yet somehow it all works perfectly. We grabbed some amazing ramen from a tiny shop nearby - the best I\'ve ever had! The neon lights at night made everything feel like a scene from a movie. Can\'t wait to explore more of Tokyo tomorrow.',
      imageUrls: [
        'https://picsum.photos/seed/shibuya1/300/200',
        'https://picsum.photos/seed/shibuya2/300/200',
      ],
      weather: 'Sunny',
      temperature: '15°C',
      tags: ['#city', '#food', '#culture'],
    ),
    JournalEntry(
      title: 'Traditional Tokyo Morning',
      date: '2024-01-19',
      time: '8:00 AM',
      location: 'Sensoji Temple',
      locationDetail: 'Asa',
      moodEmoji: '🙏',
      content:
          'Started our day early at Senso-ji Temple. The traditional architecture is breathtaking, and the incense creates such a peaceful atmosphere. We participated in the ritual of washing our hands and mouth before praying. The nearby Nakamise shopping street was full of traditional snacks and souvenirs. Got some beautiful omamori (good luck charms) for friends back home.',
      imageUrls: [
        'https://picsum.photos/seed/sensoji/300/200',
      ],
      weather: 'Cloudy',
      temperature: '12°C',
      tags: ['#temple', '#traditional', '#culture'],
    ),
  ];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F8F7), // Light green-tinted background
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTripSummaryCard(),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                child: _buildNewEntryCard(),
              ),
              const SizedBox(height: 24),
              _buildJournalEntriesSection(),
              const SizedBox(height: 24),
              _buildJournalStatsCard(),
              const SizedBox(height: 24),
              _buildExportAndShareCard(),
            ],
          ),
        ),
      ),
     // bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // Builds the top AppBar for the journal screen.
  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      
      title: const Text(
        'Trip Journal',
        style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.add, color: Colors.black87, size: 28),
          onPressed: () {
            // Action for adding a new journal or entry
          },
        ),
      ],
    );
  }
  
  // Builds the main green card summarizing the trip.
  Widget _buildTripSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF00897B), // Teal color
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.description_outlined, color: Colors.white, size: 28),
              SizedBox(width: 12),
              Text(
                'Tokyo Adventure 2024',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Jan 15-25, 2024 • 8 entries',
            style: TextStyle(color: Colors.white.withValues(alpha:0.9), fontSize: 14),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildTripTag('Tokyo', isSelected: true),
              _buildTripTag('Paris'),
              _buildTripTag('Bali'),
            ],
          )
        ],
      ),
    );
  }
  
  // Helper for creating the small city tags.
  Widget _buildTripTag(String city, {bool isSelected = false}) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : Colors.white.withValues(alpha:0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        city,
        style: TextStyle(
          color: isSelected ? const Color(0xFF00897B) : Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Builds the card for adding a new journal entry.
  Widget _buildNewEntryCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(40, 20, 40, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(60, 15, 60,15),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green.shade50,
              ),
              child: const Icon(Icons.add, color: Colors.green, size: 28),
            ),
            const SizedBox(height: 12),
            const Text(
              'Write New Entry',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Capture your travel memories',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
  
  // Builds the entire section for listing journal entries.
  Widget _buildJournalEntriesSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Journal Entries',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE8E0F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${_journalEntries.length} entries',
                style: const TextStyle(
                  color: Color(0xFF6A1B9A),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListView.separated(
          itemCount: _journalEntries.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            return _buildJournalEntryCard(_journalEntries[index]);
          },
        )
      ],
    );
  }
  
  // Builds a single card for a journal entry.
  Widget _buildJournalEntryCard(JournalEntry entry) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Text(
                entry.title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Text(entry.moodEmoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 4),
              const Icon(Icons.edit_outlined, color: Colors.grey, size: 20),
              const SizedBox(width: 4),
              const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          // Date and Location Row
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey),
              const SizedBox(width: 3),
              Text('${entry.date} at ${entry.time}', style: const TextStyle(color: Colors.grey)),
              const SizedBox(width: 10),
              const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
              const SizedBox(width: 3),
              Text('${entry.location}, ${entry.locationDetail}', style: const TextStyle(color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 16),
          // Content Text
          Text(entry.content, style: const TextStyle(fontSize: 14, height: 1.5)),
          const SizedBox(height: 16),
          // Image Grid
          _buildImageGrid(entry.imageUrls),
          const SizedBox(height: 16),
          // Footer Row
          Row(
            children: [
              const Icon(Icons.wb_sunny_outlined, size: 16, color: Colors.orangeAccent),
              const SizedBox(width: 6),
              Text('${entry.weather}, ${entry.temperature}'),
              const Spacer(),
              ...entry.tags.map((tag) => _buildTagChip(tag)),
            ],
          )
        ],
      ),
    );
  }

  // Helper to build the image grid inside a journal entry.
  Widget _buildImageGrid(List<String> imageUrls) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: imageUrls.length > 1 ? 2 : 1, // Show 2 columns if more than one image
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.5,
      ),
      itemCount: imageUrls.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            imageUrls[index],
            fit: BoxFit.cover,
            errorBuilder: (c, e, s) => const Center(child: Icon(Icons.error)),
          ),
        );
      },
    );
  }
  
  // Helper to build a single tag chip.
  Widget _buildTagChip(String tag) {
    return Container(
      margin: const EdgeInsets.only(left: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(tag, style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
    );
  }
  
  // Builds the purple card showing journal statistics.
  Widget _buildJournalStatsCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: const [
          _StatItem(count: '3', label: 'Entries'),
          _StatItem(count: '15', label: 'Photos'),
          _StatItem(count: '5', label: 'Cities'),
        ],
      ),
    );
  }
  
  // Builds the final card for exporting and sharing.
  Widget _buildExportAndShareCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.ios_share_outlined, color: Colors.blue),
              SizedBox(width: 8),
              Text('Export & Share', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 2.8,
            children: const [
              _ExportButton(icon: Icons.picture_as_pdf_outlined, text: 'PDF Export'),
              _ExportButton(icon: Icons.photo_library_outlined, text: 'Photo Book'),
              _ExportButton(icon: Icons.share_outlined, text: 'Share Trip'),
              _ExportButton(icon: Icons.calendar_month_outlined, text: 'Calendar'),
            ],
          )
        ],
      ),
    );
  }
}
class _StatItem extends StatelessWidget {
  final String count;
  final String label;
  const _StatItem({required this.count, required this.label});
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(count, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha:0.8))),
      ],
    );
  }
}

// A reusable widget for an export button.
class _ExportButton extends StatelessWidget {
  final IconData icon;
  final String text;
  const _ExportButton({required this.icon, required this.text});
  
  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: Icon(icon, color: Colors.black54),
      label: Text(text, style: const TextStyle(color: Colors.black87)),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: Colors.grey.shade300),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
