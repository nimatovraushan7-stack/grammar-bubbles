import 'package:flutter/material.dart';

import '../data/grammar_catalog.dart';
import '../services/localization_service.dart';
import 'grammar_menu_screen.dart';

class VerbsCategoryScreen extends StatelessWidget {
  const VerbsCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final exercises = GrammarCatalog.verbExercises
        .where(
          (exercise) =>
              exercise.destinationBuilder == null ||
              exercise.title == 'Voltooid deelwoord' ||
              exercise.title == 'Verleden tijd',
        )
        .toList(growable: false);

    return GrammarMenuScreen(
      title: LocalizationService.t('verbs'),
      subtitle: LocalizationService.t('verbsSubtitle'),
      exercises: exercises,
    );
  }
}
