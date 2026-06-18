import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import 'home_screen.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..forward();
    _scale = Tween<double>(begin: .86, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    Future.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      final provider = context.read<AppProvider>();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => provider.isFirstTimeOpen
              ? const OnboardingScreen()
              : const HomeScreen(),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2F6CEF), Color(0xFF4C83FF), Color(0xFFB9D0FF)],
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(child: CustomPaint(painter: _SplashLinePainter())),
            Center(
              child: FadeTransition(
                opacity: _fade,
                child: ScaleTransition(
                  scale: _scale,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 104,
                        height: 104,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: .14),
                              blurRadius: 32,
                              offset: const Offset(0, 18),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Image.asset(
                            'assets/images/Logo_Dompetku.png',
                            errorBuilder: (_, _, _) => const Icon(
                              Icons.account_balance_wallet_rounded,
                              color: Color(0xFF2F6CEF),
                              size: 50,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      const Text(
                        'DompetKu',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -.6,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Atur uang, capai tujuan.',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: .86),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 28),
                      const SizedBox(
                        width: 34,
                        height: 34,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SplashLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: .13)
      ..strokeWidth = 1.5;
    canvas.drawCircle(Offset(size.width * .18, size.height * .18), 96, paint);
    canvas.drawCircle(Offset(size.width * .88, size.height * .82), 132, paint);
    canvas.drawLine(
      Offset(-20, size.height * .68),
      Offset(size.width * 1.1, size.height * .25),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
