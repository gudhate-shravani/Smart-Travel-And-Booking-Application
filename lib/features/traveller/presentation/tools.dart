/*import 'package:flutter/material.dart';

// --- DATA MODELS ---

// Represents an item in the Document Vault.
class DocumentItem {
  final IconData icon;
  final String title;
  final String details;
  final String type;

  DocumentItem({
    required this.icon,
    required this.title,
    required this.details,
    required this.type,
  });
}

// --- MAIN SCREEN WIDGET ---

class TravelToolsScreen extends StatefulWidget {
  const TravelToolsScreen({super.key});

  @override
  State<TravelToolsScreen> createState() => _TravelToolsScreenState();
}

class _TravelToolsScreenState extends State<TravelToolsScreen> {
  // --- STATE VARIABLES ---
  int _selectedTabIndex = 0; // 0: Currency, 1: Time, 2: Weather

  // --- MOCK DATA ---
  final List<DocumentItem> _documents = [
    DocumentItem(
      icon: Icons.description_outlined,
      title: 'Passport',
      details: '2.4 MB • 2024-01-15',
      type: 'Document',
    ),
    DocumentItem(
      icon: Icons.flight_takeoff_outlined,
      title: 'Flight Tickets',
      details: '1.8 MB • 2024-01-18',
      type: 'Ticket',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FF), // Light blueish background
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
             // _buildUtilityHeader(),
              const SizedBox(height: 16),
              _buildTabs(),
              const SizedBox(height: 20),
              // AnimatedSwitcher provides a nice fade transition between tabs.
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildSelectedTabContent(),
              ),
              const SizedBox(height: 20),
              _buildDocumentVault(),
            ],
          ),
        ),
      ),
     // bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // --- WIDGET BUILDER METHODS ---

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
     
      title: const Text('Travel Tools', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
      centerTitle: true,
      actions: [
        IconButton(icon: const Icon(Icons.notifications_none, color: Colors.black87), onPressed: () {}),
        IconButton(icon: const Icon(Icons.chat_bubble_outline, color: Colors.black87), onPressed: () {}),
      ],
    );
  }
  
  Widget _buildUtilityHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: const [
            Icon(Icons.arrow_back, color: Colors.black87),
            SizedBox(width: 16),
            Text('Travel Utilities', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        Icon(Icons.calendar_view_day_outlined, color: Colors.blue.shade700),
      ],
    );
  }

  Widget _buildTabs() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          _buildTabItem('Currency', 0),
          _buildTabItem('Time', 1),
          _buildTabItem('Weather', 2),
        ],
      ),
    );
  }

  Widget _buildTabItem(String title, int index) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isSelected
                ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)]
                : [],
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.blue.shade800 : Colors.grey.shade600,
            ),
          ),
        ),
      ),
    );
  }

  // Returns the main content widget based on the selected tab index.
  Widget _buildSelectedTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildCurrencyConverter();
      case 1:
        return _buildWorldClock();
      case 2:
        return _buildWeatherUpdates();
      default:
        return Container();
    }
  }

  Widget _buildCurrencyConverter() {
    return Column(
      key: const ValueKey('currency'),
      children: [
        // Main converter card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Currency Converter', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildCurrencySelector('From', 'US', 'USD'),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Icon(Icons.swap_horiz, color: Colors.white),
                  ),
                  _buildCurrencySelector('To', 'EU', 'EUR'),
                ],
              ),
              const SizedBox(height: 12),
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Amount',
                  labelStyle: TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white12,
                  border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.all(Radius.circular(12))),
                ),
                keyboardType: TextInputType.number,
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Converted Amount', style: TextStyle(color: Colors.green.shade900)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('85.30 EUR', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        Text('Rate: 1 USD = 0.853 EUR', style: TextStyle(color: Colors.grey.shade600)),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Popular rates card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Popular Exchange Rates', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildRateRow('1 USD = 0.853 EUR'),
              _buildRateRow('1 USD = 0.742 GBP'),
              _buildRateRow('1 USD = 110.25 JPY'),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildCurrencySelector(String label, String code, String currency) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Text(code, style: const TextStyle(color: Colors.white)),
                const SizedBox(width: 8),
                Expanded(child: Text(currency, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                const Icon(Icons.arrow_drop_down, color: Colors.white),
              ],
            ),
          )
        ],
      ),
    );
  }
  
  Widget _buildRateRow(String rate) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(rate),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('Live', style: TextStyle(color: Colors.green.shade800, fontWeight: FontWeight.bold, fontSize: 12)),
          )
        ],
      ),
    );
  }

  Widget _buildWorldClock() {
    return Container(
      key: const ValueKey('time'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF3F51B5), Color(0xFF1A237E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('World Clock', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.8,
            children: [
              _buildClockItem('US', 'New York', '10:30 AM', 'EST'),
              _buildClockItem('GB', 'London', '3:30 PM', 'GMT'),
              _buildClockItem('JP', 'Tokyo', '12:30 AM+1', 'JST'),
              _buildClockItem('AU', 'Sydney', '2:30 AM+1', 'AEDT'),
              _buildClockItem('AE', 'Dubai', '7:30 PM', 'GST'),
              _buildClockItem('FR', 'Paris', '4:30 PM', 'CET'),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildClockItem(String countryCode, String city, String time, String timezone) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(countryCode, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              Text(city, style: const TextStyle(color: Colors.white70)),
            ],
          ),
          const Spacer(),
          Text(time, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          Text(timezone, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildWeatherUpdates() {
    return Container(
      key: const ValueKey('weather'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF0288D1), Color(0xFF01579B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           const Text('Weather Updates', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
           const SizedBox(height: 12),
           _buildWeatherRow(Icons.wb_sunny, Colors.orange, 'New York', 'Sunny', '22°C'),
           _buildWeatherRow(Icons.cloud_outlined, Colors.grey.shade300, 'London', 'Cloudy', '15°C'),
           _buildWeatherRow(Icons.grain, Colors.blue.shade200, 'Tokyo', 'Rainy', '18°C'),
           _buildWeatherRow(Icons.cloud, Colors.grey.shade400, 'Sydney', 'Partly Cloudy', '25°C'),
        ],
      ),
    );
  }

  Widget _buildWeatherRow(IconData icon, Color iconColor, String city, String condition, String temp) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(city, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              Text(condition, style: const TextStyle(color: Colors.white70)),
            ],
          ),
          const Spacer(),
          Text(temp, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildDocumentVault() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Document Vault', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              OutlinedButton(
                onPressed: () {},
                child: const Text('Add Document'),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          ListView.separated(
            itemCount: _documents.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final doc = _documents[index];
              return Row(
                children: [
                  Icon(doc.icon, color: Colors.blue.shade800),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(doc.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(doc.details, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                    ],
                  ),
                  const Spacer(),
                   Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(doc.type, style: const TextStyle(fontSize: 12)),
                    )
                ],
              );
            },
          )
        ],
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.deepPurple,
      unselectedItemColor: Colors.grey.shade500,
      currentIndex: 0, // Set 'Trip' as active for context.
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.location_on), label: 'Trip'),
        BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: 'Social'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Explore'),
        BottomNavigationBarItem(icon: Icon(Icons.business), label: 'Booking'),
        BottomNavigationBarItem(icon: Icon(Icons.directions_car), label: 'Transport'),
      ],
    );
  }
}*/


import 'package:flutter/material.dart';
import 'dart:async'; // For Timer and real-time clock update
import 'dart:math'; // For random data in mock weather

// --- DATA MODELS ---

// Currency Model for Dropdown
class Currency {
  final String code; // e.g., USD
  final String name; // e.g., US Dollar
  final String flagCode; // e.g., US (used for a flag display in real app)

  Currency({required this.code, required this.name, required this.flagCode});
}

// Represents an item in the Document Vault. (Unchanged)
class DocumentItem {
  final IconData icon;
  final String title;
  final String details;
  final String type;

  DocumentItem({
    required this.icon,
    required this.title,
    required this.details,
    required this.type,
  });
}

// --- MAIN SCREEN WIDGET ---

class TravelToolsScreen extends StatefulWidget {
  const TravelToolsScreen({super.key});

  @override
  State<TravelToolsScreen> createState() => _TravelToolsScreenState();
}

class _TravelToolsScreenState extends State<TravelToolsScreen> {
  // --- STATE VARIABLES ---
  int _selectedTabIndex = 0; // 0: Currency, 1: Time, 2: Weather

  // --- CURRENCY CONVERTER STATE ---
  final List<Currency> _availableCurrencies = [
    Currency(code: 'USD', name: 'US Dollar', flagCode: 'US'),
    Currency(code: 'EUR', name: 'Euro', flagCode: 'EU'),
    Currency(code: 'GBP', name: 'British Pound', flagCode: 'GB'),
    Currency(code: 'JPY', name: 'Japanese Yen', flagCode: 'JP'),
    Currency(code: 'INR', name: 'Indian Rupee', flagCode: 'IN'),
    Currency(code: 'AUD', name: 'Australian Dollar', flagCode: 'AU'),
  ];
  late Currency _fromCurrency;
  late Currency _toCurrency;
  double _inputAmount = 100.0;
  double _convertedAmount = 0.0;
  final TextEditingController _amountController = TextEditingController();

  // --- WORLD CLOCK STATE ---
  Timer? _timer;
  DateTime _currentTime = DateTime.now();

  // Mock time zone offsets (in hours from UTC) for demonstration
  final List<Map<String, dynamic>> _timeZones = [
    {'code': 'NY', 'city': 'New York', 'offset': -4.0, 'timezone': 'EDT'},
    {'code': 'LN', 'city': 'London', 'offset': 1.0, 'timezone': 'BST'},
    {'code': 'TK', 'city': 'Tokyo', 'offset': 9.0, 'timezone': 'JST'},
    {'code': 'SY', 'city': 'Sydney', 'offset': 11.0, 'timezone': 'AEDT'},
    {'code': 'DL', 'city': 'Delhi', 'offset': 5.5, 'timezone': 'IST'},
    {'code': 'PR', 'city': 'Paris', 'offset': 2.0, 'timezone': 'CEST'},
  ];

  // --- WEATHER STATE ---
  List<Map<String, dynamic>> _weatherData = [];
  bool _isWeatherLoading = false;

  // --- MOCK DATA --- (Unchanged)
  final List<DocumentItem> _documents = [
    DocumentItem(
      icon: Icons.description_outlined,
      title: 'Passport',
      details: '2.4 MB • 2024-01-15',
      type: 'Document',
    ),
    DocumentItem(
      icon: Icons.flight_takeoff_outlined,
      title: 'Flight Tickets',
      details: '1.8 MB • 2024-01-18',
      type: 'Ticket',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fromCurrency = _availableCurrencies[0]; // USD
    _toCurrency = _availableCurrencies[1]; // EUR
    _amountController.text = _inputAmount.toStringAsFixed(2);

    _convertCurrency(); // Initial conversion

    // Initialize clock and weather
    _startClock();
    _fetchWeather();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _amountController.dispose();
    super.dispose();
  }

  // --- CURRENCY LOGIC ---

  // Mock Exchange Rates (Hardcoded for demonstration)
  // Base: USD
  final Map<String, double> _mockRates = {
    'USD': 1.0,
    'EUR': 0.85, // 1 USD = 0.85 EUR
    'GBP': 0.74, // 1 USD = 0.74 GBP
    'JPY': 110.25, // 1 USD = 110.25 JPY
    'INR': 83.50,
    'AUD': 1.50,
  };

  void _convertCurrency() {
    // 1. Convert input to base currency (USD)
    final double amountInBase = _inputAmount / _mockRates[_fromCurrency.code]!;

    // 2. Convert base amount to target currency
    final double converted = amountInBase * _mockRates[_toCurrency.code]!;

    setState(() {
      _convertedAmount = converted;
    });
  }

  // --- WORLD CLOCK LOGIC (Fixing Overflow and Adding Real-Time) ---

  void _startClock() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
  }

  // Helper function to calculate time in a specific time zone
  String _getTimeInZone(double offset) {
    // Get the current UTC time
    final utcTime = _currentTime.toUtc();
    // Apply the offset (in hours)
    final targetTime = utcTime.add(Duration(
        hours: offset.toInt(),
        minutes: ((offset - offset.truncate()) * 60).toInt()));

    // Format the time (h:mm a)
    final time =
        '${targetTime.hour > 12 ? targetTime.hour - 12 : (targetTime.hour == 0 ? 12 : targetTime.hour)}:${targetTime.minute.toString().padLeft(2, '0')} ${targetTime.hour >= 12 ? 'PM' : 'AM'}';

    // Check for day difference for display
    String dayDiff = '';
    if (targetTime.day > utcTime.day) {
      dayDiff = '+1';
    } else if (targetTime.day < utcTime.day) {
      dayDiff = '-1';
    }

    return '$time$dayDiff';
  }

  // --- WEATHER LOGIC ---

  Future<void> _fetchWeather() async {
    setState(() {
      _isWeatherLoading = true;
    });

    // Simulate Network Delay
    await Future.delayed(const Duration(seconds: 2));

    final random = Random();
    final List<String> conditions = [
      'Sunny',
      'Cloudy',
      'Rainy',
      'Partly Cloudy',
      'Thunderstorm'
    ];
    final Map<String, IconData> icons = {
      'Sunny': Icons.wb_sunny,
      'Cloudy': Icons.cloud_outlined,
      'Rainy': Icons.grain,
      'Partly Cloudy': Icons.cloud,
      'Thunderstorm': Icons.flash_on,
    };
    final Map<String, Color> colors = {
      'Sunny': Colors.orange,
      'Cloudy': Colors.grey.shade300,
      'Rainy': Colors.blue.shade200,
      'Partly Cloudy': Colors.grey.shade400,
      'Thunderstorm': Colors.yellow.shade700,
    };

    final mockWeather = [
      'New York',
      'London',
      'Tokyo',
      'Sydney',
      'Mumbai',
      'Paris'
    ].map((city) {
      final condition = conditions[random.nextInt(conditions.length)];
      final temp = (20 + random.nextInt(15) - 5).toString(); // Temp range 15-30
      return {
        'city': city,
        'condition': condition,
        'temp': '$temp°C',
        'icon': icons[condition],
        'color': colors[condition],
      };
    }).toList();

    setState(() {
      _weatherData = mockWeather;
      _isWeatherLoading = false;
    });
  }

  // --- WIDGET BUILDER METHODS ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FF), // Light blueish background
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 16),
              _buildTabs(),
              const SizedBox(height: 20),
              // AnimatedSwitcher provides a nice fade transition between tabs.
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildSelectedTabContent(),
              ),
              const SizedBox(height: 20),
             // _buildDocumentVault(),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: const Text('Travel Tools',
          style: TextStyle(
              color: Colors.black87, fontWeight: FontWeight.bold)),
      centerTitle: true,
      actions: [
        IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black87),
            onPressed: () {}),
        IconButton(
            icon: const Icon(Icons.chat_bubble_outline, color: Colors.black87),
            onPressed: () {}),
      ],
    );
  }

  Widget _buildTabs() {
    // ... (Unchanged)
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          _buildTabItem('Currency', 0),
          _buildTabItem('Time', 1),
          _buildTabItem('Weather', 2),
        ],
      ),
    );
  }

  Widget _buildTabItem(String title, int index) {
    // ... (Unchanged)
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.1), blurRadius: 10)
                  ]
                : [],
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.blue.shade800 : Colors.grey.shade600,
            ),
          ),
        ),
      ),
    );
  }

  // Returns the main content widget based on the selected tab index.
  Widget _buildSelectedTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildCurrencyConverter();
      case 1:
        return _buildWorldClock();
      case 2:
        return _buildWeatherUpdates();
      default:
        return Container();
    }
  }

  Widget _buildCurrencyConverter() {
    return Column(
      key: const ValueKey('currency'),
      children: [
        // Main converter card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Currency Converter',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildCurrencySelector(
                      'From', _fromCurrency, (Currency? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _fromCurrency = newValue;
                        _convertCurrency();
                      });
                    }
                  }),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Icon(Icons.swap_horiz, color: Colors.white),
                  ),
                  _buildCurrencySelector('To', _toCurrency,
                      (Currency? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _toCurrency = newValue;
                        _convertCurrency();
                      });
                    }
                  }),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _amountController,
                onChanged: (value) {
                  setState(() {
                    _inputAmount = double.tryParse(value) ?? 0.0;
                    _convertCurrency();
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Amount',
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white12,
                  border: const OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.all(Radius.circular(12))),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Converted Amount',
                        style: TextStyle(color: Colors.green.shade900)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            '${_convertedAmount.toStringAsFixed(2)} ${_toCurrency.code}',
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold)),
                        Text(
                            'Rate: 1 ${_fromCurrency.code} = ${(_mockRates[_toCurrency.code]! / _mockRates[_fromCurrency.code]!).toStringAsFixed(4)} ${_toCurrency.code}',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 10)),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Popular rates card
        Container(
          padding: const EdgeInsets.all(16),
          decoration:
              BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Popular Exchange Rates (Base: USD)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildRateRow(
                  '1 USD = ${_mockRates['EUR']!.toStringAsFixed(3)} EUR'),
              _buildRateRow(
                  '1 USD = ${_mockRates['GBP']!.toStringAsFixed(3)} GBP'),
              _buildRateRow(
                  '1 USD = ${_mockRates['JPY']!.toStringAsFixed(2)} JPY'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCurrencySelector(String label, Currency selectedCurrency,
      ValueChanged<Currency?> onChanged) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<Currency>(
                isExpanded: true,
                value: selectedCurrency,
                dropdownColor: Colors.green.shade800,
                icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                style: const TextStyle(color: Colors.white),
                onChanged: onChanged,
                items: _availableCurrencies
                    .map<DropdownMenuItem<Currency>>((Currency currency) {
                  return DropdownMenuItem<Currency>(
                    value: currency,
                    child: Row(
                      children: [
                        // In a real app, this would be an image or a Flag icon widget
                        Text(currency.flagCode,
                            style: const TextStyle(color: Colors.white)),
                        const SizedBox(width: 8),
                        Expanded(
                            child: Text(currency.code,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold))),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildRateRow(String rate) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(rate),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('Live',
                style: TextStyle(
                    color: Colors.green.shade800,
                    fontWeight: FontWeight.bold,
                    fontSize: 12)),
          )
        ],
      ),
    );
  }

  Widget _buildWorldClock() {
    return Container(
      key: const ValueKey('time'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF3F51B5), Color(0xFF1A237E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('World Clock',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          // FIX: Adjusted childAspectRatio to allow more vertical space, preventing overflow.
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.5, // Reduced from 1.8 to 1.5 for the fix
            children: _timeZones
                .map((zone) => _buildClockItem(
                    zone['code'],
                    zone['city'],
                    _getTimeInZone(zone['offset']), // Dynamic time
                    zone['timezone']))
                .toList(),
          )
        ],
      ),
    );
  }

  Widget _buildClockItem(
      String countryCode, String city, String time, String timezone) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(countryCode,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              // Reduced font size for city to better fit the layout
              Text(city, style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
          const Spacer(),
          Text(time,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18, // Reduced font size for time to better fit
                  fontWeight: FontWeight.bold)),
          Text(timezone, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildWeatherUpdates() {
    return Container(
      key: const ValueKey('weather'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF0288D1), Color(0xFF01579B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Weather Updates',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          if (_isWeatherLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(color: Colors.white),
              ),
            )
          else
            ..._weatherData.map((data) => _buildWeatherRow(
                data['icon'] as IconData,
                data['color'] as Color,
                data['city'] as String,
                data['condition'] as String,
                data['temp'] as String)),
          const SizedBox(height: 12),
          Center(
            child: TextButton.icon(
              onPressed: _fetchWeather,
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text('Refresh Weather', style: TextStyle(color: Colors.white)),
              style: TextButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.1)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildWeatherRow(IconData icon, Color iconColor, String city,
      String condition, String temp) {
    // ... (Unchanged, uses dynamic data)
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(city,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              Text(condition, style: const TextStyle(color: Colors.white70)),
            ],
          ),
          const Spacer(),
          Text(temp,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildDocumentVault() {
    // ... (Unchanged)
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Document Vault',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              OutlinedButton(
                onPressed: () {},
                child: const Text('Add Document'),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          ListView.separated(
            itemCount: _documents.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final doc = _documents[index];
              return Row(
                children: [
                  Icon(doc.icon, color: Colors.blue.shade800),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(doc.title,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(doc.details,
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 12)),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(doc.type, style: const TextStyle(fontSize: 12)),
                  )
                ],
              );
            },
          )
        ],
      ),
    );
  }
}
