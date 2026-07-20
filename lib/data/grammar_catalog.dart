import 'package:flutter/material.dart';

import '../models/grammar_navigation.dart';
import '../screens/articles_category_screen.dart';
import '../screens/future_game_screen.dart';
import '../screens/verbs_category_screen.dart';
import '../screens/verleden_tijd_category_screen.dart';
import '../screens/voltooid_deelwoord_category_screen.dart';
import '../services/article_question_generator.dart';
import '../services/pronoun_question_generator.dart';
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
      title: 'grammar',
      description: 'grammarSubtitle',
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
      title: 'deHet',
      description: 'deHetDescription',
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
    GrammarExercise(
      title: 'dezeDit',
      description: 'dezeDitDescription',
      icon: Icons.touch_app_rounded,
      glowColor: const Color(0xFF4CFF6B),
      destinationBuilder: (_) => const FutureGameScreen(
        title: 'Deze / Dit',
        instruction: 'instructionDezeDit',
        questionsLoader: ArticleQuestionGenerator.generateDezeDitQuestions,
        categoryId: 'articles',
        categoryTitle: 'Lidwoorden',
        exerciseId: 'deze_dit',
      ),
    ),
    GrammarExercise(
      title: 'dieDat',
      description: 'dieDatDescription',
      icon: Icons.near_me_rounded,
      glowColor: const Color(0xFFFFD25B),
      destinationBuilder: (_) => const FutureGameScreen(
        title: 'Die / Dat',
        instruction: 'instructionDieDat',
        questionsLoader: ArticleQuestionGenerator.generateDieDatQuestions,
        categoryId: 'articles',
        categoryTitle: 'Lidwoorden',
        exerciseId: 'die_dat',
      ),
    ),
    GrammarExercise(
      title: 'possessivePronouns',
      description: 'possessivePronounsDescription',
      icon: Icons.person_rounded,
      glowColor: const Color(0xFFB56CFF),
      destinationBuilder: (_) => const FutureGameScreen(
        title: 'Possessive Pronouns',
        instruction: 'instructionPossessivePronouns',
        questionsLoader:
            PronounQuestionGenerator.generatePossessivePronounQuestions,
        categoryId: 'pronouns',
        categoryTitle: 'Voornaamwoorden',
        exerciseId: 'possessive_pronouns',
      ),
    ),
    GrammarExercise(
      title: 'personalPronouns',
      description: 'personalPronounsDescription',
      icon: Icons.face_rounded,
      glowColor: const Color(0xFF2FD4FF),
      destinationBuilder: (_) => const FutureGameScreen(
        title: 'Personal Pronouns',
        instruction: 'instructionPersonalPronouns',
        questionsLoader:
            PronounQuestionGenerator.generatePersonalPronounQuestions,
        categoryId: 'pronouns',
        categoryTitle: 'Voornaamwoorden',
        exerciseId: 'personal_pronouns',
      ),
    ),
    GrammarExercise(
      title: 'mixedMode',
      description: 'mixedModeDescription',
      icon: Icons.shuffle_rounded,
      glowColor: const Color(0xFFB56CFF),
      destinationBuilder: (_) => const FutureGameScreen(
        title: 'Mixed Mode',
        instruction: 'instructionMixedGrammar',
        questionsLoader: ArticleQuestionGenerator.generateMixedGrammarQuestions,
        categoryId: 'grammar',
        categoryTitle: 'Grammatica',
        exerciseId: 'mixed_grammar',
      ),
    ),
  ];
}
