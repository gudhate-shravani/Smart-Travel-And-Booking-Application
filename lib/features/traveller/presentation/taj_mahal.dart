import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:audioplayers/audioplayers.dart';



class TajMahalStreetViewApp extends StatelessWidget {
  const TajMahalStreetViewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Taj Mahal Virtual Tour",
      theme: ThemeData(
        primaryColor: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueAccent,
          primary: Colors.deepPurple,
          secondary: Colors.blueAccent,
        ),
      ),
      home: const StreetViewWithAudio(),
    );
  }
}

class StreetViewWithAudio extends StatefulWidget {
  const StreetViewWithAudio({super.key});

  @override
  State<StreetViewWithAudio> createState() => _StreetViewWithAudioState();
}

class _StreetViewWithAudioState extends State<StreetViewWithAudio> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isPlaying = false;

  final String streetViewHTML = '''
    <html>
      <body style="margin:0;padding:0;overflow:hidden;">
        <iframe width="100%" height="100%" frameborder="0" style="border:0"
          src="https://www.google.com/maps/embed/v1/streetview?key=AIzaSyC-d7WK6cZDT0RIbWhnwGjRLkrKPR3IPCY&location=27.1751,78.0421&heading=210&pitch=10&fov=90"
          allowfullscreen>
        </iframe>
      </body>
    </html>
  ''';

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> toggleAudio() async {
    if (isPlaying) {
      await _audioPlayer.stop();
    } else {
      await _audioPlayer.play(AssetSource('audio/narration_sample.wav'));
    }
    setState(() => isPlaying = !isPlaying);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Taj Mahal Virtual Tour",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 6,
        backgroundColor: Colors.deepPurple.shade400,
      ),
      body: Column(
        children: [
          // --- STREET VIEW SECTION ---
          Expanded(
            flex: 8,
            child: WebViewWidget(
              controller: WebViewController()
                ..setJavaScriptMode(JavaScriptMode.unrestricted)
                ..loadHtmlString(streetViewHTML),
            ),
          ),

          // --- AUDIO PLAYER PANEL ---
          Expanded(
            flex: 3,
            child: SafeArea(
              top: false,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.deepPurple.shade300, Colors.blueAccent.shade200],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "ðŸŽ§ Taj Mahal Audio Guide",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Discover the beauty, architecture, and history of the Taj Mahal through our immersive audio narration.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.deepPurple,
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 20),
                          elevation: 6,
                        ),
                        onPressed: toggleAudio,
                        icon: Icon(
                          isPlaying ? Icons.stop_circle_outlined : Icons.play_arrow_rounded,
                          size: 30,
                        ),
                        label: Text(
                          isPlaying ? "Stop Audio" : "Play Audio Guide",
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}