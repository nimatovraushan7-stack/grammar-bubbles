import 'package:flutter/material.dart';

import '../data/grammar_catalog.dart';
import '../services/localization_service.dart';
import 'grammar_menu_screen.dart';

class ArticlesCategoryScreen extends StatelessWidget {
  const ArticlesCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GrammarMenuScreen(
      title: LocalizationService.t('articles'),
      subtitle: LocalizationService.t('articlesSubtitle'),
      exercises: GrammarCatalog.articleExercises,
    );
  }
}
