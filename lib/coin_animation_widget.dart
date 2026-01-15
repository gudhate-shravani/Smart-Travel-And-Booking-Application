import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';

class CoinAnimation extends StatefulWidget {
  const CoinAnimation({super.key});
  
  @override
  _CoinAnimationState createState() => _CoinAnimationState();
}

class _CoinAnimationState extends State<CoinAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;
  late Duration _delay;

  @override
  void initState() {
    super.initState();
    final random = Random();
    _delay = Duration(milliseconds: random.nextInt(800));
    _controller = AnimationController(vsync: this, duration: 1500.ms);
    
    final startX = random.nextDouble() * 2.0 - 1.0;
    
    _animation = Tween<Offset>(
      begin: Offset(startX, 1.1),
      end: const Offset(1.0, -1.1),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    
    Future.delayed(_delay, () {
      if(mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _animation,
      child: Lottie.asset('assets/lottie_coins.json', width: 50, height: 50),
    );
  }
}
