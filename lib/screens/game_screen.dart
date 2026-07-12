import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/grammar_question.dart';
import '../models/quiz_review_item.dart';
import '../services/analytics_service.dart';
import '../services/favorite_service.dart';
import '../services/learning_level_service.dart';
import '../services/localization_service.dart';
import '../services/premium_service.dart';
import '../services/remote_code_service.dart';
import '../services/settings_service.dart';
import '../services/sound_service.dart';
import '../services/translation_service.dart';
import '../widgets/answer_bubble.dart';
import '../widgets/responsive_text.dart';
import 'dashboard_screen.dart';
import 'result_screen.dart';

class GameScreen extends StatefulWidget {
  final String title;
  final String instruction;
  final List<GrammarQuestion> questions;
  final String categoryId;
  final String categoryTitle;
  final String exerciseId;
  final String exerciseTitle;

  const GameScreen({
    super.key,
    required this.title,
    required this.instruction,
    required this.questions,
    this.categoryId = 'general',
    this.categoryTitle = 'Grammar',
    this.exerciseId = 'exercise',
    String? exerciseTitle,
  }) : exerciseTitle = exerciseTitle ?? title;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class BubblePosition {
  final double x;
  final double y;

  BubblePosition(this.x, this.y);
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  static final Uri _privacyPolicyUrl = Uri.parse(
    'https://nimatovraushan7-stack.github.io/bubble-grammar-privacy/',
  );
  static final Uri _termsOfUseUrl = Uri.parse(
    'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/',
  );

  String? selectedAnswer;
  bool selectedAnswerCorrect = false;
  bool timeRanOut = false;
  int currentQuestion = 0;
  int score = 0;
  List<GrammarQuestion> gameQuestions = [];
  int maxTime = SettingsService.defaultQuestionTime;
  int timeLeft = SettingsService.defaultQuestionTime;
  String translationLanguageCode = SettingsService.defaultLanguageCode;
  Timer? timer;
  Timer? feedbackTimer;
  late final AnimationController feedbackController;
  late final Animation<double> feedbackScaleAnimation;
  List<BubblePosition> bubblePositions = [];
  bool showFeedback = false;
  bool answerWasCorrect = false;
  String correctAnswer = '';
  bool showTranslation = false;
  String? translationText;
  final List<QuizReviewItem> reviewItems = [];
  final Set<int> recordedReviewIndexes = {};

  @override
  void initState() {
    super.initState();
    feedbackController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    feedbackScaleAnimation = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(
        parent: feedbackController,
        curve: Curves.easeOutBack,
      ),
    );
    gameQuestions = widget.questions
        .map(
          (question) => question.copyWith(
            instructionKey: question.instructionKey ?? widget.instruction,
            category: question.category ?? widget.categoryId,
            categoryTitle: question.categoryTitle ?? widget.categoryTitle,
            exercise: question.exercise ?? widget.exerciseId,
            exerciseTitle: question.exerciseTitle ?? widget.exerciseTitle,
          ),
        )
        .toList();
    gameQuestions.shuffle();
    if (gameQuestions.length > 15) {
      gameQuestions = gameQuestions.take(15).toList();
    }
    maxTime = SettingsService.getQuestionTime();
    timeLeft = maxTime;
    translationLanguageCode = SettingsService.getLanguage();
    SoundService.startBackground();
    generateBubblePositions();
    startTimer();
  }

  @override
  void dispose() {
    timer?.cancel();
    feedbackTimer?.cancel();
    feedbackController.dispose();
    super.dispose();
  }

  Future<void> _openLegalUrl(Uri url) async {
    final opened = await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    );

    if (!opened) return;
  }

  Future<void> toggleTranslation(String word) async {
    final shouldShowTranslation = !showTranslation;

    setState(() {
      showTranslation = shouldShowTranslation;
      if (shouldShowTranslation) {
        translationText = null;
      }
    });

    if (!shouldShowTranslation) return;

    final translation = await TranslationService.getTranslation(
      word,
      languageCode: translationLanguageCode,
    );

    if (!mounted ||
        !showTranslation ||
        gameQuestions[currentQuestion].word != word) {
      return;
    }

    setState(() {
      translationText = translation;
    });
  }

  void startTimer() {
    timer?.cancel();
    setState(() => timeLeft = maxTime);
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (timeLeft > 0) {
        setState(() => timeLeft--);
      } else {
        timer.cancel();
        SoundService.playWrong();
        setState(() {
          timeRanOut = true;
          showFeedback = true;
          answerWasCorrect = false;
          correctAnswer = gameQuestions[currentQuestion].correctAnswer;
        });
        recordReviewAnswer(
          questionIndex: currentQuestion,
          selectedAnswer: null,
          isCorrect: false,
        );
        feedbackController.reset();
        feedbackController.forward();
      }
    });
  }

  Future<void> nextQuestion() async {
    final hasPremium = await PremiumService.isPremium();

    if (!mounted) return;

    if (!hasPremium && currentQuestion >= 9) {
      showPremiumPopup();
      return;
    }

    if (currentQuestion < gameQuestions.length - 1) {
      setState(() {
        currentQuestion++;
        selectedAnswer = null;
        selectedAnswerCorrect = false;
        showTranslation = false;
        translationText = null;
        generateBubblePositions();
      });
      startTimer();
    } else {
      timer?.cancel();
      await LearningLevelService.recordSession(
        exerciseId: widget.title,
        score: score,
        total: gameQuestions.length,
      );
      if (!mounted) return;

      AnalyticsService.saveQuizResult(
        category: widget.title,
        score: score,
        total: gameQuestions.length,
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            category: widget.title,
            score: score,
            totalQuestions: gameQuestions.length,
            reviewItems: List.unmodifiable(reviewItems),
          ),
        ),
      );
    }
  }

  void showPremiumPopup() {
    const neonBlue = Color(0xFF2FD4FF);
    final l = LocalizationService.t;

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: l('premiumAccess'),
      barrierColor: Colors.black.withOpacity(0.55),
      transitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        Widget benefit(String text) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: neonBlue.withOpacity(0.14),
                    border: Border.all(
                      color: neonBlue.withOpacity(0.55),
                    ),
                  ),
                  child: const Icon(
                    Icons.check,
                    color: neonBlue,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ResponsiveText(
                    text,
                    maxLines: 1,
                    minFontSize: 10,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        Widget premiumButton({
          required String label,
          required VoidCallback onPressed,
          bool primary = false,
        }) {
          return SizedBox(
            width: double.infinity,
            height: 54,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: primary
                    ? const LinearGradient(
                        colors: [
                          Color(0xFF2FD4FF),
                          Color(0xFF168BFF),
                        ],
                      )
                    : null,
                color: primary ? null : Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: primary
                      ? neonBlue.withOpacity(0.75)
                      : Colors.white.withOpacity(0.16),
                  width: 1.2,
                ),
                boxShadow: primary
                    ? [
                        BoxShadow(
                          color: neonBlue.withOpacity(0.35),
                          blurRadius: 22,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: onPressed,
                  child: Center(
                    child: ResponsiveText(
                      label,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      minFontSize: 9,
                      style: TextStyle(
                        color: primary ? const Color(0xFF05212A) : Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        Widget legalLink({
          required String label,
          required Uri url,
        }) {
          return TextButton(
            onPressed: () => unawaited(_openLegalUrl(url)),
            style: TextButton.styleFrom(
              foregroundColor: neonBlue.withOpacity(0.88),
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 28),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              textStyle: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
              ),
            ),
            child: ResponsiveText(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              minFontSize: 9,
            ),
          );
        }

        return Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                  child: Container(
                    color: Colors.black.withOpacity(0.42),
                  ),
                ),
              ),
              SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 28,
                    ),
                    child: Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(maxWidth: 380),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 28,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF073B52).withOpacity(0.92),
                            const Color(0xFF061B2A).withOpacity(0.94),
                            const Color(0xFF020B12).withOpacity(0.96),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: neonBlue.withOpacity(0.45),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: neonBlue.withOpacity(0.28),
                            blurRadius: 38,
                            spreadRadius: 2,
                          ),
                          BoxShadow(
                            color: Colors.black.withOpacity(0.42),
                            blurRadius: 30,
                            offset: const Offset(0, 18),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 94,
                            height: 94,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  neonBlue.withOpacity(0.95),
                                  neonBlue.withOpacity(0.12),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: neonBlue.withOpacity(0.45),
                                  blurRadius: 28,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.lock_outline,
                              color: Colors.white,
                              size: 54,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ResponsiveText(
                            l('premiumAccess').toUpperCase(),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            minFontSize: 16,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.1,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ResponsiveText(
                            l('premiumSubtitle'),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            minFontSize: 10,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.76),
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.07),
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.12),
                              ),
                            ),
                            child: Column(
                              children: [
                                benefit(l('unlimitedPractice')),
                                benefit(l('analytics')),
                                benefit(l('newGrammarCategories')),
                                benefit(l('futureUpdates')),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            '€35,00',
                            style: TextStyle(
                              color: neonBlue,
                              fontSize: 42,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.4,
                            ),
                          ),
                          const SizedBox(height: 24),
                          premiumButton(
                            label: l('buyPremium').toUpperCase(),
                            primary: true,
                            onPressed: () async {
                              try {
                                final success =
                                    await PremiumService.purchasePremium();

                                if (!mounted || !dialogContext.mounted) return;

                                if (success) {
                                  Navigator.pop(dialogContext);

                                  await nextQuestion();
                                }
                              } catch (_) {
                                return;
                              }
                            },
                          ),
                          const SizedBox(height: 12),
                          premiumButton(
                            label: l('enterCode').toUpperCase(),
                            onPressed: () {
                              Navigator.of(dialogContext).pop();
                              showCodeDialog();
                            },
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: () {
                              Navigator.of(dialogContext).pop();
                              if (!mounted) return;
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (_) => const DashboardScreen(),
                                ),
                                (route) => false,
                              );
                              unawaited(SoundService.playClick());
                            },
                            child: ResponsiveText(
                              l('maybeLater').toUpperCase(),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              minFontSize: 9,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.68),
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.7,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Column(
                            children: [
                              legalLink(
                                label: l('privacyPolicy'),
                                url: _privacyPolicyUrl,
                              ),
                              const SizedBox(height: 12),
                              legalLink(
                                label: l('termsOfUse'),
                                url: _termsOfUseUrl,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
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
            scale: Tween<double>(begin: 0.92, end: 1).animate(curvedAnimation),
            child: child,
          ),
        );
      },
    );
  }

  void showCodeDialog() {
    final controller = TextEditingController();
    const neonBlue = Color(0xFF2FD4FF);
    final l = LocalizationService.t;

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: l('enterCode'),
      barrierColor: Colors.black.withOpacity(0.55),
      transitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return Material(
          color: Colors.transparent,
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 28,
                ),
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 380),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 28,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF073B52).withOpacity(0.92),
                        const Color(0xFF061B2A).withOpacity(0.94),
                        const Color(0xFF020B12).withOpacity(0.96),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: neonBlue.withOpacity(0.45),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: neonBlue.withOpacity(0.28),
                        blurRadius: 38,
                        spreadRadius: 2,
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.42),
                        blurRadius: 30,
                        offset: const Offset(0, 18),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ResponsiveText(
                        l('enterCode'),
                        maxLines: 1,
                        minFontSize: 14,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 14),
                      ResponsiveText(
                        l('enterActivationCode'),
                        maxLines: 3,
                        minFontSize: 12,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.78),
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 22),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.16),
                            width: 1.2,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        child: TextField(
                          controller: controller,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          decoration: InputDecoration(
                            hintText: l('codeHint'),
                            hintMaxLines: 2,
                            hintStyle: const TextStyle(
                              color: Colors.white54,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(height: 26),
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 54,
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  backgroundColor:
                                      Colors.white.withOpacity(0.06),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                    side: BorderSide(
                                      color: Colors.white.withOpacity(0.16),
                                    ),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.pop(dialogContext);
                                  if (!mounted) return;
                                  showPremiumPopup();
                                },
                                child: ResponsiveText(
                                  l('cancel'),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  minFontSize: 11,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.7,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SizedBox(
                              height: 54,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: neonBlue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  elevation: 0,
                                ),
                                onPressed: () async {
                                  final code = controller.text.trim();
                                  final isValidCode =
                                      await RemoteCodeService.isCodeValid(code);

                                  if (!mounted || !dialogContext.mounted) {
                                    return;
                                  }

                                  if (!isValidCode) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: ResponsiveText(
                                          l('invalidCode'),
                                          maxLines: 1,
                                          minFontSize: 11,
                                        ),
                                      ),
                                    );
                                    return;
                                  }

                                  await PremiumService.activateCodePremium();

                                  if (!mounted || !dialogContext.mounted) {
                                    return;
                                  }

                                  Navigator.pop(dialogContext);

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: ResponsiveText(
                                        l('premiumActivated'),
                                        maxLines: 1,
                                        minFontSize: 11,
                                      ),
                                    ),
                                  );

                                  setState(() {
                                    showFeedback = false;
                                  });

                                  await nextQuestion();
                                },
                                child: ResponsiveText(
                                  l('activate'),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  minFontSize: 11,
                                  style: const TextStyle(
                                    color: Color(0xFF05212A),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.7,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
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
            scale: Tween<double>(begin: 0.92, end: 1).animate(curvedAnimation),
            child: child,
          ),
        );
      },
    );
  }

  void checkAnswer(String answer) {
    if (selectedAnswer != null || showFeedback) return;

    timeRanOut = false;
    timer?.cancel();
    final isCorrect = answer == gameQuestions[currentQuestion].correctAnswer;
    recordReviewAnswer(
      questionIndex: currentQuestion,
      selectedAnswer: answer,
      isCorrect: isCorrect,
    );
    setState(() {
      selectedAnswer = answer;
      selectedAnswerCorrect = isCorrect;
    });

    if (isCorrect) {
      SoundService.playCorrect();
      score++;
      Future.delayed(const Duration(milliseconds: 600), () {
        if (!mounted) return;
        unawaited(nextQuestion());
      });
    } else {
      SoundService.playWrong();
      setState(() {
        showFeedback = true;
        answerWasCorrect = isCorrect;
        correctAnswer = gameQuestions[currentQuestion].correctAnswer;
      });
      feedbackController.reset();
      feedbackController.forward();
    }
  }

  List<BubblePosition> generatePositions() {
    final positions = <BubblePosition>[
      BubblePosition(8, 18),
      BubblePosition(186, 34),
      BubblePosition(46, 168),
      BubblePosition(188, 222),
      BubblePosition(92, 334),
    ]..shuffle();

    return positions;
  }

  void generateBubblePositions() {
    bubblePositions = generatePositions();
  }

  void recordReviewAnswer({
    required int questionIndex,
    required String? selectedAnswer,
    required bool isCorrect,
  }) {
    if (recordedReviewIndexes.contains(questionIndex)) return;

    recordedReviewIndexes.add(questionIndex);
    reviewItems.add(
      QuizReviewItem(
        question: gameQuestions[questionIndex],
        selectedAnswer: selectedAnswer,
        isCorrect: isCorrect,
      ),
    );
  }

  Future<void> toggleFavorite(GrammarQuestion question) async {
    await SoundService.playClick();

    final added = await FavoriteService.toggleFavorite(
      question: question,
      category: question.category ?? widget.categoryId,
      categoryTitle: question.categoryTitle ?? widget.categoryTitle,
      exercise: question.exercise ?? widget.exerciseId,
      exerciseTitle: question.exerciseTitle ?? widget.exerciseTitle,
      instruction: question.instructionKey ?? widget.instruction,
    );

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
    final question = gameQuestions[currentQuestion];
    final l = LocalizationService.t;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/ocean_background.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              color: Colors.black.withOpacity(0.25),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Column(
                      children: [
                        const SizedBox(height: 40),
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 18,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.15),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  ResponsiveText(
                                    LocalizationService.questionCount(
                                      currentQuestion + 1,
                                      gameQuestions.length,
                                    ),
                                    maxLines: 1,
                                    minFontSize: 11,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  ResponsiveText(
                                    '$score',
                                    maxLines: 1,
                                    minFontSize: 14,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              top: -18,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: GestureDetector(
                                  onTap: () async {
                                    await SoundService.playClick();
                                    if (!context.mounted) return;

                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                    width: 55,
                                    height: 55,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: const Color(0xFF2FD4FF),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF2FD4FF)
                                              .withOpacity(0.6),
                                          blurRadius: 20,
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.home_rounded,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: TweenAnimationBuilder<double>(
                        key: ValueKey('$currentQuestion-$timeLeft'),
                        duration: const Duration(milliseconds: 900),
                        tween: Tween(
                          begin: ((timeLeft + 1).clamp(0, maxTime)) / maxTime,
                          end: timeLeft / maxTime,
                        ),
                        builder: (context, value, child) {
                          return LinearProgressIndicator(
                            value: value,
                            minHeight: 14,
                            backgroundColor: Colors.white.withOpacity(0.15),
                            valueColor: const AlwaysStoppedAnimation(
                              Color(0xFF45D7FF),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 30),
                    ResponsiveText(
                      LocalizationService.instruction(
                        question.instructionKey ?? widget.instruction,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      minFontSize: 10,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(width: 44),
                            Flexible(
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () => toggleTranslation(question.word),
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 220),
                                  switchInCurve: Curves.easeOut,
                                  switchOutCurve: Curves.easeOut,
                                  transitionBuilder: (child, animation) {
                                    final scaleAnimation = Tween<double>(
                                      begin: 0.96,
                                      end: 1,
                                    ).animate(animation);

                                    return FadeTransition(
                                      opacity: animation,
                                      child: ScaleTransition(
                                        scale: scaleAnimation,
                                        child: child,
                                      ),
                                    );
                                  },
                                  child: ResponsiveText(
                                    showTranslation && translationText != null
                                        ? translationText!.toUpperCase()
                                        : question.word.toUpperCase(),
                                    key: ValueKey(
                                      showTranslation && translationText != null
                                          ? 'translation-${question.word}-$translationText'
                                          : 'word-${question.word}',
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    minFontSize: 18,
                                    style: TextStyle(
                                      color: showTranslation &&
                                              translationText != null
                                          ? const Color(0xFF45D7FF)
                                          : Colors.white,
                                      fontSize: 42,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 44,
                              height: 44,
                              child: ValueListenableBuilder(
                                valueListenable: FavoriteService.listenable(),
                                builder: (context, _, __) {
                                  final isFavorite = FavoriteService.isFavorite(
                                    question: question,
                                    category:
                                        question.category ?? widget.categoryId,
                                    exercise:
                                        question.exercise ?? widget.exerciseId,
                                  );

                                  return IconButton(
                                    tooltip: LocalizationService.t(
                                      isFavorite
                                          ? 'removeFavorite'
                                          : 'addFavorite',
                                    ),
                                    onPressed: () => toggleFavorite(question),
                                    icon: Icon(
                                      isFavorite
                                          ? Icons.star_rounded
                                          : Icons.star_outline_rounded,
                                      color: isFavorite
                                          ? const Color(0xFFFFD25B)
                                          : Colors.white.withOpacity(0.78),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => toggleTranslation(question.word),
                          child: SizedBox(
                            height: 24,
                            child: Center(
                              child: ResponsiveText(
                                l('tapToTranslate'),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                minFontSize: 10,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.55),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: Stack(
                        children: [
                          ...List.generate(
                            question.options.length,
                            (index) => Positioned(
                              left: bubblePositions[index].x,
                              top: bubblePositions[index].y,
                              child: AnimatedScale(
                                key: ValueKey('$currentQuestion-$index'),
                                duration: const Duration(milliseconds: 150),
                                scale: selectedAnswer == question.options[index]
                                    ? 1.35
                                    : 1,
                                child: AnswerBubble(
                                  text: question.options[index],
                                  imagePath: selectedAnswer ==
                                          question.options[index]
                                      ? (selectedAnswerCorrect
                                          ? 'assets/images/bubble_correct.png'
                                          : 'assets/images/bubble_wrong.png')
                                      : 'assets/images/bubble.png',
                                  onTap: () =>
                                      checkAnswer(question.options[index]),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (showFeedback)
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: answerWasCorrect
                    ? null
                    : () {
                        if (!mounted) return;
                        setState(() => showFeedback = false);
                        unawaited(nextQuestion());
                      },
                child: Container(
                  color: Colors.black.withOpacity(0.45),
                  child: Center(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: ScaleTransition(
                        scale: feedbackScaleAnimation,
                        child: Container(
                          width: 340,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 30,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: answerWasCorrect
                                  ? [
                                      const Color(0xFF1D563D).withOpacity(0.95),
                                      const Color(0xFF0B3421).withOpacity(0.9),
                                    ]
                                  : [
                                      const Color(0xFF521B1D).withOpacity(0.95),
                                      const Color(0xFF2F1112).withOpacity(0.9),
                                    ],
                            ),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: answerWasCorrect
                                  ? Colors.greenAccent.withOpacity(0.6)
                                  : Colors.redAccent.withOpacity(0.6),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: answerWasCorrect
                                    ? Colors.greenAccent.withOpacity(0.25)
                                    : Colors.redAccent.withOpacity(0.25),
                                blurRadius: 35,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: answerWasCorrect
                                        ? [
                                            Colors.greenAccent.withOpacity(0.9),
                                            Colors.green.withOpacity(0.1),
                                          ]
                                        : [
                                            Colors.redAccent.withOpacity(0.9),
                                            Colors.red.withOpacity(0.1),
                                          ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: answerWasCorrect
                                          ? Colors.greenAccent.withOpacity(0.35)
                                          : Colors.redAccent.withOpacity(0.35),
                                      blurRadius: 20,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  answerWasCorrect
                                      ? Icons.check_circle_outline
                                      : Icons.highlight_off,
                                  size: 56,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 24),
                              ResponsiveText(
                                timeRanOut
                                    ? l('timesUp').toUpperCase()
                                    : answerWasCorrect
                                        ? l('correct').toUpperCase()
                                        : l('incorrect').toUpperCase(),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                minFontSize: 18,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 34,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 18),
                              ResponsiveText(
                                timeRanOut
                                    ? l('correctAnswerWas')
                                    : answerWasCorrect
                                        ? l('wellDone')
                                        : l('correctAnswerWas'),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                minFontSize: 10,
                                style: TextStyle(
                                  color: Colors.white70.withOpacity(0.95),
                                  fontSize: 18,
                                ),
                              ),
                              if (!answerWasCorrect) ...[
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 22,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.14),
                                    ),
                                  ),
                                  child: ResponsiveText(
                                    correctAnswer,
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    minFontSize: 12,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 18),
                                ResponsiveText(
                                  l('tapAnywhereToContinue'),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  minFontSize: 9,
                                  style: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
