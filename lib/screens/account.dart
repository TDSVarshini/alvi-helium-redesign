import 'package:flutter/material.dart';

import '../design/tokens.dart';
import '../design/typography.dart';
import '../state/app_state.dart';
import '../widgets/widgets.dart';

bool _validEmail(String s) => RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(s);

/// Sign in (from QWatch Pro "Login"). Account backend is not part of this build; sign-in is local.
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});
  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final email = TextEditingController();
  final pass = TextEditingController();
  String? error;

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    return AlviPage(
      footer: [
        PrimaryButton('Sign in', onPressed: () {
          if (!_validEmail(email.text.trim()) || pass.text.length < 6) {
            setState(() => error = 'Check your email and password.');
            return;
          }
          app.signIn(email.text.trim());
          Navigator.pushNamedAndRemoveUntil(context, app.wearable.band == null ? '/pair' : '/today', (_) => false);
        }),
        AlviLink('Create an account', onTap: () => Navigator.pushReplacementNamed(context, '/account/create')),
        AlviLink('Privacy', onTap: () => Navigator.pushNamed(context, '/you/privacy')),
      ],
      children: [
        const Headline('Welcome back.', size: 32),
        const SizedBox(height: Space.s32),
        AlviField(label: 'Email', hint: 'you@example.com', controller: email, keyboard: TextInputType.emailAddress),
        AlviField(label: 'Password', hint: 'Password', controller: pass, obscure: true),
        Align(alignment: Alignment.centerRight, child: AlviLink('Forgot your password?', center: false, onTap: () => Navigator.pushNamed(context, '/account/reset'))),
        if (error != null) Padding(padding: const EdgeInsets.only(top: 8), child: StatusWord(error!, color: context.alvi.alert)),
      ],
    );
  }
}

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});
  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final email = TextEditingController();
  final pass = TextEditingController();
  final confirm = TextEditingController();
  String? error;

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    return AlviPage(
      footer: [
        PrimaryButton('Create account', onPressed: () {
          if (!_validEmail(email.text.trim())) return setState(() => error = 'Enter a valid email.');
          if (pass.text.length < 8) return setState(() => error = 'Use at least 8 characters.');
          if (pass.text != confirm.text) return setState(() => error = 'Passwords do not match.');
          app.signIn(email.text.trim());
          Navigator.pushNamed(context, '/onboarding/profile');
        }),
        AlviLink('I already have an account', onTap: () => Navigator.pushReplacementNamed(context, '/account/sign-in')),
      ],
      children: [
        const Headline('Create your account.', eyebrow: 'Step 1 of 8', size: 32),
        const SizedBox(height: Space.s32),
        AlviField(label: 'Email', hint: 'you@example.com', controller: email, keyboard: TextInputType.emailAddress),
        AlviField(label: 'Password', hint: 'At least 8 characters', controller: pass, obscure: true),
        AlviField(label: 'Confirm password', hint: 'Enter it again', controller: confirm, obscure: true),
        if (error != null) StatusWord(error!, color: context.alvi.alert),
        Disclaimer('By continuing you agree to the ALVI terms and privacy statement. ALVI gives general wellness guidance, not medical advice.'),
      ],
    );
  }
}

/// Reset password (from "Retrieve password"): email, code with Send, new password twice.
class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});
  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final email = TextEditingController();
  final code = TextEditingController();
  final p1 = TextEditingController();
  final p2 = TextEditingController();
  bool sent = false;
  String? error;

  @override
  Widget build(BuildContext context) => AlviPage(
        label: 'Reset password',
        footer: [
          PrimaryButton('Confirm', onPressed: () {
            if (code.text.length < 4) return setState(() => error = 'Enter the code from your email.');
            if (p1.text.length < 8 || p1.text != p2.text) return setState(() => error = 'Passwords must match and be 8+ characters.');
            toast(context, 'Password updated');
            Navigator.pop(context);
          }),
        ],
        children: [
          const Headline('Reset your password.', sub: 'We send a code to your email.'),
          const SizedBox(height: Space.s24),
          AlviField(label: 'Email', hint: 'you@example.com', controller: email, keyboard: TextInputType.emailAddress),
          AlviField(
            label: 'Verification code',
            hint: 'Six digits',
            controller: code,
            keyboard: TextInputType.number,
            trailing: TextButton(
              onPressed: () {
                if (!_validEmail(email.text.trim())) return setState(() => error = 'Enter a valid email first.');
                setState(() {
                  sent = true;
                  error = null;
                });
                toast(context, 'Code sent (sample: no email service connected)');
              },
              child: Text(sent ? 'Resend' : 'Send', style: AlviType.bodySmall(context, color: context.alvi.ink).copyWith(decoration: TextDecoration.underline)),
            ),
          ),
          AlviField(label: 'New password', hint: 'At least 8 characters', controller: p1, obscure: true),
          AlviField(label: 'Confirm new password', hint: 'Enter it again', controller: p2, obscure: true),
          if (error != null) StatusWord(error!, color: context.alvi.alert),
        ],
      );
}
