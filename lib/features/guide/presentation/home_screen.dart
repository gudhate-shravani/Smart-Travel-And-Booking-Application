
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'search_screen.dart';
import 'app_drawer_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class RequestItem {
  final String type; // 'guide' or 'package'
  final String requesterEmail;
  String requesterName;
  String? requesterAvatar;
  final String guideEmail;
  final String? packageName;
  final Map<String, dynamic>? packageData;
  final DocumentReference requestDocRef;
  String status;
  Timestamp? timestamp;
  String? guideLocation;

  RequestItem({
    required this.type,
    required this.requesterEmail,
    required this.requesterName,
    this.requesterAvatar,
    required this.guideEmail,
    this.packageName,
    this.packageData,
    required this.requestDocRef,
    required this.status,
    this.timestamp,
    this.guideLocation,
  });
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<RequestItem> _requests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() {
      _isLoading = true;
    });

    final User? user = _auth.currentUser;
    if (user == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    final String guideEmail = user.email ?? '';
    if (guideEmail.isEmpty) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    List<RequestItem> items = [];

    try {
      final guideDocRef = _firestore.collection('Guide').doc(guideEmail);
      final guideDoc = await guideDocRef.get();
      final guideLocation = guideDoc.data()?['location'] ?? '';

      // Fetch guide-level requests
      final guideRequestsSnap = await guideDocRef.collection('request').get();
      for (var req in guideRequestsSnap.docs) {
        final requesterEmail = req.id;
        final reqData = req.data();
        final status = reqData['status'] ?? 'pending';
        final ts = reqData['timestamp'] as Timestamp?;
        final travelerDoc =
            await _firestore.collection('Traveler').doc(requesterEmail).get();
        final requesterName =
            travelerDoc.data()?['fullName'] ?? requesterEmail;
        final avatar = travelerDoc.data()?['photoUrl'] ??
            'https://i.pravatar.cc/150?u=$requesterEmail';

        items.add(RequestItem(
          type: 'guide',
          requesterEmail: requesterEmail,
          requesterName: requesterName,
          requesterAvatar: avatar,
          guideEmail: guideEmail,
          requestDocRef: req.reference,
          status: status,
          timestamp: ts,
          guideLocation: guideLocation,
        ));
      }

      // Fetch package-level requests
      final packagesSnap = await guideDocRef.collection('packages').get();
      for (var pkgDoc in packagesSnap.docs) {
        final packageName = pkgDoc.id;
        final packageData = pkgDoc.data();
        final pkgReqSnap = await pkgDoc.reference.collection('request').get();

        for (var req in pkgReqSnap.docs) {
          final requesterEmail = req.id;
          final reqData = req.data();
          final status = reqData['status'] ?? 'pending';
          final ts = reqData['timestamp'] as Timestamp?;
          final travelerDoc = await _firestore
              .collection('Traveler')
              .doc(requesterEmail)
              .get();
          final requesterName =
              travelerDoc.data()?['fullName'] ?? requesterEmail;
          final avatar = travelerDoc.data()?['photoUrl'] ??
              'https://i.pravatar.cc/150?u=$requesterEmail';

          items.add(RequestItem(
            type: 'package',
            requesterEmail: requesterEmail,
            requesterName: requesterName,
            requesterAvatar: avatar,
            guideEmail: guideEmail,
            packageName: packageName,
            packageData: packageData,
            requestDocRef: req.reference,
            status: status,
            timestamp: ts,
            guideLocation: packageData['location'] ?? guideLocation,
          ));
        }
      }

      // Sort latest first
      items.sort((a, b) {
        final ta = a.timestamp?.millisecondsSinceEpoch ?? 0;
        final tb = b.timestamp?.millisecondsSinceEpoch ?? 0;
        return tb.compareTo(ta);
      });
    } catch (e) {
      debugPrint('Error loading requests: $e');
    }

    if (!mounted) return;
    setState(() {
      _requests = items;
      _isLoading = false;
    });
  }

  Future<void> _updateRequestStatus(RequestItem item, String newStatus) async {
    try {
      await item.requestDocRef
          .set({'status': newStatus}, SetOptions(merge: true));
      if (!mounted) return;
      setState(() {
        item.status = newStatus;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Request ${newStatus.toUpperCase()}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update: $e')),
      );
    }
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey.shade600, size: 18),
        const SizedBox(width: 12),
        Text(text,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade800)),
      ],
    );
  }

  Widget _buildRequestCard(RequestItem item) {
    return _buildCard(
      avatar: item.requesterAvatar ?? '',
      touristName: item.requesterName,
      packageName:
          item.packageName ?? (item.type == 'guide' ? 'Guide Request' : ''),
      date: item.timestamp != null
          ? '${item.timestamp!.toDate().day}-${item.timestamp!.toDate().month}-${item.timestamp!.toDate().year}'
          : 'No date',
      time: 'Flexible',
      location: item.guideLocation ?? 'Unknown',
      price: item.packageData?['price']?.toString() ?? 'â€”',
      status: item.status,
      onAccept: () => _updateRequestStatus(item, 'accepted'),
      onReject: () => _updateRequestStatus(item, 'rejected'),
    );
  }

  Widget _buildCard({
    required String avatar,
    required String touristName,
    required String packageName,
    required String date,
    required String time,
    required String location,
    required String price,
    required String status,
    required VoidCallback onAccept,
    required VoidCallback onReject,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(radius: 28, backgroundImage: NetworkImage(avatar)),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(touristName,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(packageName,
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 14)),
                  ],
                ),
              ],
            ),
            const Divider(height: 24),
            _buildDetailRow(CupertinoIcons.calendar, date),
            const SizedBox(height: 8),
            _buildDetailRow(CupertinoIcons.clock, time),
            const SizedBox(height: 8),
            _buildDetailRow(CupertinoIcons.location, location),
            const SizedBox(height: 8),
            _buildDetailRow(Icons.currency_rupee, price),
            const SizedBox(height: 16),
            if (status == 'pending')
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onReject,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red.shade400,
                        side: BorderSide(color: Colors.red.shade100),
                      ),
                      child: const Text('Reject'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onAccept,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [Color(0xFF8A2BE2), Color(0xFF5F2EEA)]),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: const Text('Accept'),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            else
              Text(
                status.toUpperCase(),
                style: TextStyle(
                    color: status == 'accepted'
                        ? Colors.green
                        : Colors.red.shade400,
                    fontWeight: FontWeight.bold),
              )
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => const SearchScreen())),
      child: Hero(
        tag: 'search-bar',
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4))
              ],
            ),
            child: const Row(
              children: [
                Icon(Icons.search, color: Colors.grey),
                SizedBox(width: 12),
                Text('Search tours, places, guides...',
                    style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTripOverview() {
    return StaggeredGrid.count(
      crossAxisCount: 3,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: [
        StaggeredGridTile.count(
          crossAxisCellCount: 1,
          mainAxisCellCount: 1.3,
          child: _buildOverviewCard(
            icon: Icons.currency_rupee,
            label: 'This Month',
            value: 'â‚¹45,680',
            subValue: '+12%',
            gradient: const LinearGradient(
                colors: [Color(0xFF8A2BE2), Color(0xFF5F2EEA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight),
          ),
        ),
        StaggeredGridTile.count(
          crossAxisCellCount: 1,
          mainAxisCellCount: 1,
          child: _buildOverviewCard(
            icon: CupertinoIcons.calendar,
            label: 'Upcoming',
            value: '8 tours',
            gradient: const LinearGradient(
                colors: [Color(0xFF007BFF), Color(0xFF00C6FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight),
          ),
        ),
        StaggeredGridTile.count(
          crossAxisCellCount: 1,
          mainAxisCellCount: 1.3,
          child: _buildOverviewCard(
            icon: CupertinoIcons.star_fill,
            label: 'Rating',
            value: '4.9',
            isRating: true,
            gradient: const LinearGradient(
                colors: [Color(0xFFFFA500), Color(0xFFFFC107)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight),
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewCard({
    required IconData icon,
    required String label,
    required String value,
    String? subValue,
    bool isRating = false,
    required Gradient gradient,
  }) {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: Colors.white.withValues(alpha: 0.9), size: 22),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style:
                      const TextStyle(color: Colors.white70, fontSize: 13)),
              Text(value,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              if (subValue != null)
                Text(subValue,
                    style:
                        const TextStyle(color: Colors.white, fontSize: 12)),
              if (isRating)
                const Row(
                  children: [
                    Icon(Icons.star, color: Colors.white, size: 12),
                    Icon(Icons.star, color: Colors.white, size: 12),
                    Icon(Icons.star, color: Colors.white, size: 12),
                    Icon(Icons.star, color: Colors.white, size: 12),
                    Icon(Icons.star_half, color: Colors.white, size: 12),
                  ],
                ),
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('GuideHub', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(icon: const Icon(CupertinoIcons.bell), onPressed: () {}),
        ],
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      drawer: const AppDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadRequests,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSearchBar(context),
                    const SizedBox(height: 24),
                    const Text('Trip Overview',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _buildTripOverview(),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        const Text('User Requests',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.red.shade400,
                          child: Text('${_requests.length}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_requests.isEmpty)
                      const Center(child: Text('No requests yet.')),
                    for (var r in _requests)
                      _buildRequestCard(r)
                          .animate()
                          .fadeIn(duration: 400.ms)
                          .slideX(begin: -0.1),
                  ],
                ),
              ),
            ),
    );
  }
}
