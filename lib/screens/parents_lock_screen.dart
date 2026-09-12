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

  void _onDigit(String digit) {
    if (_entered.length >= 4) return;
    setState(() {
      _entered += digit;
      _error = null;
    });
    if (_entered.length == 4) {
      _verify();
    }
  }

  void _onBackspace() {
    if (_entered.isEmpty) return;
    setState(() => _entered = _entered.substring(0, _entered.length - 1));
  }

  Future<void> _verify() async {
    if (StorageService.verifyPin(_entered)) {
      // Use push (not pushReplacement): this screen lives inside the
      // MainScreen IndexedStack, so replacing the route would remove the
      // whole tab bar and leave the user with no way back.
      await Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const ParentsDashboardScreen()));
      // Re-lock when the parent leaves the dashboard.
      if (mounted) setState(() => _entered = '');
    } else {
      setState(() {
        _error = 'Incorrect PIN, try again';
        _entered = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
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
                          color: AppTheme.surfaceContainer,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.lock_outline,
                          color: AppTheme.primaryPink,
                          size: 34,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text('Parents Area', style: AppTheme.headline(size: 24)),
                      const SizedBox(height: 8),
                      Text(
                        'Enter your 4-digit PIN to continue',
                        style: AppTheme.body(
                          size: 14,
                          color: AppTheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // ---- PIN dots ----
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(4, (i) {
                          final filled = i < _entered.length;
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: filled
                                  ? AppTheme.primaryPink
                                  : AppTheme.surfaceVariant,
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 12),
                      if (_error != null)
                        Text(
                          _error!,
                          style: AppTheme.body(size: 13, color: AppTheme.error),
                        ),

                      const Spacer(),

                      // ---- Number pad ----
                      _NumberPad(onDigit: _onDigit, onBackspace: _onBackspace),
                      const SizedBox(height: 12),
                      Text(
                        'Default PIN is 1234 unless changed by a parent.',
                        textAlign: TextAlign.center,
                        style: AppTheme.body(size: 12, color: AppTheme.outline),
                      ),
                      const SizedBox(height: 8),
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
                  child: const Icon(
                    Icons.backspace_outlined,
                    color: AppTheme.onSurfaceVariant,
                  ),
                );
              }
              return _PadButton(
                onTap: () => onDigit(key),
                child: Text(
                  key,
                  style: AppTheme.headline(size: 24, color: AppTheme.onSurface),
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(34),
      child: Container(
        width: 68,
        height: 68,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerLowest,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppTheme.navy.withValues(alpha: 0.05),
              blurRadius: 6,
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}
