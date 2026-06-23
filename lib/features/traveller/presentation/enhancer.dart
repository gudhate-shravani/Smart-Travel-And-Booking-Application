/*import 'package:flutter/material.dart';
import 'dart:async';

// Main entry point for the application.
void main() {
  runApp(const MyApp());
}

// The root widget of the application.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Photo Enhancer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
        scaffoldBackgroundColor: const Color(0xFFF8F5FA),
        fontFamily: 'Inter', // A clean, modern font similar to the design.
      ),
      home: const PhotoEnhancerScreen(),
    );
  }
}

// Main screen widget for the Photo Enhancer feature.
class PhotoEnhancerScreen extends StatefulWidget {
  const PhotoEnhancerScreen({super.key});

  @override
  State<PhotoEnhancerScreen> createState() => _PhotoEnhancerScreenState();
}

class _PhotoEnhancerScreenState extends State<PhotoEnhancerScreen> {
  // --- State Variables ---

  bool _isImageLoaded = false; // Controls whether to show the upload prompt or the editor.
  bool _isLoading = false; // Controls the visibility of the loading overlay.
  String _loadingMessage = ''; // Message to display during loading.
  int _selectedTabIndex = 0; // 0: AI Tools, 1: Filters, 2: Adjust
  int _selectedFilterIndex = 0; // Index of the currently selected filter.

  // State for the adjustment sliders.
  double _brightness = 0.5;
  double _contrast = 0.5;
  double _saturation = 0.5;

  // Placeholder for the main image being edited.
  final String _imageUrl = 'https://picsum.photos/seed/picsum/800/600';

  // --- UI Logic Methods ---

  // Simulates picking an image and transitions to the editor view.
  void _pickImage() {
    // In a real app, you would use a package like 'image_picker' here.
    // For this demo, we just simulate loading an image.
    setState(() {
      _isImageLoaded = true;
    });
  }

  // Simulates taking a new photo.
  void _takePhoto() {
    // This would also use 'image_picker' with the camera source.
    setState(() {
      _isImageLoaded = true;
    });
  }
  
  // Resets the state to show the initial upload prompt.
  void _loadNewPhoto() {
    setState(() {
      _isImageLoaded = false;
      // Reset all adjustments and filters
      _selectedTabIndex = 0;
      _selectedFilterIndex = 0;
      _brightness = 0.5;
      _contrast = 0.5;
      _saturation = 0.5;
    });
  }

  // Simulates an AI process by showing a loading overlay.
  void _runAiFeature(String featureName) {
    setState(() {
      _loadingMessage = 'Enhancing with AI...\nThis may take a few moments';
      _isLoading = true;
    });

    // Hide the overlay after a delay to simulate processing.
    Timer(const Duration(seconds: 3), () {
      setState(() {
        _isLoading = false;
      });
    });
  }
  
  // Simulates saving the final image.
  void _saveImage() {
     // In a real app, you would use 'image_gallery_saver' or a similar package.
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image saved successfully! (Simulated)')),
    );
  }


  // --- Build Methods for UI Components ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:// Color.fromARGB(197, 230, 197, 230),
      //primarySwatch: 
         
      const Color.fromARGB(255, 251, 235, 254),
        //scaffoldBackgroundColor: const Color(0xFFF8F5FA), // This line sets the color
      
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          // Main content of the screen.
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _isImageLoaded ? _buildEditor() : _buildUploadPrompt(),
            ),
          ),
          // Loading overlay that appears on top of the content when active.
          if (_isLoading) _buildLoadingOverlay(),
        ],
      ),
      // A placeholder for the main app's bottom navigation bar.
     // bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // Builds the top AppBar.
  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: const Color.fromARGB(0, 248, 246, 246),
      elevation: 0,
    
      title: const Text(
        'Photo Enhancer',
        style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      actions: _isImageLoaded
          ? [
              IconButton(
                icon: const Icon(Icons.download_outlined, color: Colors.black54),
                onPressed: _saveImage,
              ),
              IconButton(
                icon: const Icon(Icons.share_outlined, color: Colors.black54),
                onPressed: () {},
              ),
            ]
          : [
              const Icon(Icons.auto_awesome_outlined, color: Color(0xFF8A2BE2)),
              const SizedBox(width: 16),
            ],
    );
  }

  // Builds the initial view prompting the user to upload a photo.
  Widget _buildUploadPrompt() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // The main gradient card for uploading.
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              colors: [Color.fromARGB(255, 165, 77, 248), Color.fromARGB(255, 243, 211, 252)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            children: [
              Image.asset('assets/camera_icon.png', height: 60, errorBuilder: (c, e, s) => const Icon(Icons.camera_alt, size: 60, color: Colors.white)), // Placeholder in case asset is missing
              const SizedBox(height: 16),
              const Text(
                'Enhance Your Travel Photos',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(height: 8),
              const Text(
                'Upload a photo to start enhancing with AI-powered tools',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.white70),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildUploadButton('Take Photo', Icons.camera_alt_outlined, _takePhoto),
                  const SizedBox(width: 16),
                  _buildUploadButton('Upload', Icons.upload_file_outlined, _pickImage),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildSectionTitle('Recent Edits'),
        const SizedBox(height: 16),
        _buildRecentEdits(),
        const SizedBox(height: 24),
        _buildProTipsCard(),
      ],
    );
  }

  // A helper to build the buttons inside the gradient card.
  Widget _buildUploadButton(String text, IconData icon, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.deepPurple,
        backgroundColor: Colors.white.withOpacity(0.9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    );
  }

  // Builds the main editor view after an image is loaded.
  Widget _buildEditor() {
    // This matrix is dynamically built based on slider values.
    final colorMatrix = ColorFilter.matrix([
      // Red channel
      _contrast + 1, 0, 0, 0, _brightness * 255 - 128,
      // Green channel
      0, _contrast + 1, 0, 0, _brightness * 255 - 128,
      // Blue channel
      0, 0, _contrast + 1, 0, _brightness * 255 - 128,
      // Alpha channel
      0, 0, 0, 1, 0,
    ]);

    // Saturation is more complex, this is a simplified version.
    final saturationMatrix = ColorFilter.matrix([
      0.213 + 0.787 * (_saturation * 2), 0.715 - 0.715 * (_saturation * 2), 0.072 - 0.072 * (_saturation * 2), 0, 0,
      0.213 - 0.213 * (_saturation * 2), 0.715 + 0.285 * (_saturation * 2), 0.072 - 0.072 * (_saturation * 2), 0, 0,
      0.213 - 0.213 * (_saturation * 2), 0.715 - 0.715 * (_saturation * 2), 0.072 + 0.928 * (_saturation * 2), 0, 0,
      0, 0, 0, 1, 0,
    ]);
    
    return Column(
      children: [
        // The main image preview area.
        AspectRatio(
          aspectRatio: 4 / 3,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.0),
            child: ColorFiltered(
              // Apply the dynamic color filters to the image.
              colorFilter: saturationMatrix,
              child: ColorFiltered(
                colorFilter: colorMatrix,
                child: Image.network(
                    _imageUrl, 
                    fit: BoxFit.cover,
                    // Add loading and error builders for robustness.
                    loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return const Center(child: CircularProgressIndicator());
                    },
                    errorBuilder: (context, error, stackTrace) {
                        return const Center(child: Icon(Icons.broken_image, color: Colors.grey, size: 48));
                    },
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        // The tab selector (AI Tools, Filters, Adjust).
        _buildTabSelector(),
        const SizedBox(height: 24),
        // The content that changes based on the selected tab.
        IndexedStack(
          index: _selectedTabIndex,
          children: [
            _buildAiToolsGrid(),
            _buildFiltersGrid(),
            _buildAdjustmentsList(),
          ],
        ),
         const SizedBox(height: 24),
         _buildSectionTitle('Recent Edits'),
         const SizedBox(height: 16),
         _buildRecentEdits(),
      ],
    );
  }

  // Builds the tab selector widget.
  Widget _buildTabSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildTabItem(0, 'AI Tools'),
          _buildTabItem(1, 'Filters'),
          _buildTabItem(2, 'Adjust'),
        ],
      ),
    );
  }

  // Helper for creating a single tab item.
  Widget _buildTabItem(int index, String text) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 5,
                        spreadRadius: 1)
                  ]
                : [],
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.deepPurple : Colors.grey.shade600,
            ),
          ),
        ),
      ),
    );
  }

  // Builds the grid of AI tool cards.
  Widget _buildAiToolsGrid() {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('AI Enhancements'),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.1,
            children: [
              _buildAiCard('Auto Enhance', 'AI-powered automatic enhancement', Icons.auto_awesome, Colors.purple, () => _runAiFeature('Auto Enhance')),
              _buildAiCard('Remove Background', 'Smart background removal', Icons.crop_free, Colors.blue, () => _runAiFeature('Remove Background')),
              _buildAiCard('Upscale Quality', 'Increase image resolution', Icons.hd, Colors.green, () => _runAiFeature('Upscale Quality')),
              _buildAiCard('Restore Details', 'Recover lost details', Icons.filter_vintage, Colors.orange, () => _runAiFeature('Restore Details')),
            ],
          ),
          const SizedBox(height: 20),
          _buildActionButtons(),
        ],
    );
  }
  
  // Helper for a single AI tool card.
  Widget _buildAiCard(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 10,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const Spacer(),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 4),
              Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            ],
          ),
        ),
      );
  }


  // Builds the grid of photo filter options.
  Widget _buildFiltersGrid() {
    final filters = ['Original', 'Vintage', 'Dramatic', 'Vibrant', 'B&W', 'Warm'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         _buildSectionTitle('Photo Filters'),
         const SizedBox(height: 16),
        GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 5,
            mainAxisSpacing: 10,
            childAspectRatio: 0.8,
          ),
          itemCount: filters.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final isSelected = _selectedFilterIndex == index;
            return GestureDetector(
              onTap: () => setState(() => _selectedFilterIndex = index),
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? Colors.deepPurple : Colors.transparent,
                        width: 3,
                      ),
                     
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(9),
                      child: Image.network(
                        'https://picsum.photos/seed/${filters[index]}/200/300',
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => const Center(child: Icon(Icons.error_outline, color: Colors.red)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(filters[index], style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, fontSize: 13)),
                ],
              ),
            );
          },
        ),
         const SizedBox(height: 20),
        _buildActionButtons(),
      ],
    );
  }

  // Builds the list of manual adjustment sliders.
  Widget _buildAdjustmentsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Manual Adjustments'),
        const SizedBox(height: 16),
        _buildSliderRow('Brightness', Icons.brightness_6_outlined, _brightness, (val) => setState(() => _brightness = val)),
        _buildSliderRow('Contrast', Icons.contrast_outlined, _contrast, (val) => setState(() => _contrast = val)),
        _buildSliderRow('Saturation', Icons.color_lens_outlined, _saturation, (val) => setState(() => _saturation = val)),
        const SizedBox(height: 20),
        Row(
            children: [
                Expanded(child: _buildUtilButton('Rotate', Icons.rotate_90_degrees_ccw_outlined)),
                const SizedBox(width: 16),
                Expanded(child: _buildUtilButton('Crop', Icons.crop_outlined)),
            ],
        ),
        const SizedBox(height: 20),
        _buildActionButtons(),
      ],
    );
  }
  
  // Helper for creating a single adjustment slider row.
  Widget _buildSliderRow(String title, IconData icon, double value, ValueChanged<double> onChanged) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey.shade600),
            const SizedBox(width: 12),
            Text(title, style: const TextStyle(fontSize: 14)),
            Expanded(
              child: Slider(
                value: value,
                onChanged: onChanged,
                activeColor: Colors.deepPurple,
                inactiveColor: Colors.deepPurple.withOpacity(0.2),
              ),
            ),
            Text('${(value * 100).toInt()}%', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
      );
  }
  
  // Helper for Rotate and Crop buttons.
  Widget _buildUtilButton(String text, IconData icon) {
      return OutlinedButton.icon(
        onPressed: () {
            // Add rotate/crop logic here.
            // Cropping requires a package like 'image_cropper'.
        },
        icon: Icon(icon, size: 20),
        label: Text(text),
        style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            foregroundColor: Colors.black87,
            side: BorderSide(color: Colors.grey.shade300),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
  }

  // Builds the "New Photo" and "Save" buttons.
  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _loadNewPhoto,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              foregroundColor: Colors.black87,
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('New Photo', style: TextStyle(fontSize: 16)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _saveImage,
            icon: const Icon(Icons.download, size: 20),
            label: const Text('Save Enhanced', style: TextStyle(fontSize: 16)),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: const Color(0xFF8A2BE2),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              shadowColor: Colors.deepPurple.withOpacity(0.4),
            ),
          ),
        ),
      ],
    );
  }

  // Builds the horizontal list of recently edited photos.
  Widget _buildRecentEdits() {
    final recentImages = [
        'https://picsum.photos/seed/travel/200/300',
        'https://picsum.photos/seed/lights/200/300',
        'https://picsum.photos/seed/beach/200/300',
    ];
    final recentTitles = ['Mountain Sunset', 'Northern Lights', 'Beach Paradise'];

    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        itemBuilder: (context, index) => Card(
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: SizedBox(
            width: 110,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Image.network(
                      recentImages[index], 
                      fit: BoxFit.cover, 
                      width: double.infinity,
                      errorBuilder: (c, e, s) => const Center(child: Icon(Icons.error_outline, color: Colors.red)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(recentTitles[index], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  // Builds the "Pro Tips" card.
  Widget _buildProTipsCard() {
      return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFE0F2F1),
            borderRadius: BorderRadius.circular(16)
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Row(
                    children: const [
                        Icon(Icons.lightbulb, color: Color(0xFF00796B)),
                        SizedBox(width: 8),
                        Text('Pro Tips', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF00796B))),
                    ],
                ),
                const SizedBox(height: 12),
                _buildTipRow('Use AI Auto Enhance for quick improvements'),
                _buildTipRow('Remove backgrounds for social media posts'),
                _buildTipRow('Try different filters to set the mood'),
                _buildTipRow('Adjust brightness for better visibility'),
            ],
          ),
      );
  }

  // Helper for a single tip item.
  Widget _buildTipRow(String text) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                const Text('• ', style: TextStyle(color: Color(0xFF004D40))),
                Expanded(child: Text(text, style: const TextStyle(color: Color(0xFF004D40)))),
            ],
        ),
      );
  }
  
  // A generic helper for building section titles.
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
    );
  }
  
  // Builds the loading overlay with a message.
  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16)
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 20),
                Text(_loadingMessage, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
              ],
            ),
        ),
      ),
    );
  }

  // Builds the placeholder bottom navigation bar.
  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.deepPurple,
      unselectedItemColor: Colors.grey.shade500,
      currentIndex: 1, // Set 'Social' (camera icon) as active for context.
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.location_on), label: 'Trip'),
        BottomNavigationBarItem(icon: Icon(Icons.camera), label: 'Social'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Explore'),
        BottomNavigationBarItem(icon: Icon(Icons.business), label: 'Booking'),
        BottomNavigationBarItem(icon: Icon(Icons.directions_car), label: 'Transport'),
      ],
    );
  }
}

*/



import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:io';

// Packages for photo functionality
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

void main() {
  runApp(const MyApp());
}

// The root widget of the application.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Photo Enhancer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Use a consistent primary color based on the design's purple
        primaryColor: const Color(0xFF8A2BE2), 
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.deepPurple,
        ).copyWith(
          secondary: const Color(0xFF8A2BE2),
        ),
        scaffoldBackgroundColor: const Color(0xFFF8F5FA),
        fontFamily: 'Inter',
      ),
      home: const PhotoEnhancerScreen(),
    );
  }
}

// Main screen widget for the Photo Enhancer feature.
class PhotoEnhancerScreen extends StatefulWidget {
  const PhotoEnhancerScreen({super.key});

  @override
  State<PhotoEnhancerScreen> createState() => _PhotoEnhancerScreenState();
}

class _PhotoEnhancerScreenState extends State<PhotoEnhancerScreen> {
  // --- State Variables ---

  // XFile stores the temporary file object returned by image_picker/cropper
  XFile? _selectedFile; 
  bool _isImageLoaded = false;
  bool _isLoading = false;
  String _loadingMessage = '';
  int _selectedTabIndex = 0; // 0: AI Tools, 1: Filters, 2: Adjust
  int _selectedFilterIndex = 0; // Index of the currently selected filter.

  // State for the adjustment sliders (0.0 to 1.0)
  double _brightness = 0.5;
  double _contrast = 0.5;
  double _saturation = 0.5;

  final ImagePicker _picker = ImagePicker();

  // --- UI Logic Methods ---

  // Fetches an image from the gallery
  Future<void> _pickImage() async {
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() {
        _selectedFile = file;
        _isImageLoaded = true;
      });
    }
  }

  // Captures an image using the camera
  Future<void> _takePhoto() async {
    final XFile? file = await _picker.pickImage(source: ImageSource.camera);
    if (file != null) {
      setState(() {
        _selectedFile = file;
        _isImageLoaded = true;
      });
    }
  }

  // Handles cropping and rotation using image_cropper
  Future<void> _cropImage() async {
    if (_selectedFile == null) return;
    
    final CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: _selectedFile!.path,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 90,
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: Theme.of(context).primaryColor,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        IOSUiSettings(
          title: 'Crop Image',
          doneButtonTitle: 'Done',
          cancelButtonTitle: 'Cancel',
        ),
      ],
    );

    if (croppedFile != null) {
      setState(() {
        // CroppedFile needs to be converted back to XFile for consistency
        _selectedFile = XFile(croppedFile.path); 
      });
    }
  }
  
  // Simulates an AI process by showing a loading overlay.
  void _runAiFeature(String featureName) {
    setState(() {
      _loadingMessage = 'Processing $featureName...';
      _isLoading = true;
    });

    Timer(const Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$featureName complete! (Simulated)')),
      );
    });
  }

  // Resets the state to show the initial upload prompt.
  void _loadNewPhoto() {
    setState(() {
      _selectedFile = null;
      _isImageLoaded = false;
      _selectedTabIndex = 0;
      _selectedFilterIndex = 0;
      _brightness = 0.5;
      _contrast = 0.5;
      _saturation = 0.5;
    });
  }
  
  // Simulates saving the final image (requires file handling packages in a real app).
  void _saveImage() {
    if (_selectedFile == null) return;
    // In a real app, you would save _selectedFile to the device gallery.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Image saved successfully! (Simulated)')),
    );
  }

  // Applies the filter based on the selected index
  void _applyFilter(int index) {
    setState(() {
      _selectedFilterIndex = index;
      // In a real implementation, this would trigger a complex image processing pipeline.
      // For now, it updates the index which can be used to apply a custom ColorFilter.
    });
  }

  // --- Color Filter & Image Rendering ---

  // Returns the image widget based on file source (local or network placeholder)
  Widget _buildImageWidget(String placeholderUrl) {
    if (_selectedFile != null) {
      return Image.file(
        File(_selectedFile!.path),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Center(child: Icon(Icons.broken_image, color: Colors.red, size: 48));
        },
      );
    }
    // Fallback to the network image placeholder if for some reason file is null but isImageLoaded is true (shouldn't happen often)
    return Image.network(
      placeholderUrl,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const Center(child: CircularProgressIndicator());
      },
      errorBuilder: (context, error, stackTrace) {
        return const Center(child: Icon(Icons.broken_image, color: Colors.grey, size: 48));
      },
    );
  }
  
  // Applies the color adjustments (Brightness, Contrast, Saturation)
  ColorFilter _getAdjustmentFilter() {
    // Simplified B/C Matrix: 
    // R/G/B Channels: (C * component) + (B * 255 - 128)
    final contrastValue = _contrast * 2; // Range 0.0 to 2.0
    final brightnessValue = (_brightness - 0.5) * 255; // Range -127.5 to 127.5

    // Saturation Matrix (simplified for demonstration)
    final double sat = _saturation * 2; // Range 0.0 to 2.0
    final double luR = 0.213;
    final double luG = 0.715;
    final double luB = 0.072;
    
    // Saturation matrix elements
    final m11 = luR + sat * (1 - luR); final m12 = luG - sat * luG;     final m13 = luB - sat * luB;
    final m21 = luR - sat * luR;     final m22 = luG + sat * (1 - luG); final m23 = luB - sat * luB;
    final m31 = luR - sat * luR;     final m32 = luG - sat * luG;     final m33 = luB + sat * (1 - luB);

    // Combine Saturation, Brightness, and Contrast into a single matrix (simplified)
    return ColorFilter.matrix([
      // R channel
      contrastValue * m11, contrastValue * m12, contrastValue * m13, 0, brightnessValue,
      // G channel
      contrastValue * m21, contrastValue * m22, contrastValue * m23, 0, brightnessValue,
      // B channel
      contrastValue * m31, contrastValue * m32, contrastValue * m33, 0, brightnessValue,
      // A channel
      0, 0, 0, 1, 0,
    ]);
  }

  // Returns a filter matrix based on the selected filter index
  ColorFilter? _getFilterMatrix() {
    if (_selectedFilterIndex == 4) { // B&W Filter (Index 4 in filters list)
      // Standard grayscale conversion (Luminosity coefficients)
      return const ColorFilter.matrix([
        0.2126, 0.7152, 0.0722, 0, 0,
        0.2126, 0.7152, 0.0722, 0, 0,
        0.2126, 0.7152, 0.0722, 0, 0,
        0,      0,      0,      1, 0,
      ]);
    }
    // TODO: Add matrices for Vintage, Dramatic, etc. here.
    return null;
  }


  // --- Build Methods for UI Components ---

  @override
  Widget build(BuildContext context) {
    // Use the theme's background color for consistency
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    
    // The placeholder URL for the demo
    const placeholderImageUrl = 'https://picsum.photos/seed/picsum/800/600'; 
    
    return Scaffold(
      // Match the custom color in the main function's scaffoldBackgroundColor
      backgroundColor: backgroundColor,
      
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          // Main content of the screen.
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _isImageLoaded ? _buildEditor(placeholderImageUrl) : _buildUploadPrompt(),
            ),
          ),
          // Loading overlay that appears on top of the content when active.
          if (_isLoading) _buildLoadingOverlay(),
        ],
      ),
    );
  }


  // Builds the main editor view after an image is loaded.
  Widget _buildEditor(String placeholderImageUrl) {
    // Determine the color filter(s) to apply
    final adjustmentFilter = _getAdjustmentFilter();
    final specificFilter = _getFilterMatrix();

    return Column(
      children: [
        // The main image preview area, applying all filters.
        AspectRatio(
          aspectRatio: 4 / 3,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.0),
            child: ColorFiltered(
              colorFilter: specificFilter ?? const ColorFilter.mode(Colors.transparent, BlendMode.color), // Apply specific filter (e.g., B&W)
              child: ColorFiltered(
                colorFilter: adjustmentFilter, // Apply slider adjustments
                child: _buildImageWidget(placeholderImageUrl),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        // The tab selector (AI Tools, Filters, Adjust).
        _buildTabSelector(),
        const SizedBox(height: 24),
        // The content that changes based on the selected tab.
        IndexedStack(
          index: _selectedTabIndex,
          children: [
            _buildAiToolsGrid(),
            _buildFiltersGrid(placeholderImageUrl),
            _buildAdjustmentsList(),
          ],
        ),
        const SizedBox(height: 24),
        _buildSectionTitle('Recent Edits'),
        const SizedBox(height: 16),
        _buildRecentEdits(),
      ],
    );
  }

  // Helper for creating a single adjustment slider row.
  Widget _buildSliderRow(String title, IconData icon, double value, ValueChanged<double> onChanged) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey.shade600),
            const SizedBox(width: 12),
            Text(title, style: const TextStyle(fontSize: 14)),
            Expanded(
              child: Slider(
                value: value,
                onChanged: onChanged,
                min: 0.0,
                max: 1.0,
                activeColor: Theme.of(context).primaryColor,
                inactiveColor: Theme.of(context).primaryColor.withOpacity(0.2),
              ),
            ),
            Text('${(value * 100).toInt()}%', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
      );
  }

  // Helper for Rotate and Crop buttons.
  Widget _buildUtilButton(String text, IconData icon, VoidCallback onTap) {
      return OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 20),
        label: Text(text),
        style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            foregroundColor: Colors.black87,
            side: BorderSide(color: Colors.grey.shade300),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
  }

  // The grid of photo filter options.
  Widget _buildFiltersGrid(String placeholderImageUrl) {
      final filters = ['Original', 'Vintage', 'Dramatic', 'Vibrant', 'B&W', 'Warm'];
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            _buildSectionTitle('Photo Filters'),
            const SizedBox(height: 16),
          GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.8,
            ),
            itemCount: filters.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final isSelected = _selectedFilterIndex == index;
              return GestureDetector(
                onTap: () => _applyFilter(index), // Use the new apply filter method
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
                          width: 3,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(9),
                        child: Builder(
                          builder: (context) {
                            final Widget img = _selectedFile != null
                                ? Image.file(
                                    File(_selectedFile!.path),
                                    fit: BoxFit.cover,
                                    errorBuilder: (c, e, s) => const Center(child: Icon(Icons.broken_image, color: Colors.red)),
                                  )
                                : Image.network(
                                    // Use the placeholder image for the preview tiles
                                    'https://picsum.photos/seed/${filters[index]}/200/300',
                                    fit: BoxFit.cover,
                                    loadingBuilder: (c, child, progress) {
                                      if (progress == null) return child;
                                      return const Center(child: CircularProgressIndicator());
                                    },
                                    errorBuilder: (c, e, s) => const Center(child: Icon(Icons.error_outline, color: Colors.red)),
                                  );

                            if (index == 4) {
                              // Wrap the preview with ColorFiltered for the B&W tile
                              return ColorFiltered(
                                colorFilter: _getFilterMatrix() ?? const ColorFilter.mode(Colors.transparent, BlendMode.srcOver),
                                child: img,
                              );
                            }
                            return img;
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(filters[index], style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, fontSize: 13)),
                  ],
                ),
              );
            },
          ),
            const SizedBox(height: 20),
          _buildActionButtons(),
        ],
      );
  }

  // The list of manual adjustment sliders.
  Widget _buildAdjustmentsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Manual Adjustments'),
        const SizedBox(height: 16),
        _buildSliderRow('Brightness', Icons.brightness_6_outlined, _brightness, (val) => setState(() => _brightness = val)),
        _buildSliderRow('Contrast', Icons.contrast_outlined, _contrast, (val) => setState(() => _contrast = val)),
        _buildSliderRow('Saturation', Icons.color_lens_outlined, _saturation, (val) => setState(() => _saturation = val)),
        const SizedBox(height: 20),
        Row(
            children: [
                // Crop button now calls the functional crop method
                Expanded(child: _buildUtilButton('Crop', Icons.crop_outlined, _cropImage)), 
                const SizedBox(width: 16),
                // Rotate is often integrated into the crop tool, but we can keep a separate button
                Expanded(child: _buildUtilButton('Rotate', Icons.rotate_90_degrees_ccw_outlined, () => _runAiFeature('Rotate'))), 
            ],
        ),
        const SizedBox(height: 20),
        _buildActionButtons(),
      ],
    );
  }

  // The AI tool grid now calls the simulated process for features
  Widget _buildAiToolsGrid() {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('AI Enhancements'),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.1,
            children: [
              // All AI tools now call the simulated loading process
              _buildAiCard('Auto Enhance', 'AI-powered automatic enhancement', Icons.auto_awesome, Colors.purple, () => _runAiFeature('Auto Enhance')),
              _buildAiCard('Remove Background', 'Smart background removal', Icons.crop_free, Colors.blue, () => _runAiFeature('Remove Background')),
              _buildAiCard('Upscale Quality', 'Increase image resolution', Icons.hd, Colors.green, () => _runAiFeature('Upscale Quality')),
              _buildAiCard('Restore Details', 'Recover lost details', Icons.filter_vintage, Colors.orange, () => _runAiFeature('Restore Details')),
            ],
          ),
          const SizedBox(height: 20),
          _buildActionButtons(),
        ],
    );
  }

  // The upload prompt now uses the functional methods
  Widget _buildUploadPrompt() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                colors: [Color.fromARGB(255, 165, 77, 248), Color.fromARGB(255, 243, 211, 252)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                Image.asset('assets/camera_icon.png', height: 60, errorBuilder: (c, e, s) => const Icon(Icons.camera_alt, size: 60, color: Colors.white)),
                const SizedBox(height: 16),
                const Text(
                  'Enhance Your Travel Photos',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Upload a photo to start enhancing with AI-powered tools',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildUploadButton('Take Photo', Icons.camera_alt_outlined, _takePhoto),
                    const SizedBox(width: 16),
                    _buildUploadButton('Upload', Icons.upload_file_outlined, _pickImage),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('Recent Edits'),
          const SizedBox(height: 16),
          _buildRecentEdits(),
          const SizedBox(height: 24),
          _buildProTipsCard(),
        ],
      );
  }

  // All other helper methods remain the same.

  // Helper for a single AI tool card.
  Widget _buildAiCard(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 10,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const Spacer(),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 4),
              Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            ],
          ),
        ),
      );
  }

  // A generic helper for building section titles.
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
    );
  }

  // Builds the top AppBar.
  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent, // Use transparent for a clean look over the custom background
      elevation: 0,
    
      title: const Text(
        'Photo Enhancer',
        style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      actions: _isImageLoaded
          ? [
              IconButton(
                icon: const Icon(Icons.download_outlined, color: Colors.black54),
                onPressed: _saveImage,
              ),
              IconButton(
                icon: const Icon(Icons.share_outlined, color: Colors.black54),
                onPressed: () {},
              ),
            ]
          : [
              const Icon(Icons.auto_awesome_outlined, color: Color(0xFF8A2BE2)),
              const SizedBox(width: 16),
            ],
    );
  }
  
  // A helper to build the buttons inside the gradient card.
  Widget _buildUploadButton(String text, IconData icon, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.deepPurple,
        backgroundColor: Colors.white.withOpacity(0.9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    );
  }
  
  // Builds the horizontal list of recently edited photos.
  Widget _buildRecentEdits() {
    final recentImages = [
        'https://picsum.photos/seed/travel/200/300',
        'https://picsum.photos/seed/lights/200/300',
        'https://picsum.photos/seed/beach/200/300',
    ];
    final recentTitles = ['Mountain Sunset', 'Northern Lights', 'Beach Paradise'];

    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.only(right: 16.0), // Add spacing between cards
          child: Card(
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: SizedBox(
              width: 110,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Image.network(
                        recentImages[index], 
                        fit: BoxFit.cover, 
                        width: double.infinity,
                        errorBuilder: (c, e, s) => const Center(child: Icon(Icons.error_outline, color: Colors.red)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(recentTitles[index], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  // Builds the "Pro Tips" card.
  Widget _buildProTipsCard() {
      return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFE0F2F1),
            borderRadius: BorderRadius.circular(16)
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Row(
                    children: const [
                        Icon(Icons.lightbulb, color: Color(0xFF00796B)),
                        SizedBox(width: 8),
                        Text('Pro Tips', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF00796B))),
                    ],
                ),
                const SizedBox(height: 12),
                _buildTipRow('Use AI Auto Enhance for quick improvements'),
                _buildTipRow('Remove backgrounds for social media posts'),
                _buildTipRow('Try different filters to set the mood'),
                _buildTipRow('Adjust brightness for better visibility'),
            ],
          ),
      );
  }

  // Helper for a single tip item.
  Widget _buildTipRow(String text) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                const Text('• ', style: TextStyle(color: Color(0xFF004D40))),
                Expanded(child: Text(text, style: const TextStyle(color: Color(0xFF004D40)))),
            ],
        ),
      );
  }
  
  // Builds the tab selector widget.
  Widget _buildTabSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildTabItem(0, 'AI Tools'),
          _buildTabItem(1, 'Filters'),
          _buildTabItem(2, 'Adjust'),
        ],
      ),
    );
  }

  // Helper for creating a single tab item.
  Widget _buildTabItem(int index, String text) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 5,
                        spreadRadius: 1)
                  ]
                : [],
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.deepPurple : Colors.grey.shade600,
            ),
          ),
        ),
      ),
    );
  }

  // Builds the "New Photo" and "Save" buttons.
  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _loadNewPhoto,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              foregroundColor: Colors.black87,
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('New Photo', style: TextStyle(fontSize: 16)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _saveImage,
            icon: const Icon(Icons.download, size: 20),
            label: const Text('Save Enhanced', style: TextStyle(fontSize: 16)),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: const Color(0xFF8A2BE2),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              shadowColor: Colors.deepPurple.withOpacity(0.4),
            ),
          ),
        ),
      ],
    );
  }

  // Builds the loading overlay with a message.
  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16)
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 20),
                Text(_loadingMessage, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
              ],
            ),
        ),
      ),
    );
  }

}