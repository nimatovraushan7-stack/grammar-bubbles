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
        exerciseId: 'past_participle_irregular',
        bestScoreCategories: [
          'Voltooid Deelwoord - Onregelmatig',
        ],
        questionsLoader:
            QuestionGenerator.generateOnregelmatigeVoltooidDeelwoordQuestions,
      ),
      regularMode: GrammarModeConfig(
        gameTitle: 'Voltooid Deelwoord - Regelmatig',
        exerciseId: 'past_participle_regular',
        bestScoreCategories: [
          'Voltooid Deelwoord - Regelmatig',
        ],
        questionsLoader:
            QuestionGenerator.generateRegelmatigeVoltooidDeelwoordQuestions,
      ),
      separableMode: GrammarModeConfig(
        gameTitle: 'Voltooid Deelwoord - Scheidbaar',
        exerciseId: 'past_participle_separable',
        bestScoreCategories: [
          'Voltooid Deelwoord - Scheidbaar',
        ],
        questionsLoader:
            QuestionGenerator.generateScheidbareVoltooidDeelwoordQuestions,
      ),
      mixedMode: GrammarModeConfig(
        gameTitle: 'Voltooid Deelwoord - Gemengd',
        exerciseId: 'past_participle_mixed',
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
