import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/ui/responsive_center.dart';
import '../../data/models/profile_models.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/primary_button.dart';
import '../learn/widgets/parrot_mascot.dart';

/// RED DE SEGURIDAD del registro: garantiza que TODO usuario tenga nombre +
/// confirmación de mayoría de edad, sea cual sea el camino por el que entró
/// (Google OAuth, email, cuenta creada antes de que el onboarding pidiera el
/// nombre, PWA vieja cacheada). Se muestra UNA vez, después del onboarding,
/// solo si falta algo (needs_name o is_adult sin confirmar). El onboarding
/// nuevo ya pide ambos → esta pantalla no aparece para altas recientes.
class CompleteProfileScreen extends ConsumerStatefulWidget {
  const CompleteProfileScreen({super.key, required this.profile, required this.onDone});

  final ProfileInfo profile;
  final VoidCallback onDone;

  @override
  ConsumerState<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends ConsumerState<CompleteProfileScreen> {
  late final TextEditingController _name =
      TextEditingController(text: widget.profile.name ?? '');
  late int? _birthYear = widget.profile.birthYear;
  bool _saving = false;
  bool _error = false;

  // Solo pedimos el nombre si falta (cuentas viejas / OAuth); el AGE GATE (año)
  // se pide a todos una vez.
  bool get _needsName => widget.profile.needsName;
  bool get _canSave =>
      (!_needsName || _name.text.trim().isNotEmpty) && _birthYear != null && !_saving;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_canSave) return;
    setState(() {
      _saving = true;
      _error = false;
    });
    try {
      final repo = ref.read(progressRepositoryProvider);
      if (_needsName) {
        await repo.setProfile(name: _name.text.trim());
      }
      // AGE GATE: el servidor recomputa is_adult REAL desde el año. 18+ es solo
      // requisito social (aún no abierto); un menor sigue usando la app.
      await repo.submitAgeGate(_birthYear!);
      widget.onDone();
    } catch (_) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currentYear = DateTime.now().year;
    final years = [for (var y = currentYear; y >= currentYear - 100; y--) y];
    // Copy NEUTRAL (pide el año, no "¿eres adulto?"). Si además falta el nombre,
    // se pide arriba; si no, solo el año.
    final title = _needsName ? l10n.completeProfileTitle : l10n.ageGateTitle;
    final subtitle = _needsName ? l10n.completeProfileSubtitle : l10n.ageGateSubtitle;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ResponsiveCenter(
          maxWidth: 480,
          child: ListView(
            padding: const EdgeInsets.all(28),
            children: [
              const SizedBox(height: 24),
              const Center(child: ParrotMascot(size: 92)),
              const SizedBox(height: 16),
              Text(title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.text)),
              const SizedBox(height: 8),
              Text(subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMuted,
                      height: 1.4)),
              const SizedBox(height: 24),
              if (_needsName) ...[
                TextField(
                  controller: _name,
                  textCapitalization: TextCapitalization.words,
                  maxLength: 40,
                  onChanged: (_) => setState(() {}),
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.text),
                  decoration: InputDecoration(
                    hintText: l10n.onbNameHint,
                    counterText: '',
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon:
                        const Icon(Icons.person_outline_rounded, color: AppColors.textMuted),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFE5E7F1), width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppColors.primary, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              // AGE GATE neutral: dropdown de AÑO de nacimiento.
              DropdownButtonFormField<int>(
                initialValue: _birthYear,
                isExpanded: true,
                onChanged: (v) => setState(() => _birthYear = v),
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.text),
                decoration: InputDecoration(
                  hintText: l10n.ageGateYearHint,
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon:
                      const Icon(Icons.cake_outlined, color: AppColors.textMuted),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFE5E7F1), width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
                items: [
                  for (final y in years)
                    DropdownMenuItem(value: y, child: Text('$y')),
                ],
              ),
              if (_error) ...[
                const SizedBox(height: 8),
                Text(l10n.profileEditSaveError,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.coral)),
              ],
              const SizedBox(height: 16),
              PrimaryButton(
                label: _saving ? l10n.profileEditSaving : l10n.commonContinue,
                expand: true,
                onPressed: _canSave ? _save : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
