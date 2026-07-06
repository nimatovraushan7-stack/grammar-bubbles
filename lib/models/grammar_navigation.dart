import 'package:flutter/material.dart';

class GrammarCategory {
  final String title;
  final String description;
  final IconData icon;
  final Color glowColor;
  final bool comingSoon;
  final WidgetBuilder? destinationBuilder;

  const GrammarCategory({
    required this.title,
    required this.description,
    required this.icon,
    required this.glowColor,
    this.comingSoon = false,
    this.destinationBuilder,
  });
}

class GrammarExercise {
  final String title;
  final String description;
  final IconData icon;
  final Color glowColor;
  final bool comingSoon;
  final WidgetBuilder? destinationBuilder;

  const GrammarExercise({
    required this.title,
    required this.description,
    required this.icon,
    required this.glowColor,
    this.comingSoon = false,
    this.destinationBuilder,
  });
}
