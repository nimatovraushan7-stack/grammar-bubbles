import 'package:flutter/material.dart';

import '../models/grammar_question.dart';
import 'game_screen.dart';

class FutureGameScreen extends StatefulWidget {
  final String title;
  final String instruction;
  final Future<List<GrammarQuestion>> Function() questionsLoader;

  const FutureGameScreen({
    super.key,
    required this.title,
    required this.instruction,
    required this.questionsLoader,
  });

  @override
  State<FutureGameScreen> createState() => _FutureGameScreenState();
}

class _FutureGameScreenState extends State<FutureGameScreen> {
  late final Future<List<GrammarQuestion>> questionsFuture =
      widget.questionsLoader();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<GrammarQuestion>>(
      future: questionsFuture,
      builder: (context, snapshot) {
        final questions = snapshot.data;
        if (questions == null) {
          return const Scaffold(
            backgroundColor: Color(0xFF061B2A),
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFF2FD4FF),
              ),
            ),
          );
        }

        return GameScreen(
          title: widget.title,
          instruction: widget.instruction,
          questions: questions,
        );
      },
    );
  }
}
