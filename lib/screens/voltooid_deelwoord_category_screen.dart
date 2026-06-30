import 'package:flutter/material.dart';

import '../services/question_generator.dart';
import 'grammar_mode_category_screen.dart';

class VoltooidDeelwoordCategoryScreen extends StatelessWidget {
  const VoltooidDeelwoordCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const GrammarModeCategoryScreen(
      title: 'Voltooid Deelwoord',
      instruction: 'Zoek het voltooid deelwoord van:',
      irregularMode: GrammarModeConfig(
        gameTitle: 'Voltooid Deelwoord - Onregelmatig',
        bestScoreCategories: [
          'Voltooid Deelwoord - Onregelmatig',
        ],
        questionsLoader:
            QuestionGenerator.generateOnregelmatigeVoltooidDeelwoordQuestions,
      ),
      regularMode: GrammarModeConfig(
        gameTitle: 'Voltooid Deelwoord - Regelmatig',
        bestScoreCategories: [
          'Voltooid Deelwoord - Regelmatig',
        ],
        questionsLoader:
            QuestionGenerator.generateRegelmatigeVoltooidDeelwoordQuestions,
      ),
      mixedMode: GrammarModeConfig(
        gameTitle: 'Voltooid Deelwoord - Gemengd',
        bestScoreCategories: [
          'Voltooid Deelwoord',
          'Voltooid Deelwoord - Gemengd',
        ],
        questionsLoader:
            QuestionGenerator.generateGemengdeVoltooidDeelwoordQuestions,
      ),
    );
  }
}
