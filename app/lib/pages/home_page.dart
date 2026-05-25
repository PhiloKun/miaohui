import 'package:flutter/material.dart';
import '../models/reply.dart';
import '../widgets/reply_card.dart';
import 'settings_page.dart';
import '../services/api_service.dart';
import '../models/history_entry.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  late ApiService _apiService;
  List<ReplyResult>? _replies;
  bool _loading = false;
  String? _error;
  final _history = <HistoryEntry>[];
  bool _showHistory = false;
  String _serverUrl = 'http://127.0.0.1:8099';
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService(_serverUrl);
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _getReplies() async {
    final msg = _controller.text.trim();
    if (msg.isEmpty) return;

    setState(() {
      _loading = true;
      _error = null;
      _replies = null;
    });

    try {
      final replies = await _apiService.getReplies(msg);
      if (!mounted) return;
      setState(() {
        _replies = replies;
        _loading = false;
        _history.insert(0, HistoryEntry(
          message: msg,
          replies: replies,
          timestamp: DateTime.now(),
        ));
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _navigateToSettings() async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => SettingsPage(serverUrl: _serverUrl)),
    );
    if (result != null && result.isNotEmpty) {
      setState(() {
        _serverUrl = result;
        _apiService = ApiService(_serverUrl);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1A1A2E) : const Color(0xFFFAFAFA);
    final cardColor = isDark ? const Color(0xFF16213E) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(theme, isDark),

            // Input area
            _buildInputArea(theme, isDark, cardColor),

            // Content area
            Expanded(child: _buildContent(theme, isDark, cardColor)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          // Logo
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF6B6B), Color(0xFFFF8E8E)],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF6B6B).withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Center(
              child: Text('\u{1F4AC}', style: TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '\u79d2\u56de',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF2D3436),
                  ),
                ),
                Text(
                  '\u6536\u5230\u6d88\u606f\u4e0d\u77e5\u600e\u4e48\u56de\uff1fAI \u5e2e\u4f60',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.grey[400] : const Color(0xFF636E72),
                  ),
                ),
              ],
            ),
          ),
          // History toggle
          if (_history.isNotEmpty)
            IconButton(
              icon: Icon(
                _showHistory ? Icons.history : Icons.history_toggle_off_outlined,
                color: theme.colorScheme.primary,
              ),
              onPressed: () => setState(() => _showHistory = !_showHistory),
              tooltip: '\u5386\u53f2\u8bb0\u5f55',
            ),
          // Settings
          IconButton(
            icon: Icon(Icons.settings_outlined, color: isDark ? Colors.grey[400] : Colors.grey[600]),
            onPressed: _navigateToSettings,
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea(ThemeData theme, bool isDark, Color cardColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E2A45) : const Color(0xFFF5F6FA),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: isDark ? Colors.white12 : const Color(0xFFE0E0E0)),
            ),
            child: Row(
              children: [
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    textInputAction: TextInputAction.send,
                    onSubmitted: _loading ? null : (_) => _getReplies(),
                    decoration: InputDecoration(
                      hintText: '\u8f93\u5165\u522b\u4eba\u53d1\u6765\u7684\u6d88\u606f\u2026',
                      hintStyle: TextStyle(
                        color: isDark ? Colors.grey[500] : const Color(0xFFB2BEC3),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.white : const Color(0xFF2D3436),
                    ),
                    maxLines: 3,
                    minLines: 1,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(6),
                  child: AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return FilledButton(
                        onPressed: _loading ? null : _getReplies,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(48, 48),
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _loading
                            ? SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white.withValues(alpha: _pulseAnimation.value),
                                ),
                              )
                            : const Icon(Icons.send_rounded),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(ThemeData theme, bool isDark, Color cardColor) {
    // Show history if toggled
    if (_showHistory && _history.isNotEmpty) {
      return _buildHistory(theme, isDark);
    }

    // Error state
    if (_error != null) {
      return _buildError(theme);
    }

    // Loading shimmer
    if (_loading) {
      return _buildLoadingShimmer(theme, isDark);
    }

    // Replies
    if (_replies != null) {
      return _buildRepliesList(theme, isDark);
    }

    // Empty state
    return _buildEmptyState(theme, isDark);
  }

  Widget _buildEmptyState(ThemeData theme, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: isDark ? Colors.white10 : const Color(0xFFFFF0F0),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Center(
                child: Text('\u{1F4AC}', style: TextStyle(fontSize: 36)),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '\u8f93\u5165\u522b\u4eba\u53d1\u6765\u7684\u6d88\u606f',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : const Color(0xFF2D3436),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'AI \u4f1a\u4e3a\u4f60\u751f\u6210\u5e7d\u9ed8\u3001\u6696\u5fc3\u3001\u4e92\u52a8\u4e09\u79cd\u98ce\u683c\u7684\u56de\u590d',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey[500] : const Color(0xFF636E72),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingShimmer(ThemeData theme, bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            color: isDark ? const Color(0xFF16213E) : Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 60,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white12 : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    height: 16,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white12 : Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.6,
                    height: 16,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white12 : Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildError(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFFFE0E0),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Center(
                child: Icon(Icons.wifi_off_rounded, size: 32, color: Color(0xFFE74C3C)),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '\u8bf7\u6c42\u5931\u8d25',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? '',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _getReplies,
              icon: const Icon(Icons.refresh),
              label: const Text('\u91cd\u8bd5'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRepliesList(ThemeData theme, bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _replies!.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          // Show original message
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E2A45) : const Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? Colors.white12 : const Color(0xFFE0E0E0),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.person_outline, size: 16, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                      const SizedBox(width: 6),
                      Text(
                        _history.isNotEmpty ? _history.first.message : '',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.grey[300] : const Color(0xFF636E72),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ReplyCard(
            reply: _replies![index - 1],
            index: index - 1,
          ),
        );
      },
    );
  }

  Widget _buildHistory(ThemeData theme, bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _history.length,
      itemBuilder: (context, index) {
        final entry = _history[index];
    final timeStr = "${entry.timestamp.hour.toString().padLeft(2, '0')}:${entry.timestamp.minute.toString().padLeft(2, '0')}";
        return Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          color: isDark ? const Color(0xFF16213E) : Colors.white,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              setState(() {
                _replies = entry.replies;
                _controller.text = entry.message;
                _showHistory = false;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Icon(Icons.chat_bubble_outline, color: theme.colorScheme.primary, size: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.message,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white : const Color(0xFF2D3436),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "${entry.replies.length} 条回复 · ${timeStr}",
                          style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[500] : Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: isDark ? Colors.grey[600] : Colors.grey[400]),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
