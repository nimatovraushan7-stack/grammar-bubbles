import 'package:flutter/material.dart';

import '../services/learning_level_service.dart';
import '../services/localization_service.dart';
import '../services/settings_service.dart';
import '../widgets/responsive_text.dart';
import '../services/sound_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const Color _accentBlue = Color(0xFF45D7FF);
  static const Color _green = Color(0xFF4CFF6B);

  late double questionTime;
  late String languageCode;
  late String learningLevelMode;

  @override
  void initState() {
    super.initState();
    questionTime = SettingsService.getQuestionTime().toDouble();
    languageCode = SettingsService.getLanguage();
    learningLevelMode = LearningLevelService.getMode();
  }

  Future<void> _updateQuestionTime(double value) async {
    setState(() {
      questionTime = value;
    });

    await SettingsService.setQuestionTime(value.round());
  }

  Future<void> _selectLanguage(String code) async {
    if (code == languageCode) return;

    await SoundService.playClick();

    await SettingsService.setLanguage(code);

    setState(() {
      languageCode = code;
    });
  }

  Future<void> _selectLearningLevel(String mode) async {
    if (mode == learningLevelMode) return;

    await SoundService.playClick();
    await LearningLevelService.setMode(mode);

    setState(() {
      learningLevelMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = LocalizationService.t;

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
            color: Colors.black.withValues(alpha: 0.05),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 22, 24, 34),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        _BackButton(
                          onTap: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ResponsiveText(
                                l('settings'),
                                maxLines: 1,
                                minFontSize: 16,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 34,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              ResponsiveText(
                                l('settingsSubtitle'),
                                maxLines: 1,
                                minFontSize: 10,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    _SectionLabel(
                      icon: Icons.menu_book_rounded,
                      title: l('learning'),
                    ),
                    const SizedBox(height: 12),
                    _SettingsCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ResponsiveText(
                            l('questionTime'),
                            maxLines: 1,
                            minFontSize: 13,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 18),
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: _accentBlue,
                              inactiveTrackColor:
                                  Colors.white.withValues(alpha: 0.18),
                              thumbColor: Colors.white,
                              overlayColor: _accentBlue.withValues(alpha: 0.16),
                              valueIndicatorColor: _accentBlue,
                              valueIndicatorTextStyle: const TextStyle(
                                color: Color(0xFF062235),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            child: Slider(
                              value: questionTime,
                              min: 5,
                              max: 20,
                              divisions: 15,
                              label: LocalizationService.seconds(
                                questionTime.round(),
                              ),
                              onChanged: _updateQuestionTime,
                              onChangeEnd: (_) async {
                                await SoundService.playClick();
                              },
                            ),
                          ),
                          const SizedBox(height: 8),
                          ResponsiveText(
                            LocalizationService.seconds(questionTime.round()),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            minFontSize: 13,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    _SettingsCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ResponsiveText(
                            l('learningLevel'),
                            maxLines: 1,
                            minFontSize: 13,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 14),
                          _LearningLevelTile(
                            title: l('learningLevelAuto'),
                            subtitle: l('learningLevelAutoSubtitle'),
                            isSelected: learningLevelMode ==
                                LearningLevelService.autoMode,
                            accentColor: _green,
                            onTap: () => _selectLearningLevel(
                              LearningLevelService.autoMode,
                            ),
                          ),
                          const SizedBox(height: 10),
                          _LearningLevelTile(
                            title: l('learningLevelBeginner'),
                            subtitle: 'A1',
                            isSelected: learningLevelMode == 'a1',
                            accentColor: _green,
                            onTap: () => _selectLearningLevel('a1'),
                          ),
                          const SizedBox(height: 10),
                          _LearningLevelTile(
                            title: l('learningLevelElementary'),
                            subtitle: 'A2',
                            isSelected: learningLevelMode == 'a2',
                            accentColor: _green,
                            onTap: () => _selectLearningLevel('a2'),
                          ),
                          const SizedBox(height: 10),
                          _LearningLevelTile(
                            title: l('learningLevelIntermediate'),
                            subtitle: 'B1',
                            isSelected: learningLevelMode == 'b1',
                            accentColor: _green,
                            onTap: () => _selectLearningLevel('b1'),
                          ),
                          const SizedBox(height: 10),
                          _LearningLevelTile(
                            title: l('learningLevelAdvanced'),
                            subtitle: 'B2',
                            isSelected: learningLevelMode == 'b2',
                            accentColor: _green,
                            onTap: () => _selectLearningLevel('b2'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    _SectionLabel(
                      icon: Icons.public_rounded,
                      title: l('nativeLanguage'),
                    ),
                    const SizedBox(height: 12),
                    _SettingsCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ResponsiveText(
                            l('nativeLanguage'),
                            maxLines: 1,
                            minFontSize: 13,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 14),
                          _LanguageTile(
                            flag: '🇳🇱',
                            name: l('dutch'),
                            isSelected: languageCode == 'nl',
                            accentColor: _green,
                            onTap: () => _selectLanguage('nl'),
                          ),
                          const SizedBox(height: 10),
                          _LanguageTile(
                            flag: '🇬🇧',
                            name: l('english'),
                            isSelected: languageCode == 'en',
                            accentColor: _green,
                            onTap: () => _selectLanguage('en'),
                          ),
                          const SizedBox(height: 10),
                          _LanguageTile(
                            flag: '🇹🇷',
                            name: l('turkish'),
                            isSelected: languageCode == 'tr',
                            accentColor: _green,
                            onTap: () => _selectLanguage('tr'),
                          ),
                          const SizedBox(height: 10),
                          _LanguageTile(
                            flag: '🇷🇺',
                            name: l('russian'),
                            isSelected: languageCode == 'ru',
                            accentColor: _green,
                            onTap: () => _selectLanguage('ru'),
                          ),
                          const SizedBox(height: 10),
                          _LanguageTile(
                            flag: '🇸🇦',
                            name: l('arabic'),
                            isSelected: languageCode == 'ar',
                            accentColor: _green,
                            onTap: () => _selectLanguage('ar'),
                          ),
                          const SizedBox(height: 10),
                          _LanguageTile(
                            flag: '🇺🇦',
                            name: l('ukrainian'),
                            isSelected: languageCode == 'uk',
                            accentColor: _green,
                            onTap: () => _selectLanguage('uk'),
                          ),
                        ],
                      ),
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
}

class _LearningLevelTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isSelected;
  final Color accentColor;
  final VoidCallback onTap;

  const _LearningLevelTile({
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: accentColor.withValues(alpha: 0.10),
        highlightColor: accentColor.withValues(alpha: 0.05),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? accentColor.withValues(alpha: 0.12)
                : Colors.black.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected
                  ? accentColor.withValues(alpha: 0.42)
                  : Colors.white.withValues(alpha: 0.10),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accentColor.withValues(alpha: 0.12),
                ),
                child: Icon(
                  isSelected
                      ? Icons.check_circle_rounded
                      : Icons.school_rounded,
                  color: accentColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ResponsiveText(
                      title,
                      maxLines: 1,
                      minFontSize: 11,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    ResponsiveText(
                      subtitle,
                      maxLines: 1,
                      minFontSize: 9,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final Widget child;

  const _SettingsCard({
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xF01A3145),
            Color.alphaBlend(
              const Color(0xFF45D7FF).withValues(alpha: 0.12),
              const Color(0xF0122638),
            ),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF45D7FF).withValues(alpha: 0.26),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF45D7FF).withValues(alpha: 0.10),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionLabel({
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: const Color(0xFF45D7FF),
          size: 20,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ResponsiveText(
            title.toUpperCase(),
            maxLines: 1,
            minFontSize: 8,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.6,
            ),
          ),
        ),
      ],
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final String flag;
  final String name;
  final bool isSelected;
  final Color accentColor;
  final VoidCallback? onTap;

  const _LanguageTile({
    required this.flag,
    required this.name,
    this.isSelected = false,
    this.accentColor = const Color(0xFF45D7FF),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: accentColor.withValues(alpha: 0.10),
        highlightColor: accentColor.withValues(alpha: 0.05),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? accentColor.withValues(alpha: 0.12)
                : Colors.black.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected
                  ? accentColor.withValues(alpha: 0.42)
                  : Colors.white.withValues(alpha: 0.10),
            ),
          ),
          child: Row(
            children: [
              Text(
                flag,
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ResponsiveText(
                      name,
                      maxLines: 1,
                      minFontSize: 11,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle_rounded,
                  color: accentColor,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  final VoidCallback onTap;

  const _BackButton({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Ink(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF45D7FF).withValues(alpha: 0.25),
                const Color(0xFF2FD4FF).withValues(alpha: 0.10),
              ],
            ),
            border: Border.all(
              color: const Color(0xFF45D7FF).withValues(alpha: 0.38),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF45D7FF).withValues(alpha: 0.18),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
            size: 26,
          ),
        ),
      ),
    );
  }
}
