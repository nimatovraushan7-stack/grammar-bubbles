import 'package:flutter/material.dart';

import 'responsive_text.dart';

class GrammarMenuCard extends StatefulWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color glowColor;
  final bool comingSoon;
  final VoidCallback onTap;

  const GrammarMenuCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.glowColor,
    required this.onTap,
    this.comingSoon = false,
  });

  @override
  State<GrammarMenuCard> createState() => _GrammarMenuCardState();
}

class _GrammarMenuCardState extends State<GrammarMenuCard> {
  bool _pressed = false;
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final scale = _pressed ? 0.985 : (_hovered ? 1.015 : 1.0);
    final opacity = widget.comingSoon ? 0.56 : 1.0;

    return AnimatedScale(
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOut,
      scale: scale,
      child: Opacity(
        opacity: opacity,
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: widget.onTap,
            onTapDown: (_) => setState(() => _pressed = true),
            onTapCancel: () => setState(() => _pressed = false),
            onTapUp: (_) => setState(() => _pressed = false),
            onHover: (value) => setState(() => _hovered = value),
            splashColor: widget.glowColor.withOpacity(0.12),
            highlightColor: widget.glowColor.withOpacity(0.06),
            child: Ink(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xF01A3145),
                    Color.alphaBlend(
                      widget.glowColor.withOpacity(0.18),
                      const Color(0xF0122638),
                    ),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: widget.glowColor.withOpacity(0.38),
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.glowColor.withOpacity(0.12),
                    blurRadius: 22,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: widget.glowColor.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(17),
                      border: Border.all(
                        color: widget.glowColor.withOpacity(0.32),
                      ),
                    ),
                    child: Icon(
                      widget.icon,
                      color: widget.glowColor,
                      size: 27,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ResponsiveText(
                          widget.title,
                          maxLines: 2,
                          minFontSize: 14,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        ResponsiveText(
                          widget.description,
                          maxLines: 2,
                          minFontSize: 10,
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(
                    widget.comingSoon
                        ? Icons.hourglass_top_rounded
                        : Icons.arrow_forward_ios_rounded,
                    color: widget.glowColor,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
