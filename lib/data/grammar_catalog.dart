import 'package:flutter/material.dart';

import '../models/grammar_navigation.dart';
import '../screens/articles_category_screen.dart';
import '../screens/future_game_screen.dart';
import '../screens/verbs_category_screen.dart';
import '../screens/verleden_tijd_category_screen.dart';
import '../screens/voltooid_deelwoord_category_screen.dart';
import '../services/article_question_generator.dart';
import '../services/question_generator.dart';

class GrammarCatalog {
  static final List<GrammarCategory> categories = [
    GrammarCategory(
      title: 'Werkwoorden',
      description: 'Werkwoordsvormen, tijden en herhaling',
      icon: Icons.menu_book_rounded,
      glowColor: const Color(0xFF2FD4FF),
      destinationBuilder: (_) => const VerbsCategoryScreen(),
    ),
    GrammarCategory(
      title: 'Lidwoorden',
      description: 'Oefen de, het en andere lidwoordpatronen',
      icon: Icons.article_rounded,
      glowColor: const Color(0xFF4CFF6B),
      destinationBuilder: (_) => const ArticlesCategoryScreen(),
    ),
  ];

  static final List<GrammarExercise> verbExercises = [
    GrammarExercise(
      title: 'Voltooid deelwoord',
      description: 'Oefen voltooid deelwoord vormen',
      icon: Icons.auto_awesome_rounded,
      glowColor: const Color(0xFF2FD4FF),
      destinationBuilder: (_) => const VoltooidDeelwoordCategoryScreen(),
    ),
    GrammarExercise(
      title: 'Verleden tijd',
      description: 'Oefen verleden tijd vormen',
      icon: Icons.history_rounded,
      glowColor: const Color(0xFF4CFF6B),
      destinationBuilder: (_) => const VerledenTijdCategoryScreen(),
    ),
    GrammarExercise(
      title: 'separableVerbs',
      description: 'separableVerbsDescription',
      icon: Icons.call_split_rounded,
      glowColor: const Color(0xFFFFD25B),
      destinationBuilder: (_) => const FutureGameScreen(
        title: 'Scheidbare Werkwoorden',
        instruction: 'instructionSeparableVerb',
        questionsLoader: QuestionGenerator.generateSeparableVerbQuestions,
        categoryId: 'verbs',
        categoryTitle: 'Werkwoorden',
        exerciseId: 'separable_verbs',
      ),
    ),
    GrammarExercise(
      title: 'Gemengd',
      description: 'mixedVerbsDescription',
      icon: Icons.shuffle_rounded,
      glowColor: const Color(0xFFB56CFF),
      destinationBuilder: (_) => const FutureGameScreen(
        title: 'Werkwoorden - Gemengd',
        instruction: 'instructionPastParticiple',
        questionsLoader: QuestionGenerator.generateMixedVerbQuestions,
        categoryId: 'verbs',
        categoryTitle: 'Werkwoorden',
        exerciseId: 'mixed_verbs',
      ),
    ),
  ];

  static final List<GrammarExercise> articleExercises = [
    GrammarExercise(
      title: 'De / Het',
      description: 'Kies het juiste Nederlandse lidwoord',
      icon: Icons.article_rounded,
      glowColor: const Color(0xFF2FD4FF),
      destinationBuilder: (_) => const FutureGameScreen(
        title: 'De / Het',
        instruction: 'instructionDeHet',
        questionsLoader: ArticleQuestionGenerator.generateDeHetQuestions,
        categoryId: 'articles',
        categoryTitle: 'Lidwoorden',
        exerciseId: 'de_het',
      ),
    ),
    const GrammarExercise(
      title: 'Deze / Dit',
      description: 'Binnenkort',
      icon: Icons.touch_app_rounded,
      glowColor: Color(0xFF4CFF6B),
      comingSoon: true,
    ),
    const GrammarExercise(
      title: 'Die / Dat',
      description: 'Binnenkort',
      icon: Icons.near_me_rounded,
      glowColor: Color(0xFFFFD25B),
      comingSoon: true,
    ),
    const GrammarExercise(
      title: 'Mijn / Mij',
      description: 'Binnenkort',
      icon: Icons.person_rounded,
      glowColor: Color(0xFFB56CFF),
      comingSoon: true,
    ),
    const GrammarExercise(
      title: 'Hem / Zijn',
      description: 'Binnenkort',
      icon: Icons.face_rounded,
      glowColor: Color(0xFF2FD4FF),
      comingSoon: true,
    ),
    const GrammarExercise(
      title: 'Haar / Zijn',
      description: 'Binnenkort',
      icon: Icons.face_3_rounded,
      glowColor: Color(0xFF4CFF6B),
      comingSoon: true,
    ),
    const GrammarExercise(
      title: 'Gemengd',
      description: 'Binnenkort',
      icon: Icons.shuffle_rounded,
      glowColor: Color(0xFFB56CFF),
      comingSoon: true,
    ),
  ];
}
