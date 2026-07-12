import 'package:flutter/material.dart';

import '../models/grammar_navigation.dart';
import '../services/localization_service.dart';
import '../services/sound_service.dart';
import '../widgets/grammar_menu_card.dart';
import '../widgets/responsive_text.dart';

class GrammarMenuScreen extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<GrammarExercise> exercises;

  const GrammarMenuScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.exercises,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SizedBox.expand(
        child: DecoratedBox(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/ocean_background.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            color: Colors.black.withOpacity(0),
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                _IconActionButton(
                                  icon: Icons.arrow_back_ios_new_rounded,
                                  onTap: () async {
                                    await SoundService.playClick();
                                    if (!context.mounted) return;
                                    Navigator.pop(context);
                                  },
                                ),
                                const Spacer(),
                              ],
                            ),
                            const SizedBox(height: 26),
                            ResponsiveText(
                              title,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              minFontSize: 16,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.2,
                                shadows: [
                                  Shadow(
                                    color: Color(0xAA001018),
                                    blurRadius: 16,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            ResponsiveText(
                              subtitle,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              minFontSize: 10,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 36),
                            ...exercises.expand(
                              (exercise) => [
                                GrammarMenuCard(
                                  title: LocalizationService.t(exercise.title),
                                  description: LocalizationService.t(
                                    exercise.description,
                                  ),
                                  icon: exercise.icon,
                                  glowColor: exercise.glowColor,
                                  comingSoon: exercise.comingSoon,
                                  onTap: () => _openExercise(
                                    context,
                                    exercise,
                                  ),
                                ),
                                const SizedBox(height: 20),
                              ],
                            ),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openExercise(
    BuildContext context,
    GrammarExercise exercise,
  ) async {
    await SoundService.playClick();
    if (!context.mounted) return;

    final destinationBuilder = exercise.destinationBuilder;
    if (exercise.comingSoon || destinationBuilder == null) {
      await showComingSoonDialog(context);
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: destinationBuilder,
      ),
    );
  }
}

Future<void> showComingSoonDialog(BuildContext context) {
  const glowColor = Color(0xFF2FD4FF);

  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Binnenkort',
    barrierColor: Colors.black.withOpacity(0.55),
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (dialogContext, animation, secondaryAnimation) {
      return Material(
        color: Colors.transparent,
        child: SafeArea(
          child: Center(
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 360),
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF073B52).withOpacity(0.94),
                    const Color(0xFF061B2A).withOpacity(0.96),
                    const Color(0xFF020B12).withOpacity(0.98),
                  ],
                ),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: glowColor.withOpacity(0.45),
                  width: 1.4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: glowColor.withOpacity(0.28),
                    blurRadius: 34,
                    spreadRadius: 2,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.42),
                    blurRadius: 28,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 74,
                    height: 74,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: glowColor.withOpacity(0.16),
                      border: Border.all(
                        color: glowColor.withOpacity(0.42),
                      ),
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      color: glowColor,
                      size: 38,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const ResponsiveText(
                    'Binnenkort',
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    minFontSize: 22,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const ResponsiveText(
                    'Deze grammatica-oefening komt beschikbaar in een toekomstige update.\n\nBlijf oefenen!',
                    textAlign: TextAlign.center,
                    maxLines: 5,
                    minFontSize: 13,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      height: 1.35,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      style: FilledButton.styleFrom(
                        backgroundColor: glowColor,
                        foregroundColor: const Color(0xFF05212A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: const ResponsiveText(
                        'OK',
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutBack,
      );

      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.94, end: 1).animate(curvedAnimation),
          child: child,
        ),
      );
    },
  );
}

class _IconActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconActionButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const glowColor = Color(0xFF2FD4FF);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: glowColor.withOpacity(0.12),
        highlightColor: glowColor.withOpacity(0.06),
        child: Ink(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xF01A3145),
                Color.alphaBlend(
                  glowColor.withOpacity(0.18),
                  const Color(0xF0122638),
                ),
              ],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: glowColor.withOpacity(0.38),
            ),
          ),
          child: Icon(
            icon,
            color: glowColor,
            size: 20,
          ),
        ),
      ),
    );
  }
}
