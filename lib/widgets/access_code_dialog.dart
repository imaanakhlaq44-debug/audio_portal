import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../services/access_code_api.dart';
import '../services/premium_service.dart';
import '../theme/app_theme.dart';

/// Asks for a VIP or school code and redeems it. Returns true once Premium
/// is open.
///
/// Only offered in the PIN-locked Parents area, so there is no grown-up
/// question here.
Future<bool> showAccessCodeDialog(BuildContext context) async {
  final unlocked = await showDialog<bool>(
    context: context,
    builder: (_) => const AccessCodeDialog(),
  );
  if (unlocked != true || !context.mounted) return false;
  final premium = context.read<PremiumService>();
  final until = premium.codeUntil;
  final what = premium.codeKind == CodeKind.school ? 'School trial' : 'VIP';
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        until == null
            ? 'Every episode is open'
            : '$what unlocked: every episode is open until '
                  '${DateFormat.yMMMd().format(until)}',
      ),
    ),
  );
  return true;
}

class AccessCodeDialog extends StatefulWidget {
  const AccessCodeDialog({super.key});

  @override
  State<AccessCodeDialog> createState() => _AccessCodeDialogState();
}

class _AccessCodeDialogState extends State<AccessCodeDialog> {
  final _controller = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _redeem() async {
    final code = _controller.text.trim();
    if (code.isEmpty || _busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final outcome = await context.read<PremiumService>().redeemCode(code);
    if (!mounted) return;
    if (outcome == CodeOutcome.unlocked) {
      Navigator.pop(context, true);
      return;
    }
    setState(() {
      _busy = false;
      _error = switch (outcome) {
        CodeOutcome.unlocked || CodeOutcome.cancelled => null,
        CodeOutcome.invalid => "That code isn't right. Check it and try again.",
        CodeOutcome.used =>
          'This code has already been used by another family.',
        CodeOutcome.full =>
          "Every place on this school's code is taken. Ask the school for "
              'help.',
        CodeOutcome.trialUsed =>
          'This Google account has already had its school trial.',
        CodeOutcome.expired => "This code's time is over.",
        CodeOutcome.tooManyTries =>
          'Too many tries. Please wait an hour and try again.',
        CodeOutcome.offline =>
          "Couldn't reach Qissora. Check the internet and try again.",
        CodeOutcome.failed => 'Something went wrong. Please try again.',
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AlertDialog(
      title: const Text('Enter a code'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'A VIP code opens every episode for a year; a code from your '
            "child's school, for a month. You will sign in with Google, so "
            'it stays with your family on any phone.',
            style: AppTheme.body(size: 14, color: c.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            enabled: !_busy,
            autofocus: true,
            autocorrect: false,
            enableSuggestions: false,
            textCapitalization: TextCapitalization.characters,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9- ]')),
              LengthLimitingTextInputFormatter(16),
            ],
            decoration: InputDecoration(
              hintText: 'QV-XXXX-XXXX or QS-XXXX-XXXX',
              errorText: _error,
              errorMaxLines: 3,
            ),
            onChanged: (_) => setState(() => _error = null),
            onSubmitted: (_) => _redeem(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _busy || _controller.text.trim().isEmpty ? null : _redeem,
          child: _busy
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Unlock'),
        ),
      ],
    );
  }
}
