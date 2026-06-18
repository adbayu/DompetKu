import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import 'auth_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _holdController;
  late final Animation<double> _buttonScale;
  late final Animation<double> _heroScale;
  late final Animation<double> _fade;
  var _isCompleting = false;

  @override
  void initState() {
    super.initState();
    _holdController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 650),
        )..addStatusListener((status) {
          if (status == AnimationStatus.completed) _completeOnboarding();
        });
    _buttonScale = Tween<double>(begin: 1, end: 1.18).animate(
      CurvedAnimation(parent: _holdController, curve: Curves.easeOutCubic),
    );
    _heroScale = Tween<double>(begin: 1, end: 18).animate(
      CurvedAnimation(parent: _holdController, curve: Curves.easeInCubic),
    );
    _fade = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: _holdController,
        curve: const Interval(.58, 1, curve: Curves.easeOut),
      ),
    );
  }

  @override
  void dispose() {
    _holdController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    if (_isCompleting) return;
    _isCompleting = true;
    await context.read<AppProvider>().completeOnboarding();
    await Future<void>.delayed(const Duration(milliseconds: 180));
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AuthScreen()),
    );
  }

  void _cancelHold() {
    if (!_isCompleting && _holdController.status != AnimationStatus.completed) {
      _holdController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3F75F2),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _holdController,
          builder: (context, _) {
            return Stack(
              fit: StackFit.expand,
              children: [
                const _BlueBackdrop(),
                FadeTransition(
                  opacity: _fade,
                  child: const _OnboardingContent(),
                ),
                Positioned(
                  right: 30,
                  bottom: 146,
                  child: Semantics(
                    button: true,
                    label: 'Tahan tombol mulai untuk masuk ke halaman login',
                    child: GestureDetector(
                      onLongPressStart: (_) => _holdController.forward(),
                      onLongPressEnd: (_) => _cancelHold(),
                      onLongPressCancel: _cancelHold,
                      child: Transform.scale(
                        scale: _buttonScale.value,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Transform.scale(
                              scale: _heroScale.value,
                              child: const _StartCircle(),
                            ),
                            if (_holdController.value < .92)
                              SizedBox(
                                width: 112,
                                height: 112,
                                child: CircularProgressIndicator(
                                  value: _holdController.value,
                                  strokeWidth: 3,
                                  color: const Color(0xFF3F75F2),
                                  backgroundColor: Colors.transparent,
                                ),
                              ),
                            if (_holdController.value < .72)
                              const Text(
                                'Tahan Mulai',
                                style: TextStyle(
                                  color: Color(0xFF2F6CEF),
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _BlueBackdrop extends StatelessWidget {
  const _BlueBackdrop();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF3F75F2), Color(0xFF447CFA)],
        ),
      ),
      child: CustomPaint(painter: _DiagonalLinePainter()),
    );
  }
}

class _OnboardingContent extends StatelessWidget {
  const _OnboardingContent();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 34),
            child: Column(
              children: [
                RichText(
                  text: const TextSpan(
                    style: TextStyle(fontSize: 26, color: Colors.white70),
                    children: [
                      TextSpan(text: 'Dompet'),
                      TextSpan(
                        text: 'Ku',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
                Text(
                  '“',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: .32),
                    fontSize: 54,
                    height: .6,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Atur Uangmu\nLebih Rapi, Tenang,\nDan Terarah',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    height: 1.28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Catat pemasukan, kontrol pengeluaran,\npantau budget, dan capai target\nkeuangan dari satu aplikasi.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: .84),
                    fontSize: 14,
                    height: 1.25,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 28),
                const _PageDots(),
              ],
            ),
          ),
        ),
        Positioned(
          left: 110,
          right: 0,
          bottom: -10,
          child: Image.asset(
            'assets/images/man-pointing.png',
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}

class _StartCircle extends StatelessWidget {
  const _StartCircle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 112,
      height: 112,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _PageDots extends StatelessWidget {
  const _PageDots();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        3,
        (index) => Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: index == 0 ? .95 : .45),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

class _DiagonalLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: .16)
      ..strokeWidth = 1.6;
    canvas.drawLine(
      Offset(-size.width * .18, size.height * .47),
      Offset(size.width * 1.02, size.height * 1.05),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * .68, -20),
      Offset(size.width * 1.08, size.height * .35),
      paint,
    );
    canvas.drawLine(
      Offset(-size.width * .05, size.height * .97),
      Offset(size.width * .15, size.height * 1.16),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
