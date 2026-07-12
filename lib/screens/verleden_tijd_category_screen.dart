import 'package:flutter/material.dart';

import '../services/question_generator.dart';
import 'grammar_mode_category_screen.dart';

class VerledenTijdCategoryScreen extends StatelessWidget {
  const VerledenTijdCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const GrammarModeCategoryScreen(
      titleKey: 'pastTense',
      instructionKey: 'instructionPastTense',
      irregularMode: GrammarModeConfig(
        gameTitle: 'Verleden Tijd - Onregelmatig',
        exerciseId: 'past_tense_irregular',
        bestScoreCategories: [
          'Verleden Tijd - Onregelmatig',
        ],
        questionsLoader:
            QuestionGenerator.generateOnregelmatigeVerledenTijdQuestions,
      ),
      regularMode: GrammarModeConfig(
        gameTitle: 'Verleden Tijd - Regelmatig',
        exerciseId: 'past_tense_regular',
        bestScoreCategories: [
          'Verleden Tijd - Regelmatig',
        ],
        questionsLoader:
            QuestionGenerator.generateRegelmatigeVerledenTijdQuestions,
      ),
      separableMode: GrammarModeConfig(
        gameTitle: 'Verleden Tijd - Scheidbaar',
        exerciseId: 'past_tense_separable',
        bestScoreCategories: [
          'Verleden Tijd - Scheidbaar',
        ],
        questionsLoader:
            QuestionGenerator.generateScheidbareVerledenTijdQuestions,
      ),
      mixedMode: GrammarModeConfig(
        gameTitle: 'Verleden Tijd - Gemengd',
        exerciseId: 'past_tense_mixed',
        bestScoreCategories: [
          'Verleden Tijd',
          'Verleden Tijd - Gemengd',
        ],
        questionsLoader:
            QuestionGenerator.generateGemengdeVerledenTijdQuestions,
      ),
    );
  }
}
