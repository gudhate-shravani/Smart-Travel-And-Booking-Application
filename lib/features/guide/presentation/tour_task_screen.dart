import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dotted_path_painter.dart';
import 'package:lottie/lottie.dart';

class TourTaskScreen extends StatefulWidget {
  const TourTaskScreen({super.key});

  @override
  State<TourTaskScreen> createState() => _TourTaskScreenState();
}

class _TourTaskScreenState extends State<TourTaskScreen> {
  int _currentTask = 0;
  final int _totalTasks = 4;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Active Tour: Old Delhi')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                   CustomPaint(
                    painter: DottedPathPainter(),
                    size: Size.infinite,
                  ),
                  AnimatedPositioned(
                    duration: 500.ms,
                    top: (MediaQuery.of(context).size.height * 0.6 / _totalTasks) * _currentTask,
                    left: MediaQuery.of(context).size.width / 2 - 75,
                    child: Lottie.asset('assets/lottie_boy.json', width: 100, height: 100),
                  ),
                ],
              ),
            ),
            
            if(_currentTask < _totalTasks)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text('Task ${_currentTask + 1}: Explain Jama Masjid', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => setState(() {
                        if(_currentTask < _totalTasks) _currentTask++;
                      }),
                      child: const Text('Mark as Completed'),
                    ),
                  ],
                ),
              ),
            ),

            if(_currentTask == _totalTasks)
              Center(
                child: Column(
                  children: [
                     const Text('Tour Successfully Completed!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.green)),
                     const SizedBox(height: 20),
                     ElevatedButton(onPressed: ()=> Navigator.pop(context), child: const Text('Go Back'))
                  ],
                ),
              ).animate().scale(),
          ],
        ),
      ),
    );
  }
}
