import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/theme/app_colors.dart';
import '../../data/providers.dart';
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
    final name = _name.text.trim();
    final email = _email.text.trim();
    final pw = _password.text.trim();
    if (_signUp && name.isEmpty) {
      setState(() => _error = 'Dinos tu nombre para personalizar tu viaje.');
      return;
    }
    if (!_emailRe.hasMatch(email) || pw.length < 6) {
      setState(() => _error = 'Pon un email válido y una contraseña de 6+ caracteres.');
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
        _error = 'Algo salió mal. Inténtalo de nuevo.';
      });
    }
  }

  String _friendly(String raw) {
    final m = raw.toLowerCase();
    if (m.contains('already registered') || m.contains('already been registered')) {
      return 'Ese email ya tiene cuenta. Inicia sesión.';
    }
    if (m.contains('invalid login') || m.contains('credentials')) {
      return 'Email o contraseña incorrectos.';
    }
    if (m.contains('password')) return 'La contraseña debe tener 6+ caracteres.';
    return 'No se pudo continuar. Revisa tus datos.';
  }

  @override
  Widget build(BuildContext context) {
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
              Text(_signUp ? 'Crea tu cuenta' : 'Bienvenido de vuelta',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 26, fontWeight: FontWeight.w900, color: AppColors.text)),
              const SizedBox(height: 6),
              Text(
                _signUp
                    ? 'Un plan con fecha real, examen de las 4 habilidades y un coach que te trae de vuelta.'
                    : 'Sigue donde lo dejaste.',
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
                _field(_name, 'Tu nombre', Icons.person_outline_rounded,
                    keyboard: TextInputType.name),
                const SizedBox(height: 12),
              ],
              _field(_email, 'Email', Icons.mail_outline_rounded,
                  keyboard: TextInputType.emailAddress),
              const SizedBox(height: 12),
              _field(_password, 'Contraseña', Icons.lock_outline_rounded, obscure: true),
              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(_error!,
                    style: const TextStyle(
                        color: AppColors.hearts, fontWeight: FontWeight.w800, fontSize: 12.5)),
              ],
              const SizedBox(height: 18),
              PrimaryButton(
                label: _loading
                    ? (_signUp ? 'CREANDO…' : 'ENTRANDO…')
                    : (_signUp ? 'CREAR CUENTA' : 'INICIAR SESIÓN'),
                expand: true,
                onPressed: _loading ? null : _submit,
              ),
              const SizedBox(height: 18),
              if (_signUp)
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text('Al crear tu cuenta aceptas los ',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                    GestureDetector(
                      onTap: () => Navigator.of(context)
                          .push(MaterialPageRoute(builder: (_) => LegalScreen.terms())),
                      child: const Text('Términos',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.primary)),
                    ),
                    const Text(' y la ',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                    GestureDetector(
                      onTap: () => Navigator.of(context)
                          .push(MaterialPageRoute(builder: (_) => LegalScreen.privacy())),
                      child: const Text('Privacidad',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.primary)),
                    ),
                  ],
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

class _SegToggle extends StatelessWidget {
  const _SegToggle({required this.signUp, required this.onChanged});
  final bool signUp;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFEDEEF6),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _seg('Crear cuenta', signUp, () => onChanged(true)),
          _seg('Iniciar sesión', !signUp, () => onChanged(false)),
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
