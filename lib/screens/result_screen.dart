import 'package:flutter/material.dart';

import '../services/sound_service.dart';

class ResultScreen extends StatefulWidget {
  final String category;
  final int score;
  final int totalQuestions;

  const ResultScreen({
    super.key,
    required this.category,
    required this.score,
    required this.totalQuestions,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  @override
  void initState() {
    super.initState();
    SoundService.playVictory();
  }

  @override
  Widget build(BuildContext context) {
    double percentage = widget.score / widget.totalQuestions;

    int starCount = 0;

    if (percentage >= 0.9) {
      starCount = 3;
    } else if (percentage >= 0.7) {
      starCount = 2;
    } else if (widget.score > 0) {
      starCount = 1;
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              'assets/images/ocean_background.png',
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          color: Colors.black.withOpacity(0.3),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.category,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Resultaat',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 20),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) {
                    final isEarned = index < starCount;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(
                        isEarned
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        color: isEarned
                            ? const Color(0xFFFFD25B)
                            : Colors.white.withOpacity(0.30),
                        size: 60,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 30),
                Text(
                  '${widget.score} / ${widget.totalQuestions}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '${(percentage * 100).toInt()}%',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 60),
                SizedBox(
                  width: 260,
                  child: ElevatedButton(
                    onPressed: () async {
                      await SoundService.playClick();
                      if (!context.mounted) return;

                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2FD4FF),
                      shadowColor: const Color(0xFF2FD4FF),
                      elevation: 15,
                      padding: const EdgeInsets.symmetric(
                        vertical: 18,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Opnieuw spelen',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: 260,
                  child: OutlinedButton(
                    onPressed: () async {
                      await SoundService.playClick();
                      if (!context.mounted) return;

                      Navigator.popUntil(
                        context,
                        (route) => route.isFirst,
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: Colors.white.withOpacity(0.3),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 18,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          20,
                        ),
                      ),
                    ),
                    child: const Text(
                      'Dashboard',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
