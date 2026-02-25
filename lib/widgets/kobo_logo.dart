import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class KoboLogo extends StatelessWidget {
  final double size;
  final bool showTagline;
  final Color? color;

  const KoboLogo({
    super.key,
    this.size = 48,
    this.showTagline = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              'KOBO',
              style: GoogleFonts.outfit(
                fontSize: size,
                fontWeight: FontWeight.w900,
                color: color ?? const Color(0xFF27ae60),
                letterSpacing: -2,
                height: 1.0,
              ),
            ),
            Text(
              '.',
              style: GoogleFonts.outfit(
                fontSize: size,
                fontWeight: FontWeight.w900,
                color: const Color(0xFFe67e22), // Accent orange dot
                height: 1.0,
              ),
            ),
          ],
        ),
        if (showTagline) ...[
          SizedBox(height: size * 0.1),
          Text(
            'BUSINESS MANAGER',
            style: GoogleFonts.inter(
              fontSize: size * 0.2,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF95a5a6),
              letterSpacing: size * 0.05,
            ),
          ),
        ],
      ],
    );
  }
}
