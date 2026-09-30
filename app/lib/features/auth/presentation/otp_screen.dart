import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_theme.dart';
import '../application/auth_controller.dart';

/// Screen 2b — OTP entry. On success the router redirects automatically, so
/// this screen never navigates by hand.
class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key, required this.phone});

  final String phone;

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _controller = TextEditingController();
  bool _submitting = false;
  bool _resending = false;
  String? _error;

  static const _codeLength = 6;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final code = _controller.text.trim();
    if (code.length != _codeLength) {
      setState(() => _error = 'Enter the $_codeLength-digit code');
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      await ref
          .read(authControllerProvider.notifier)
          .verifyOtp(phone: widget.phone, code: code);
      // No navigation here — the redirect in app_router reacts to the new
      // auth state and sends the user to the right home screen.
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = _messageFor(e));
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  /// Branch on the stable code, never the human-facing message.
  String _messageFor(ApiException e) => switch (e.code) {
        ApiErrorCode.otpExpired =>
          'That code has expired. Request a new one.',
        ApiErrorCode.otpInvalid => 'That code is not correct.',
        ApiErrorCode.otpMaxAttempts =>
          'Too many incorrect attempts. Request a new code.',
        ApiErrorCode.phoneRateLimited =>
          'Too many requests. Try again in a few minutes.',
        _ => e.message,
      };

  Future<void> _resend() async {
    setState(() {
      _resending = true;
      _error = null;
    });
    try {
      await ref.read(authControllerProvider.notifier).requestOtp(widget.phone);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A new code is on its way.')),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = _messageFor(e));
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Verify')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.screen,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.md),
              Text('Enter the code', style: theme.textTheme.headlineSmall),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Sent to ${widget.phone}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: _controller,
                keyboardType: TextInputType.number,
                autofocus: true,
                enabled: !_submitting,
                maxLength: _codeLength,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium?.copyWith(letterSpacing: 8),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(counterText: ''),
                onChanged: (value) {
                  if (value.length == _codeLength) _verify();
                },
              ),
              if (_error != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              FilledButton(
                onPressed: _submitting ? null : _verify,
                child: _submitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Verify'),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextButton(
                onPressed: (_resending || _submitting) ? null : _resend,
                child: Text(_resending ? 'Sending…' : 'Resend code'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
