import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/theme/app_colors.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/primary_button.dart';
import '../legal/legal_screen.dart';

/// Pantalla de ENTRADA (GA4 auth-first): crear cuenta o iniciar sesión.
/// Tras autenticarse, el AppGate decide onboarding (si falta) o mapa.
class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _signUp = true; // arranca en "crear cuenta"
  bool _loading = false;
  bool _accepted = false; // aceptación legal (requerida para crear cuenta)
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  static final _emailRe = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    final name = _name.text.trim();
    final email = _email.text.trim();
    final pw = _password.text.trim();
    if (_signUp && name.isEmpty) {
      setState(() => _error = l10n.authErrorNameRequired);
      return;
    }
    if (!_emailRe.hasMatch(email) || pw.length < 6) {
      setState(() => _error = l10n.authErrorEmailPassword);
      return;
    }
    if (_signUp && !_accepted) {
      setState(() => _error = l10n.authErrorTermsRequired);
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repo = ref.read(progressRepositoryProvider);
      if (_signUp) {
        await repo.signUpEmail(email, pw);
        await repo.setProfile(name: name); // guarda el nombre real de entrada
        await repo.acceptLegal(kLegalVersion); // registra el consentimiento (versión + fecha)
      } else {
        await repo.signInEmail(email, pw);
      }
      // El AppGate escucha onAuthStateChange y enruta solo. No navegamos aquí.
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = _friendly(e.message);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = l10n.authErrorGeneral;
      });
    }
  }

  String _friendly(String raw) {
    final l10n = AppLocalizations.of(context);
    final m = raw.toLowerCase();
    if (m.contains('already registered') || m.contains('already been registered')) {
      return l10n.authErrorDuplicate;
    }
    if (m.contains('invalid login') || m.contains('credentials')) {
      return l10n.authErrorInvalid;
    }
    if (m.contains('password')) return l10n.authErrorPasswordLength;
    return l10n.authErrorFallback;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 24, 28, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              const Center(child: Text('🦜', style: TextStyle(fontSize: 72))),
              const SizedBox(height: 14),
              Text(_signUp ? l10n.authTitleSignUp : l10n.authTitleSignIn,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 26, fontWeight: FontWeight.w900, color: AppColors.text)),
              const SizedBox(height: 6),
              Text(
                _signUp ? l10n.authSubtitleSignUp : l10n.authSubtitleSignIn,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textMuted, height: 1.4),
              ),
              const SizedBox(height: 24),
              // Selector crear cuenta / iniciar sesión.
              _SegToggle(
                signUp: _signUp,
                onChanged: (v) => setState(() {
                  _signUp = v;
                  _error = null;
                }),
              ),
              const SizedBox(height: 18),
              if (_signUp) ...[
                _field(_name, l10n.authFieldName, Icons.person_outline_rounded,
                    keyboard: TextInputType.name),
                const SizedBox(height: 12),
              ],
              _field(_email, l10n.authFieldEmail, Icons.mail_outline_rounded,
                  keyboard: TextInputType.emailAddress),
              const SizedBox(height: 12),
              _field(_password, l10n.authFieldPassword, Icons.lock_outline_rounded, obscure: true),
              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(_error!,
                    style: const TextStyle(
                        color: AppColors.hearts, fontWeight: FontWeight.w800, fontSize: 12.5)),
              ],
              if (_signUp) ...[
                const SizedBox(height: 16),
                _LegalCheckbox(
                  l10n: l10n,
                  value: _accepted,
                  onChanged: (v) => setState(() {
                    _accepted = v;
                    if (v) _error = null;
                  }),
                  onTapTerms: () => Navigator.of(context)
                      .push(MaterialPageRoute(builder: (_) => LegalScreen.terms())),
                  onTapPrivacy: () => Navigator.of(context)
                      .push(MaterialPageRoute(builder: (_) => LegalScreen.privacy())),
                ),
              ],
              const SizedBox(height: 18),
              PrimaryButton(
                label: _loading
                    ? (_signUp ? l10n.authCtaCreating : l10n.authCtaLoggingIn)
                    : (_signUp ? l10n.authCtaSignUp : l10n.authCtaSignIn),
                expand: true,
                onPressed: (_loading || (_signUp && !_accepted)) ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String hint, IconData icon,
      {bool obscure = false, TextInputType? keyboard}) {
    return TextField(
      controller: c,
      obscureText: obscure,
      keyboardType: keyboard,
      enabled: !_loading,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.textMuted),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE5E7F1), width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }
}

/// Casilla de aceptación legal (requerida para crear cuenta). Texto + enlaces a
/// Términos y Privacidad. La aceptación se persiste con versión (mig 062).
class _LegalCheckbox extends StatelessWidget {
  const _LegalCheckbox({
    required this.l10n,
    required this.value,
    required this.onChanged,
    required this.onTapTerms,
    required this.onTapPrivacy,
  });
  final AppLocalizations l10n;
  final bool value;
  final ValueChanged<bool> onChanged;
  final VoidCallback onTapTerms;
  final VoidCallback onTapPrivacy;

  @override
  Widget build(BuildContext context) {
    const link = TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.primary);
    const base = TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMuted, height: 1.4);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 26,
          height: 26,
          child: Checkbox(
            value: value,
            onChanged: (v) => onChanged(v ?? false),
            activeColor: AppColors.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: () => onChanged(!value),
            child: Text.rich(
              TextSpan(style: base, children: [
                TextSpan(text: l10n.authLegalPrefix),
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: GestureDetector(onTap: onTapTerms, child: Text(l10n.authLegalTerms, style: link)),
                ),
                TextSpan(text: l10n.authLegalAnd),
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: GestureDetector(onTap: onTapPrivacy, child: Text(l10n.authLegalPrivacy, style: link)),
                ),
                TextSpan(text: l10n.authLegalSuffix),
              ]),
            ),
          ),
        ),
      ],
    );
  }
}

class _SegToggle extends StatelessWidget {
  const _SegToggle({required this.signUp, required this.onChanged});
  final bool signUp;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFEDEEF6),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _seg(l10n.authSegCreateAccount, signUp, () => onChanged(true)),
          _seg(l10n.authSegSignIn, !signUp, () => onChanged(false)),
        ],
      ),
    );
  }

  Widget _seg(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
            boxShadow: active
                ? const [BoxShadow(color: Color(0x14000000), offset: Offset(0, 2), blurRadius: 6)]
                : null,
          ),
          child: Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: active ? AppColors.primary : AppColors.textMuted)),
        ),
      ),
    );
  }
}
