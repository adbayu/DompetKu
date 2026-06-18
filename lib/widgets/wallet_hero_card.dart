import 'package:flutter/material.dart';
import '../providers/app_provider.dart';
import '../widgets/currency_text.dart';
import '../utils/localization.dart';

class WalletHeroCard extends StatelessWidget {
  const WalletHeroCard({super.key, required this.provider});

  final AppProvider provider;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 228,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(36),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F3FB9), Color(0xFF1D4ED8), Color(0xFF2563EB)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2F6CEF).withValues(alpha: .24),
            blurRadius: 30,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _CardPatternPainter())),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Image.asset(
                    'assets/images/Logo_Dompetku.png',
                    width: 34,
                    height: 34,
                    errorBuilder: (_, _, _) => const Icon(
                      Icons.account_balance_wallet_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Center(
                child: CurrencyText(
                  provider.totalBalance,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -.7,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      tr(context, 'Saldo DompetKu', 'DompetKu Balance'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CardPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: .10)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width * .2, size.height * .1), 82, paint);
    canvas.drawCircle(Offset(size.width * .85, size.height * .45), 62, paint);
    canvas.drawCircle(Offset(size.width * .45, size.height * .92), 104, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
