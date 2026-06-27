import 'package:flutter/material.dart';

class AnswerBubble extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final String imagePath;

  const AnswerBubble({
    super.key,
    required this.text,
    required this.onTap,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    const double bubbleSize = 120;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: bubbleSize,
        height: bubbleSize,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(
              imagePath,
              width: bubbleSize,
              height: bubbleSize,
              fit: BoxFit.contain,
            ),
            Positioned.fill(
              child: Center(
                child: Transform.translate(
                  offset: const Offset(0, -1),
                  child: Padding(
  padding: const EdgeInsets.symmetric(horizontal: 12),
  child: SizedBox(
    width: 90,
    height: 50,
    child: FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 21,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  ),
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
