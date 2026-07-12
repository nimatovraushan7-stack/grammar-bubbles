import 'package:flutter/material.dart';

import '../models/favorite_item.dart';
import '../services/favorite_service.dart';
import '../services/localization_service.dart';
import '../services/settings_service.dart';
import '../services/sound_service.dart';
import '../services/translation_service.dart';
import '../widgets/responsive_text.dart';
import 'game_screen.dart';

class FavoriteListScreen extends StatefulWidget {
  final String category;

  const FavoriteListScreen({
    super.key,
    required this.category,
  });

  @override
  State<FavoriteListScreen> createState() => _FavoriteListScreenState();
}

class _FavoriteListScreenState extends State<FavoriteListScreen> {
  final Set<String> selectedIds = {};

  @override
  void initState() {
    super.initState();
    selectedIds.addAll(
      FavoriteService.favoritesForCategory(widget.category).map(
        (item) => item.id,
      ),
    );
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
            color: Colors.black.withOpacity(0),
            child: SafeArea(
              child: ValueListenableBuilder(
                valueListenable: FavoriteService.listenable(),
                builder: (context, _, __) {
                  final items = FavoriteService.favoritesForCategory(
                    widget.category,
                  );
                  final validIds = items.map((item) => item.id).toSet();
                  selectedIds.removeWhere((id) => !validIds.contains(id));
                  final title = items.isEmpty
                      ? l('favorites')
                      : '${l('favoritePrefix')} ${LocalizationService.t(items.first.categoryTitle)}';

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
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
                              minFontSize: 15,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 34,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(height: 10),
                            ResponsiveText(
                              l('savedWordsCount').replaceAll(
                                '{count}',
                                '${items.length}',
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              minFontSize: 12,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 18),
                            Row(
                              children: [
                                Expanded(
                                  child: _SmallActionButton(
                                    label: l('selectAll'),
                                    onTap: items.isEmpty
                                        ? null
                                        : () {
                                            setState(() {
                                              selectedIds
                                                ..clear()
                                                ..addAll(
                                                  items.map((item) => item.id),
                                                );
                                            });
                                          },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _SmallActionButton(
                                    label: l('clearSelection'),
                                    onTap: selectedIds.isEmpty
                                        ? null
                                        : () {
                                            setState(selectedIds.clear);
                                          },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Expanded(
                        child: items.isEmpty
                            ? const Center(child: _EmptyFavoriteList())
                            : ListView.separated(
                                padding: const EdgeInsets.fromLTRB(
                                  24,
                                  6,
                                  24,
                                  110,
                                ),
                                itemCount: items.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final item = items[index];
                                  return _FavoriteRow(
                                    item: item,
                                    selected: selectedIds.contains(item.id),
                                    onSelected: (selected) {
                                      setState(() {
                                        if (selected) {
                                          selectedIds.add(item.id);
                                        } else {
                                          selectedIds.remove(item.id);
                                        }
                                      });
                                    },
                                    onRemoved: () async {
                                      await FavoriteService.remove(item.id);
                                      if (!context.mounted) return;
                                      ScaffoldMessenger.of(context)
                                        ..hideCurrentSnackBar()
                                        ..showSnackBar(
                                          SnackBar(
                                            behavior: SnackBarBehavior.floating,
                                            backgroundColor:
                                                const Color(0xFF061B2A),
                                            content: ResponsiveText(
                                              l('removedFromFavorites'),
                                              maxLines: 1,
                                              minFontSize: 11,
                                            ),
                                          ),
                                        );
                                    },
                                  );
                                },
                              ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                        child: _PracticeButton(
                          enabled: selectedIds.isNotEmpty,
                          label: l('practiceSelected'),
                          onTap: () => _practiceSelected(items),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _practiceSelected(List<FavoriteItem> items) async {
    final selectedItems = items
        .where((item) => selectedIds.contains(item.id))
        .toList(growable: false);

    if (selectedItems.isEmpty) return;

    await SoundService.playClick();
    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GameScreen(
          title:
              '${LocalizationService.t('favoritePrefix')} ${LocalizationService.t(selectedItems.first.categoryTitle)}',
          instruction: selectedItems.first.instruction,
          questions: selectedItems.map((item) => item.toQuestion()).toList(),
          categoryId: selectedItems.first.category,
          categoryTitle: selectedItems.first.categoryTitle,
          exerciseId: 'favorites_${selectedItems.first.category}',
          exerciseTitle:
              '${LocalizationService.t('favoritePrefix')} ${LocalizationService.t(selectedItems.first.categoryTitle)}',
        ),
      ),
    );
  }
}

class _FavoriteRow extends StatefulWidget {
  final FavoriteItem item;
  final bool selected;
  final ValueChanged<bool> onSelected;
  final VoidCallback onRemoved;

  const _FavoriteRow({
    required this.item,
    required this.selected,
    required this.onSelected,
    required this.onRemoved,
  });

  @override
  State<_FavoriteRow> createState() => _FavoriteRowState();
}

class _FavoriteRowState extends State<_FavoriteRow> {
  bool showTranslation = false;
  String? translationText;

  Future<void> toggleTranslation() async {
    final shouldShowTranslation = !showTranslation;

    setState(() {
      showTranslation = shouldShowTranslation;
      if (shouldShowTranslation) {
        translationText = null;
      }
    });

    if (!shouldShowTranslation) return;

    final translation = await TranslationService.getTranslation(
      widget.item.word,
      languageCode: SettingsService.getLanguage(),
    );

    if (!mounted || !showTranslation) return;

    setState(() {
      translationText = translation;
    });
  }

  @override
  Widget build(BuildContext context) {
    const glowColor = Color(0xFFFFD25B);
    final shownWord = showTranslation && translationText != null
        ? translationText!
        : widget.item.word;

    return Dismissible(
      key: ValueKey(widget.item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => widget.onRemoved(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 22),
        decoration: BoxDecoration(
          color: Colors.redAccent.withOpacity(0.22),
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Icon(
          Icons.delete_rounded,
          color: Colors.white,
        ),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xF01A3145),
              Color.alphaBlend(
                glowColor.withOpacity(0.12),
                const Color(0xF0122638),
              ),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: glowColor.withOpacity(0.28)),
        ),
        child: Row(
          children: [
            Checkbox(
              value: widget.selected,
              onChanged: (value) => widget.onSelected(value ?? false),
              activeColor: const Color(0xFF45D7FF),
              checkColor: const Color(0xFF05212A),
              side: BorderSide(color: Colors.white.withOpacity(0.64)),
            ),
            IconButton(
              tooltip: LocalizationService.t('removeFavorite'),
              onPressed: widget.onRemoved,
              icon: const Icon(
                Icons.star_rounded,
                color: glowColor,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: toggleTranslation,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(
                        scale: Tween<double>(begin: 0.97, end: 1).animate(
                          animation,
                        ),
                        child: child,
                      ),
                    );
                  },
                  child: ResponsiveText(
                    shownWord,
                    key: ValueKey('${widget.item.id}-$shownWord'),
                    maxLines: 1,
                    minFontSize: 11,
                    style: TextStyle(
                      color: showTranslation && translationText != null
                          ? const Color(0xFF45D7FF)
                          : Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SmallActionButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _SmallActionButton({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: FilledButton(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          backgroundColor: Colors.white.withOpacity(onTap == null ? 0.07 : 0.1),
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.white.withOpacity(0.05),
          disabledForegroundColor: Colors.white.withOpacity(0.35),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: Colors.white.withOpacity(0.14),
            ),
          ),
        ),
        child: ResponsiveText(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          minFontSize: 10,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _PracticeButton extends StatelessWidget {
  final bool enabled;
  final String label;
  final VoidCallback onTap;

  const _PracticeButton({
    required this.enabled,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: enabled
              ? const LinearGradient(
                  colors: [
                    Color(0xFF2FD4FF),
                    Color(0xFF168BFF),
                  ],
                )
              : null,
          color: enabled ? null : Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(18),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: const Color(0xFF2FD4FF).withOpacity(0.32),
                    blurRadius: 22,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: FilledButton(
          onPressed: enabled ? onTap : null,
          style: FilledButton.styleFrom(
            backgroundColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            foregroundColor: const Color(0xFF05212A),
            disabledForegroundColor: Colors.white.withOpacity(0.35),
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          child: ResponsiveText(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            minFontSize: 12,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyFavoriteList extends StatelessWidget {
  const _EmptyFavoriteList();

  @override
  Widget build(BuildContext context) {
    final l = LocalizationService.t;

    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.star_rounded,
            color: Color(0xFFFFD25B),
            size: 56,
          ),
          const SizedBox(height: 14),
          ResponsiveText(
            l('noFavoriteWordsYet'),
            textAlign: TextAlign.center,
            maxLines: 1,
            minFontSize: 14,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          ResponsiveText(
            l('favoritesEmptySubtitle'),
            textAlign: TextAlign.center,
            maxLines: 4,
            minFontSize: 12,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 15,
              height: 1.35,
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
