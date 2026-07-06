import 'package:flutter/material.dart';

import '../services/question_generator.dart';
import 'grammar_mode_category_screen.dart';

class VoltooidDeelwoordCategoryScreen extends StatelessWidget {
  const VoltooidDeelwoordCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const GrammarModeCategoryScreen(
      titleKey: 'pastParticiple',
      instructionKey: 'instructionPastParticiple',
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
      separableMode: GrammarModeConfig(
        gameTitle: 'Voltooid Deelwoord - Scheidbaar',
        bestScoreCategories: [
          'Voltooid Deelwoord - Scheidbaar',
        ],
        questionsLoader:
            QuestionGenerator.generateScheidbareVoltooidDeelwoordQuestions,
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
