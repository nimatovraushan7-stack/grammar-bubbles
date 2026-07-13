import 'dart:async';

import 'package:flutter/material.dart';

import '../models/dictionary_entry.dart';
import '../services/dictionary_service.dart';
import '../services/localization_service.dart';
import '../services/sound_service.dart';
import '../utils/dictionary_debug.dart';
import '../widgets/grammar_menu_card.dart';
import '../widgets/responsive_text.dart';
import 'dictionary_detail_screen.dart';

class DictionaryScreen extends StatefulWidget {
  const DictionaryScreen({super.key});

  @override
  State<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends State<DictionaryScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  late final int _debugId;
  List<DictionaryEntry> _results = const [];
  Timer? _searchDebounceTimer;
  int _searchGeneration = 0;
  bool _isLoading = true;
  bool _isSearching = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _debugId = identityHashCode(this);
    _log(
      'initState controller=${identityHashCode(_searchController)} '
      'focus=${identityHashCode(_searchFocusNode)}',
    );
    _searchController.addListener(_onSearchChanged);
    _searchFocusNode.addListener(_onFocusChanged);
    unawaited(_loadDictionary());
  }

  @override
  void dispose() {
    _log(
      'dispose text="${_searchController.text}" '
      'focus=${_searchFocusNode.hasFocus} generation=$_searchGeneration '
      'results=${_results.length} isLoading=$_isLoading '
      'isSearching=$_isSearching',
    );
    _searchDebounceTimer?.cancel();
    _searchFocusNode.removeListener(_onFocusChanged);
    _searchFocusNode.dispose();
    _searchController
      ..removeListener(_onSearchChanged)
      ..dispose();
    super.dispose();
  }

  Future<void> _loadDictionary() async {
    _log('_loadDictionary start');
    try {
      final entries = await DictionaryService.loadEntries();
      _log('_loadDictionary complete entries=${entries.length}');
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _loadError = null;
      });
      _queueSearch(immediate: true);
    } catch (error, stackTrace) {
      _logError('_loadDictionary failed', error, stackTrace);
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'dictionary',
          context: ErrorDescription('while loading Dictionary entries'),
        ),
      );
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _loadError = error.toString();
      });
    }
  }

  void _onFocusChanged() {
    _log(
      'focusChanged hasFocus=${_searchFocusNode.hasFocus} '
      'canRequestFocus=${_searchFocusNode.canRequestFocus} '
      'skipTraversal=${_searchFocusNode.skipTraversal} '
      'text="${_searchController.text}"',
    );
  }

  void _onSearchChanged() {
    _log(
      '_onSearchChanged text="${_searchController.text}" '
      'isLoading=$_isLoading generation=$_searchGeneration',
    );
    if (_isLoading) {
      _log('_onSearchChanged ignored because loading');
      return;
    }
    _queueSearch();
  }

  void _queueSearch({bool immediate = false}) {
    _searchDebounceTimer?.cancel();
    final generation = ++_searchGeneration;
    final query = _searchController.text.trim();
    _log(
      '_queueSearch immediate=$immediate generation=$generation '
      'query="$query" mounted=$mounted',
    );

    if (query.isEmpty) {
      if (mounted) {
        _log('_queueSearch empty query -> clear results');
        setState(() {
          _results = const [];
          _isSearching = false;
        });
      }
      return;
    }

    if (mounted) {
      _log(
        '_queueSearch set searching=${!immediate} and clear stale results',
      );
      setState(() {
        _results = const [];
        _isSearching = !immediate;
      });
    }

    if (immediate) {
      _runSearch(generation);
      return;
    }

    _searchDebounceTimer = Timer(const Duration(milliseconds: 280), () {
      _log(
        '_queueSearch timer fired generation=$generation '
        'currentGeneration=$_searchGeneration text="${_searchController.text}"',
      );
      _runSearch(generation);
    });
  }

  void _runSearch(int generation) {
    _log(
      '_runSearch start generation=$generation currentGeneration='
      '$_searchGeneration mounted=$mounted isLoading=$_isLoading '
      'text="${_searchController.text}"',
    );
    if (!mounted || _isLoading || generation != _searchGeneration) {
      _log('_runSearch aborted');
      return;
    }

    final query = _searchController.text.trim();
    final results = DictionaryService.searchCached(query);
    _log(
      '_runSearch results query="$query" count=${results.length} '
      'first=${results.isEmpty ? '-' : results.first.word}',
    );

    if (!mounted || generation != _searchGeneration) {
      _log('_runSearch aborted after search');
      return;
    }

    setState(() {
      _results = results;
      _isSearching = false;
    });
  }

  void _goBack() {
    _log('_goBack');
    _searchDebounceTimer?.cancel();
    _searchFocusNode.unfocus();
    unawaited(SoundService.playClick().catchError((_) {}));
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    _log(
      'build text="${_searchController.text}" focus='
      '${_searchFocusNode.hasFocus} generation=$_searchGeneration '
      'results=${_results.length} isLoading=$_isLoading '
      'isSearching=$_isSearching loadError=$_loadError',
    );
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
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _IconActionButton(
                          icon: Icons.arrow_back_ios_new_rounded,
                          onTap: _goBack,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ResponsiveText(
                            l('dictionary'),
                            maxLines: 1,
                            minFontSize: 18,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 34,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _SearchField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      onSubmitted: (value) {
                        _log(
                          'TextField onSubmitted value="$value" '
                          'focus=${_searchFocusNode.hasFocus}',
                        );
                        _searchFocusNode.unfocus();
                        _queueSearch(immediate: true);
                      },
                      onTap: () => _log(
                        'TextField onTap focus=${_searchFocusNode.hasFocus}',
                      ),
                    ),
                    const SizedBox(height: 18),
                    Expanded(
                      child: _buildResults(l),
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

  Widget _buildResults(String Function(String key) l) {
    _log(
      '_buildResults text="${_searchController.text}" '
      'isLoading=$_isLoading isSearching=$_isSearching '
      'results=${_results.length} loadError=$_loadError',
    );
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF2FD4FF),
        ),
      );
    }

    if (_loadError != null) {
      return _DictionaryHint(text: l('dictionaryLoadFailed'));
    }

    if (_searchController.text.trim().isEmpty) {
      return _DictionaryHint(text: l('dictionaryHint'));
    }

    if (_isSearching) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF2FD4FF),
        ),
      );
    }

    if (_results.isEmpty) {
      return _DictionaryHint(text: l('noDictionaryResults'));
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemCount: _results.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final entry = _results[index];
        return GrammarMenuCard(
          title: entry.word,
          description: LocalizationService.t(entry.typeLabelKey),
          icon: entry.type == DictionaryEntryType.article
              ? Icons.article_rounded
              : Icons.menu_book_rounded,
          glowColor: entry.type == DictionaryEntryType.article
              ? const Color(0xFF4CFF6B)
              : const Color(0xFF2FD4FF),
          onTap: () => unawaited(_openEntry(context, entry)),
        );
      },
    );
  }

  Future<void> _openEntry(BuildContext context, DictionaryEntry entry) async {
    _log('_openEntry start word=${entry.word}');
    try {
      _searchFocusNode.unfocus();
      unawaited(SoundService.playClick().catchError((_) {}));
      if (!context.mounted) return;

      _log('_openEntry Navigator.push word=${entry.word}');
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DictionaryDetailScreen(entry: entry),
        ),
      );

      _log(
        '_openEntry Navigator returned word=${entry.word} mounted=$mounted '
        'text="${_searchController.text}" generation=$_searchGeneration',
      );
      if (!mounted) return;
      _queueSearch(immediate: true);
    } catch (error, stackTrace) {
      _logError('_openEntry failed word=${entry.word}', error, stackTrace);
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'dictionary',
          context: ErrorDescription('while opening Dictionary entry'),
        ),
      );
      rethrow;
    }
  }

  void _log(String message) {
    DictionaryDebug.log('DictionaryScreen#$_debugId', message);
  }

  void _logError(String message, Object error, StackTrace stackTrace) {
    DictionaryDebug.error(
      'DictionaryScreen#$_debugId',
      error,
      stackTrace,
      context: message,
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onTap;

  const _SearchField({
    required this.controller,
    required this.focusNode,
    required this.onSubmitted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      textInputAction: TextInputAction.search,
      autocorrect: false,
      enableSuggestions: false,
      onSubmitted: onSubmitted,
      onTap: onTap,
      onTapOutside: (_) => FocusScope.of(context).unfocus(),
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
      cursorColor: const Color(0xFF2FD4FF),
      decoration: InputDecoration(
        hintText: LocalizationService.t('searchDutchWords'),
        hintStyle: TextStyle(
          color: Colors.white.withOpacity(0.55),
          fontWeight: FontWeight.w600,
        ),
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: Color(0xFF2FD4FF),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.08),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.14),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(
            color: Color(0xFF2FD4FF),
            width: 1.4,
          ),
        ),
      ),
    );
  }
}

class _DictionaryHint extends StatelessWidget {
  final String text;

  const _DictionaryHint({required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ResponsiveText(
        text,
        textAlign: TextAlign.center,
        maxLines: 3,
        minFontSize: 12,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
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
