import 'dart:async';

import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import 'parents_dashboard_screen.dart';

/// PIN gate that must be solved before the Parents Dashboard is revealed.
class ParentsLockScreen extends StatefulWidget {
  const ParentsLockScreen({super.key});

  @override
  State<ParentsLockScreen> createState() => _ParentsLockScreenState();
}

class _ParentsLockScreenState extends State<ParentsLockScreen> {
  String _entered = '';
  String? _error;

  /// Set while the PBKDF2 derivation runs, so the pad can't be hammered.
  bool _checking = false;

  /// Drives the lockout countdown once a lockout is armed.
  Timer? _lockTicker;

  @override
  void initState() {
    super.initState();
    if (StorageService.isPinLocked()) _startLockTicker();
  }

  @override
  void dispose() {
    _lockTicker?.cancel();
    super.dispose();
  }

  void _startLockTicker() {
    _lockTicker?.cancel();
    _lockTicker = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (!StorageService.isPinLocked()) {
        t.cancel();
        _lockTicker = null;
        setState(() => _error = null);
      } else {
        setState(() {});
      }
    });
  }

  bool get _isLocked => StorageService.isPinLocked();

  void _onDigit(String digit) {
    if (_checking || _isLocked || _entered.length >= 4) return;
    setState(() {
      _entered += digit;
      _error = null;
    });
    if (_entered.length == 4) {
      _verify();
    }
  }

  void _onBackspace() {
    if (_checking || _isLocked || _entered.isEmpty) return;
    setState(() => _entered = _entered.substring(0, _entered.length - 1));
  }

  Future<void> _verify() async {
    final pin = _entered;
    setState(() => _checking = true);

    final ok = await StorageService.verifyPin(pin);
    if (!mounted) return;

    if (ok) {
      await StorageService.clearPinFailures();
      if (!mounted) return;
      setState(() {
        _checking = false;
        _entered = '';
        _error = null;
      });

      // Use push (not pushReplacement): this screen lives inside the
      // MainScreen IndexedStack, so replacing the route would remove the
      // whole tab bar and leave the user with no way back.
      await Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const ParentsDashboardScreen()));
      // Re-lock when the parent leaves the dashboard.
      if (mounted) setState(() => _entered = '');
      return;
    }

    final lockout = await StorageService.registerFailedPinAttempt();
    if (!mounted) return;
    setState(() {
      _checking = false;
      _entered = '';
      _error = lockout > Duration.zero
          ? 'Too many attempts'
          : _wrongPinMessage();
    });
    if (lockout > Duration.zero) _startLockTicker();
  }

  String _wrongPinMessage() {
    final left = StorageService.pinAttemptsBeforeLockout();
    if (left > 2) return 'Incorrect PIN, try again';
    return left == 1
        ? 'Incorrect PIN - 1 try left'
        : 'Incorrect PIN - $left tries left';
  }

  /// "30s" / "4:59" - short enough to sit under the PIN dots.
  static String _formatRemaining(Duration d) {
    final total = d.inSeconds + (d.inMilliseconds % 1000 > 0 ? 1 : 0);
    if (total < 60) return '${total}s';
    final m = total ~/ 60;
    final s = total % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final remaining = StorageService.pinLockRemaining();
    final locked = remaining > Duration.zero;
    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        // Scrollable + min-height so the number pad never overflows on short
        // screens (e.g. when the mini-player is showing above the tab bar).
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: c.primaryFixed,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.lock_outline,
                          color: c.primaryDeep,
                          size: 34,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Parents Area',
                        style: AppTheme.headline(size: 24, color: c.headline),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        locked
                            ? 'Too many incorrect attempts'
                            : 'Enter your 4-digit PIN to continue',
                        textAlign: TextAlign.center,
                        style: AppTheme.body(
                          size: 14,
                          color: c.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // ---- PIN dots (a spinner while the hash is derived) ----
                      SizedBox(
                        height: 18,
                        child: _checking
                            ? SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: c.primary,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(4, (i) {
                                  final filled = i < _entered.length;
                                  return Container(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    width: 18,
                                    height: 18,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: filled
                                          ? c.primary
                                          : c.surfaceVariant,
                                    ),
                                  );
                                }),
                              ),
                      ),
                      const SizedBox(height: 12),
                      if (locked)
                        Text(
                          'Try again in ${_formatRemaining(remaining)}',
                          style: AppTheme.body(size: 13, color: c.error),
                        )
                      else if (_error != null)
                        Text(
                          _error!,
                          style: AppTheme.body(size: 13, color: c.error),
                        ),

                      const Spacer(),

                      // ---- Number pad ----
                      Opacity(
                        opacity: locked ? 0.4 : 1,
                        child: _NumberPad(
                          onDigit: _onDigit,
                          onBackspace: _onBackspace,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NumberPad extends StatelessWidget {
  final void Function(String) onDigit;
  final VoidCallback onBackspace;

  const _NumberPad({required this.onDigit, required this.onBackspace});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    const rows = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', 'back'],
    ];

    return Column(
      children: rows.map((row) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: row.map((key) {
              if (key.isEmpty) {
                return const SizedBox(width: 68, height: 68);
              }
              if (key == 'back') {
                return _PadButton(
                  onTap: onBackspace,
                  child: Icon(
                    Icons.backspace_outlined,
                    color: c.onSurfaceVariant,
                  ),
                );
              }
              return _PadButton(
                onTap: () => onDigit(key),
                child: Text(
                  key,
                  style: AppTheme.headline(size: 24, color: c.onSurface),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}

class _PadButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  const _PadButton({required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(34),
      child: Container(
        width: 68,
        height: 68,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: c.surfaceLowest,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: c.shadow.withValues(alpha: c.isDark ? 0.3 : 0.05),
              blurRadius: 6,
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}
