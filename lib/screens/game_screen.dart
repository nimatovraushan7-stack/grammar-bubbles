import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../models/grammar_question.dart';
import '../services/analytics_service.dart';
import '../services/premium_service.dart';
import '../services/remote_code_service.dart';
import '../services/sound_service.dart';
import '../widgets/answer_bubble.dart';
import 'dashboard_screen.dart';
import 'result_screen.dart';

class GameScreen extends StatefulWidget {
  final String title;
  final String instruction;
  final List<GrammarQuestion> questions;

  const GameScreen({
    super.key,
    required this.title,
    required this.instruction,
    required this.questions,
  });

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
  String? selectedAnswer;
  bool selectedAnswerCorrect = false;
  bool timeRanOut = false;
  int currentQuestion = 0;
  int score = 0;
  List<GrammarQuestion> gameQuestions = [];
  final int maxTime = 10;
  int timeLeft = 10;
  Timer? timer;
  Timer? feedbackTimer;
  late final AnimationController feedbackController;
  late final Animation<double> feedbackScaleAnimation;
  List<BubblePosition> bubblePositions = [];
  bool showFeedback = false;
  bool answerWasCorrect = false;
  String correctAnswer = '';

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
    gameQuestions = List.from(widget.questions);
    gameQuestions.shuffle();
    if (gameQuestions.length > 15) {
      gameQuestions = gameQuestions.take(15).toList();
    }
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

  void startTimer() {
    timer?.cancel();
    setState(() => timeLeft = 10);
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
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
        feedbackController.reset();
        feedbackController.forward();
      }
    });
  }

  Future<void> nextQuestion() async {
  if (!await PremiumService.isPremium() && currentQuestion >= 9) {
    showPremiumPopup();
    return;
  }
    if (currentQuestion < gameQuestions.length - 1) {
      setState(() {
        currentQuestion++;
        selectedAnswer = null;
        selectedAnswerCorrect = false;
        generateBubblePositions();
      });
      startTimer();
    } else {
      timer?.cancel();
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
          ),
        ),
      );
    }
  }

  void showPremiumPopup() {
    const neonBlue = Color(0xFF2FD4FF);

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Premium toegang',
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
                  child: Text(
                    text,
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
                    child: Text(
                      label,
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
                          const Text(
                            'PREMIUM TOEGANG',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.1,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '6 maanden onbeperkt toegang',
                            textAlign: TextAlign.center,
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
                                benefit('Onbeperkt oefenen'),
                                benefit('Analytics'),
                                benefit('Nieuwe grammatica categorieën'),
                                benefit('Toekomstige updates'),
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
  label: 'KOOP PREMIUM',
  primary: true,
  onPressed: () async {
    try {
      final success = await PremiumService.activatePremium();

      if (!mounted || !dialogContext.mounted) return;

      if (success) {
        Navigator.pop(dialogContext);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Premium succesvol geactiveerd!'),
          ),
        );

        await nextQuestion();
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Aankoop mislukt: $e'),
        ),
      );
    }
  },
),
                          const SizedBox(height: 12),
                          premiumButton(
                            label: 'CODE INVOEREN',
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
                            child: Text(
                              'MISSCHIEN LATER',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.68),
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.7,
                              ),
                            ),
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

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Code invoeren',
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
                      const Text(
                        'Code invoeren',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Voer je activatiecode in om premium te ontgrendelen.',
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
                          decoration: const InputDecoration(
                            hintText: 'Voer code in',
                            hintStyle: TextStyle(
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
                                  backgroundColor: Colors.white.withOpacity(0.06),
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
                                child: const Text(
                                  'Annuleren',
                                  style: TextStyle(
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
                                  final isValidCode = await RemoteCodeService.isCodeValid(code);

                                  if (!mounted || !dialogContext.mounted) return;

                                  if (!isValidCode) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Ongeldige of verlopen code',
                                        ),
                                      ),
                                    );
                                    return;
                                  }

                                  await PremiumService.activatePremium();

                                  if (!mounted || !dialogContext.mounted) return;

                                  Navigator.pop(dialogContext);

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Premium geactiveerd!',
                                      ),
                                    ),
                                  );

                                  setState(() {
                                    showFeedback = false;
                                  });

                                  await nextQuestion();
                                },
                                child: const Text(
                                  'Activeren',
                                  style: TextStyle(
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
    timeRanOut = false;
    timer?.cancel();
    final isCorrect = answer == gameQuestions[currentQuestion].correctAnswer;
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
    final positions = <BubblePosition>[];
    for (int i = 0; i < 5; i++) {
      bool validPosition = false;
      while (!validPosition) {
        final x = Random().nextDouble() * 220;
        final y = Random().nextDouble() * 350;
        validPosition = true;
        for (final position in positions) {
          final dx = position.x - x;
          final dy = position.y - y;
          if (sqrt(dx * dx + dy * dy) < 120) {
            validPosition = false;
            break;
          }
        }
        if (validPosition) positions.add(BubblePosition(x, y));
      }
    }
    return positions;
  }

  void generateBubblePositions() {
    bubblePositions = generatePositions();
  }

  @override
  Widget build(BuildContext context) {
    final question = gameQuestions[currentQuestion];

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
                                  Text(
                                    'Vraag ${currentQuestion + 1}/${gameQuestions.length}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    '$score',
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
                    Text(
                      widget.instruction,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      question.word.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 42,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
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
                              Text(
                                timeRanOut
                                    ? 'TIJD OP'
                                    : answerWasCorrect
                                        ? 'CORRECT'
                                        : 'INCORRECT',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 34,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 18),
                              Text(
                                timeRanOut
                                    ? 'Het juiste antwoord was:'
                                    : answerWasCorrect
                                        ? 'Goed gedaan!'
                                        : 'Het juiste antwoord was:',
                                textAlign: TextAlign.center,
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
                                  child: Text(
                                    correctAnswer,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 18),
                                const Text(
                                  'Tik ergens om verder te gaan',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
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
