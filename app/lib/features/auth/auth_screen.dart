import 'package:flutter/foundation.dart' show kIsWeb;
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
  String? _notice; // mensaje neutral (p. ej. "revisa tu correo")

  @override
  void initState() {
    super.initState();
    // Si volvemos de un OAuth fallido (proveedor sin configurar o cancelado),
    // Supabase reenvía a la app con un ?error=/#error= en la URL. Lo mostramos
    // con gracia en vez de dejar al usuario sin señal. Solo web.
    if (kIsWeb) {
      final u = Uri.base;
      final hasError = u.queryParameters.containsKey('error') ||
          u.queryParameters.containsKey('error_description') ||
          u.fragment.contains('error=');
      if (hasError) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _error = AppLocalizations.of(context).authGoogleError);
        });
      }
    }
  }

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
      _notice = null;
    });
    try {
      final repo = ref.read(progressRepositoryProvider);
      if (_signUp) {
        final hasSession = await repo.signUpEmail(email, pw);
        if (!hasSession) {
          // Proyecto con "confirm email" ON: todavía no hay sesión → no podemos
          // guardar perfil/consentimiento (RLS). Avisamos con gracia y salimos.
          if (!mounted) return;
          setState(() {
            _loading = false;
            _notice = l10n.authCheckEmail;
          });
          return;
        }
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

  /// "Continuar con Google": en web dispara un redirect de página completa a
  /// Google; la sesión (o el error) llega al volver a la app. Degrada con gracia.
  Future<void> _google() async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _loading = true;
      _error = null;
      _notice = null;
    });
    try {
      await ref.read(progressRepositoryProvider).signInWithGoogle();
      // No navegamos aquí: en web el navegador ya está redirigiendo.
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = l10n.authGoogleError;
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
              // "Continuar con Google" (camino rápido, sin contraseña). Solo web
              // (PWA): usa redirect OAuth. Si el proveedor aún no está configurado
              // en Supabase, el retorno trae un error que mostramos con gracia.
              if (kIsWeb) ...[
                _GoogleButton(
                  label: l10n.authContinueGoogle,
                  onTap: _loading ? null : _google,
                ),
                const SizedBox(height: 16),
                _OrDivider(label: l10n.authOr),
                const SizedBox(height: 16),
              ],
              // Selector crear cuenta / iniciar sesión.
              _SegToggle(
                signUp: _signUp,
                onChanged: (v) => setState(() {
                  _signUp = v;
                  _error = null;
                  _notice = null;
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
              if (_notice != null) ...[
                const SizedBox(height: 10),
                Text(_notice!,
                    style: const TextStyle(
                        color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 12.5, height: 1.4)),
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

/// Botón "Continuar con Google". Sin assets externos (CSP del deploy bloquea
/// hosts externos): la "G" se dibuja con la tipografía Material, en los colores
/// de la marca. Blanco con borde, estilo estándar de proveedor.
class _GoogleButton extends StatelessWidget {
  const _GoogleButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: disabled ? 0.6 : 1,
        child: Container(
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFDADCE6), width: 2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // "G" multicolor aproximada con la tipografía (sin imagen externa).
              const Text('G',
                  style: TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF4285F4))),
              const SizedBox(width: 12),
              Text(label,
                  style: const TextStyle(
                      fontSize: 15.5, fontWeight: FontWeight.w900, color: Color(0xFF3C4043))),
            ],
          ),
        ),
      ),
    );
  }
}

/// Divisor "— o —" entre el camino Google y el de email.
class _OrDivider extends StatelessWidget {
  const _OrDivider({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    const line = Expanded(child: Divider(color: Color(0xFFE0E2EC), thickness: 1.5));
    return Row(
      children: [
        line,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(label,
              style: const TextStyle(
                  fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.textMuted)),
        ),
        line,
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
