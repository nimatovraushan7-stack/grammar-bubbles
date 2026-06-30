import 'package:flutter/material.dart';

import 'analytics_screen.dart';

import '../services/sound_service.dart';
import 'verleden_tijd_category_screen.dart';
import 'voltooid_deelwoord_category_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    SoundService.startBackground();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SizedBox.expand(
        child: DecoratedBox(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                'assets/images/ocean_background.png',
              ),
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
                            const SizedBox(height: 30),
                            const Text(
                              'GRAMMAR\nBUBBLES',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 42,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Leer grammatica spelenderwijs',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 60),
                            _MenuButton(
                              title: 'Voltooid Deelwoord',
                              subtitle: 'Regelmatig • Onregelmatig • Gemengd',
                              icon: Icons.auto_awesome_rounded,
                              glowColor: const Color(0xFF2FD4FF),
                              onTap: () async {
                                await SoundService.playClick();
                                if (!context.mounted) return;

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const VoltooidDeelwoordCategoryScreen(),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 20),
                            _MenuButton(
                              title: 'Verleden Tijd',
                              subtitle: 'Regelmatig • Onregelmatig • Gemengd',
                              icon: Icons.history_rounded,
                              glowColor: const Color(0xFF4CFF6B),
                              onTap: () async {
                                await SoundService.playClick();
                                if (!context.mounted) return;

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const VerledenTijdCategoryScreen(),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 20),
                            _MenuButton(
                              glowColor: const Color(0xFFB56CFF),
                              title: 'Mijn groei',
                              subtitle: 'Bekijk je voortgang en prestaties',
                              icon: Icons.insights_rounded,
                              onTap: () async {
                                await SoundService.playClick();
                                if (!context.mounted) return;

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const AnalyticsScreen(),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 60),
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
}

class _MenuButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final Color glowColor;

  const _MenuButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    required this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: glowColor.withOpacity(0.12),
        highlightColor: glowColor.withOpacity(0.06),
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
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
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: glowColor.withOpacity(0.38)),
            boxShadow: [
              BoxShadow(
                color: glowColor.withOpacity(0.12),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: glowColor.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(color: glowColor.withOpacity(0.32)),
                ),
                child: Icon(icon, color: glowColor, size: 27),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: glowColor,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
