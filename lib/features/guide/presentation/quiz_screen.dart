import 'package:flutter/material.dart';

class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Knowledge Check')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('What is the Red Fort primarily made of?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            _buildOption(context, 'White Marble'),
            _buildOption(context, 'Red Sandstone'),
            _buildOption(context, 'Granite'),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); 
              },
              child: const Text('Submit & Claim Reward'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(BuildContext context, String text) {
    return Card(
      child: ListTile(
        title: Text(text),
        onTap: () {},
      ),
    );
  }
}
