import 'dart:async';

import 'package:flutter/material.dart';

import '../models/dictionary_entry.dart';
import '../models/grammar_question.dart';
import '../services/favorite_service.dart';
import '../services/localization_service.dart';
import '../services/settings_service.dart';
import '../services/sound_service.dart';
import '../services/translation_service.dart';
import '../utils/dictionary_debug.dart';
import '../widgets/responsive_text.dart';

class DictionaryDetailScreen extends StatefulWidget {
  final DictionaryEntry entry;

  const DictionaryDetailScreen({
    super.key,
    required this.entry,
  });

  @override
  State<DictionaryDetailScreen> createState() => _DictionaryDetailScreenState();
}

class _DictionaryDetailScreenState extends State<DictionaryDetailScreen> {
  late final Future<void> _favoritesReadyFuture;
  late final int _debugId;
  bool showTranslation = false;
  String? translationText;

  DictionaryEntry get entry => widget.entry;
  GrammarQuestion get favoriteQuestion => entry.toFavoriteQuestion();

  @override
  void initState() {
    super.initState();
    _debugId = identityHashCode(this);
    _log('initState word=${entry.word}');
    _favoritesReadyFuture = _initializeFavorites();
  }

  @override
  void dispose() {
    _log(
      'dispose word=${entry.word} showTranslation=$showTranslation '
      'translationText=$translationText',
    );
    super.dispose();
  }

  Future<void> _initializeFavorites() async {
    _log('_initializeFavorites start');
    try {
      await FavoriteService.initialize();
      _log('_initializeFavorites complete');
    } catch (error, stackTrace) {
      _logError('_initializeFavorites failed', error, stackTrace);
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'dictionary',
          context: ErrorDescription(
            'while initializing favorites in Dictionary detail',
          ),
        ),
      );
      rethrow;
    }
  }

  Future<void> _toggleTranslation() async {
    final shouldShowTranslation = !showTranslation;
    _log(
      '_toggleTranslation shouldShow=$shouldShowTranslation '
      'currentText=$translationText',
    );

    setState(() {
      showTranslation = shouldShowTranslation;
      if (shouldShowTranslation) {
        translationText = null;
      }
    });

    if (!shouldShowTranslation) return;

    final translation = await TranslationService.getTranslation(
      entry.word,
      languageCode: SettingsService.getLanguage(),
    );
    _log('_toggleTranslation loaded "$translation" mounted=$mounted');

    if (!mounted || !showTranslation) return;

    setState(() {
      translationText = translation;
    });
  }

  Future<void> _toggleFavorite() async {
    _log('_toggleFavorite start');
    unawaited(SoundService.playClick().catchError((_) {}));
    await _favoritesReadyFuture;
    final question = favoriteQuestion;
    final added = await FavoriteService.toggleFavorite(
      question: question,
      category: entry.category,
      categoryTitle: entry.categoryTitle,
      exercise: entry.favoriteExerciseId,
      exerciseTitle: entry.categoryTitle,
      instruction: question.instructionKey ?? '',
    );
    _log('_toggleFavorite complete added=$added');

    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF061B2A),
          content: ResponsiveText(
            LocalizationService.t(
              added ? 'addedToFavorites' : 'removedFromFavorites',
            ),
            maxLines: 1,
            minFontSize: 11,
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    _log(
      'build word=${entry.word} showTranslation=$showTranslation '
      'translationText=$translationText',
    );
    final l = LocalizationService.t;
    final shownWord = showTranslation && translationText != null
        ? translationText!
        : entry.word;

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
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _IconActionButton(
                          icon: Icons.arrow_back_ios_new_rounded,
                          onTap: () {
                            _log('back button tapped');
                            unawaited(
                              SoundService.playClick().catchError((_) {}),
                            );
                            Navigator.pop(context);
                          },
                        ),
                        const Spacer(),
                        FutureBuilder<void>(
                          future: _favoritesReadyFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState !=
                                ConnectionState.done) {
                              return _IconActionButton(
                                icon: Icons.star_outline_rounded,
                                color: const Color(0xFFFFD25B),
                                onTap: () {},
                              );
                            }

                            if (snapshot.hasError) {
                              debugPrint(
                                'FavoriteService.initialize failed: '
                                '${snapshot.error}',
                              );
                              return _IconActionButton(
                                icon: Icons.star_outline_rounded,
                                color: const Color(0xFFFFD25B),
                                onTap: () {
                                  ScaffoldMessenger.of(context)
                                    ..hideCurrentSnackBar()
                                    ..showSnackBar(
                                      SnackBar(
                                        behavior: SnackBarBehavior.floating,
                                        backgroundColor:
                                            const Color(0xFF061B2A),
                                        content: ResponsiveText(
                                          LocalizationService.t(
                                            'dictionaryLoadFailed',
                                          ),
                                          maxLines: 1,
                                          minFontSize: 11,
                                        ),
                                      ),
                                    );
                                },
                              );
                            }

                            return ValueListenableBuilder(
                              valueListenable: FavoriteService.listenable(),
                              builder: (context, _, __) {
                                final isFavorite = FavoriteService.isFavorite(
                                  question: favoriteQuestion,
                                  category: entry.category,
                                  exercise: entry.favoriteExerciseId,
                                );

                                return _IconActionButton(
                                  icon: isFavorite
                                      ? Icons.star_rounded
                                      : Icons.star_outline_rounded,
                                  color: const Color(0xFFFFD25B),
                                  onTap: _toggleFavorite,
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 42),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _toggleTranslation,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: ScaleTransition(
                              scale: Tween<double>(begin: 0.97, end: 1)
                                  .animate(animation),
                              child: child,
                            ),
                          );
                        },
                        child: ResponsiveText(
                          shownWord.toUpperCase(),
                          key: ValueKey(shownWord),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          minFontSize: 18,
                          style: TextStyle(
                            color: showTranslation && translationText != null
                                ? const Color(0xFF45D7FF)
                                : Colors.white,
                            fontSize: 42,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ResponsiveText(
                      l('tapToTranslate'),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      minFontSize: 9,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.55),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 34),
                    _DetailCard(
                      children: [
                        if (entry.type == DictionaryEntryType.verb) ...[
                          _DetailRow(
                            label: l('presentTense'),
                            value: entry.presentTense ?? '-',
                          ),
                          _DetailRow(
                            label: l('pastTense'),
                            value: entry.pastTense ?? '-',
                          ),
                          _DetailRow(
                            label: l('pastParticiple'),
                            value: entry.pastParticiple ?? '-',
                          ),
                          _DetailRow(
                            label: l('presentParticiple'),
                            value: entry.presentParticiple ?? '-',
                          ),
                        ] else if (entry.type ==
                            DictionaryEntryType.article) ...[
                          _DetailRow(
                            label: l('article'),
                            value: entry.article ?? '-',
                          ),
                          _DetailRow(
                            label: l('demonstrative'),
                            value: entry.demonstrative ?? '-',
                          ),
                        ] else ...[
                          _DetailRow(
                            label: l('dictionarySource'),
                            value: entry.source,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _log(String message) {
    DictionaryDebug.log('DictionaryDetail#$_debugId', message);
  }

  void _logError(String message, Object error, StackTrace stackTrace) {
    DictionaryDebug.error(
      'DictionaryDetail#$_debugId',
      error,
      stackTrace,
      context: message,
    );
  }
}

class _DetailCard extends StatelessWidget {
  final List<Widget> children;

  const _DetailCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xF01A3145),
            Color.alphaBlend(
              const Color(0xFF2FD4FF).withOpacity(0.12),
              const Color(0xF0122638),
            ),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF2FD4FF).withOpacity(0.28),
        ),
      ),
      child: Column(
        children: children,
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Row(
        children: [
          Expanded(
            child: ResponsiveText(
              label,
              maxLines: 1,
              minFontSize: 10,
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ResponsiveText(
              value,
              textAlign: TextAlign.end,
              maxLines: 1,
              minFontSize: 11,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IconActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const _IconActionButton({
    required this.icon,
    required this.onTap,
    this.color = const Color(0xFF2FD4FF),
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
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
                  color.withOpacity(0.18),
                  const Color(0xF0122638),
                ),
              ],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: color.withOpacity(0.38),
            ),
          ),
          child: Icon(
            icon,
            color: color,
            size: 22,
          ),
        ),
      ),
    );
  }
}
