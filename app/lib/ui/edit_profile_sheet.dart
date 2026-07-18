import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../core/errors/error_reporter.dart';
import '../core/theme/app_colors.dart';
import '../l10n/app_localizations.dart';
import '../data/models/profile_models.dart';
import '../data/providers.dart';
import 'app_avatar.dart';
import 'primary_button.dart';

/// Editar perfil (T5): nombre, color de avatar (selector de COLORES), país
/// (buscador con bandera), GÉNERO obligatorio, CUMPLEAÑOS día+mes obligatorio,
/// bio. El AÑO viene del age gate y NO se re-pide. Género/cumpleaños se validan
/// también en el servidor (set_profile_required).
Future<void> showEditProfileSheet(
    BuildContext context, WidgetRef ref, ProfileInfo profile) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _EditProfileSheet(profile: profile),
  );
}

class _EditProfileSheet extends ConsumerStatefulWidget {
  const _EditProfileSheet({required this.profile});
  final ProfileInfo profile;
  @override
  ConsumerState<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends ConsumerState<_EditProfileSheet> {
  late final TextEditingController _name =
      TextEditingController(text: widget.profile.name ?? '');
  late final TextEditingController _bio =
      TextEditingController(text: widget.profile.bio ?? '');
  late String _color = widget.profile.avatarColor;
  late String? _country = widget.profile.country;
  late int? _bDay = widget.profile.birthdayDay;
  late int? _bMonth = widget.profile.birthdayMonth;
  late String? _gender = widget.profile.gender;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _bio.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final name = _name.text.trim();
    // Validación de cliente (feedback rápido); el servidor es la autoridad.
    if (name.isEmpty) {
      setState(() => _error = l10n.profileEditNameError);
      return;
    }
    if (_gender == null) {
      setState(() => _error = l10n.profileEditGenderError);
      return;
    }
    if (_bDay == null || _bMonth == null) {
      setState(() => _error = l10n.profileEditBirthdayError);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final off = DateTime.now().timeZoneOffset;
      final tz = 'UTC${off.isNegative ? '-' : '+'}${off.inHours.abs()}'
          '${off.inMinutes.abs() % 60 == 0 ? '' : ':30'}';
      await ref.read(progressRepositoryProvider).setProfileRequired(
            name: name,
            gender: _gender!,
            birthdayDay: _bDay!,
            birthdayMonth: _bMonth!,
            country: _country,
            bio: _bio.text.trim(),
            avatarColor: _color,
            timezone: tz,
          );
      ref.invalidate(profileProvider);
      ref.invalidate(leagueProvider); // el nombre aparece en ligas
      if (mounted) Navigator.of(context).pop();
    } catch (e, st) {
      // Motivo tipado (mapeo central) + reporte a Sentry de lo inesperado (los
      // *_required son validación esperada → no llegan a Sentry).
      final jz = reportError(e, stackTrace: st, rpc: 'set_profile_required');
      final s = e.toString();
      if (mounted) {
        setState(() {
          _saving = false;
          _error = jz.reason == 'gender_required' || s.contains('gender_required')
              ? l10n.profileEditGenderError
              : jz.reason == 'birthday_required' || s.contains('birthday_required')
                  ? l10n.profileEditBirthdayError
                  : s.contains('name_required')
                      ? l10n.profileEditNameError
                      : l10n.profileEditSaveError;
        });
      }
    }
  }

  Future<void> _pickCountry() async {
    final iso = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _CountryPickerSheet(),
    );
    if (iso != null && mounted) setState(() => _country = iso);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final initial = _name.text.trim().isEmpty
        ? '🦜'
        : _name.text.trim().characters.first.toUpperCase();
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        padding: const EdgeInsets.fromLTRB(22, 14, 22, 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD9DBE9),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              // Preview EN VIVO: el color elegido se aplica a la inicial.
              Center(child: AppAvatar(initial: initial, colorHex: _color, size: 88)),
              const SizedBox(height: 18),
              _label(l10n.authFieldName, required: true),
              const SizedBox(height: 8),
              TextField(
                controller: _name,
                textCapitalization: TextCapitalization.words,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                decoration: _dec(l10n.profileEditNameHint),
              ),
              const SizedBox(height: 18),
              // ── AVATAR: selector de COLORES ──
              _label(l10n.profileEditAvatarColor),
              const SizedBox(height: 12),
              Wrap(
                spacing: 14,
                runSpacing: 14,
                children: [
                  for (final c in kAvatarColors)
                    _ColorSwatch(
                      hex: c,
                      selected: _color == c,
                      onTap: () => setState(() => _color = c),
                    ),
                ],
              ),
              const SizedBox(height: 18),
              // ── PAÍS: buscador con bandera ──
              _label(l10n.profileEditCountry),
              const SizedBox(height: 8),
              _FieldButton(
                icon: Icons.public_rounded,
                onTap: _pickCountry,
                child: _country == null
                    ? Text(l10n.profileEditCountryHint,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textMuted))
                    : Text('${countryFlag(_country)}  ${countryName(_country)}',
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.text)),
              ),
              const SizedBox(height: 18),
              // ── CUMPLEAÑOS: día + mes OBLIGATORIOS (el año viene del age gate) ──
              _label(l10n.profileEditBirthday, required: true),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      initialValue: _bDay,
                      isExpanded: true,
                      decoration: _dec(l10n.profileEditDay),
                      hint: Text(l10n.profileEditDay),
                      items: [
                        for (var d = 1; d <= 31; d++)
                          DropdownMenuItem(value: d, child: Text('$d')),
                      ],
                      onChanged: (v) => setState(() => _bDay = v),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<int>(
                      initialValue: _bMonth,
                      isExpanded: true,
                      decoration: _dec(l10n.profileEditMonth),
                      hint: Text(l10n.profileEditMonth),
                      items: [
                        for (var m = 1; m <= 12; m++)
                          DropdownMenuItem(
                            value: m,
                            child: Text(
                              DateFormat.MMMM(Localizations.localeOf(context).toString())
                                  .format(DateTime(2024, m)),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                      onChanged: (v) => setState(() => _bMonth = v),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              // ── GÉNERO: OBLIGATORIO (sin deseleccionar) ──
              _label(l10n.profileEditGender, required: true),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final (code, lbl) in [
                    ('female', l10n.genderFemale),
                    ('male', l10n.genderMale),
                    ('other', l10n.genderOther),
                    ('prefer_not_to_say', l10n.genderPreferNot),
                  ])
                    _GenderChip(
                      label: lbl,
                      selected: _gender == code,
                      // Obligatorio: tocar SELECCIONA (no deselecciona).
                      onTap: () => setState(() => _gender = code),
                    ),
                ],
              ),
              const SizedBox(height: 18),
              _label(l10n.profileEditBio),
              const SizedBox(height: 8),
              TextField(
                controller: _bio,
                maxLength: 160,
                maxLines: 2,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                decoration: _dec(l10n.profileEditBioHint),
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2, bottom: 6),
                  child: Text(_error!,
                      style: const TextStyle(
                          color: AppColors.hearts, fontWeight: FontWeight.w800, fontSize: 12.5)),
                ),
              const SizedBox(height: 8),
              PrimaryButton(
                label: _saving ? l10n.profileEditSaving : l10n.profileEditSave,
                expand: true,
                onPressed: _saving ? null : _save,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text, {bool required = false}) => Row(
        children: [
          Flexible(
            child: Text(text,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.text)),
          ),
          if (required)
            const Padding(
              padding: EdgeInsets.only(left: 3),
              child: Text('*',
                  style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.hearts)),
            ),
        ],
      );

  InputDecoration _dec(String hint) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        counterText: '',
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE5E7F1), width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      );
}

/// Muestra de color seleccionable (círculo con gradiente). Al elegir: anillo
/// blanco + check + un leve rebote (reduce-motion-aware).
class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({required this.hex, required this.selected, required this.onTap});
  final String hex;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.of(context).disableAnimations;
    final base = AppAvatar.parseHex(hex);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: selected && !reduce ? 1.12 : 1.0,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutBack,
        child: Container(
          width: 46,
          height: 46,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [base.withValues(alpha: 0.85), base],
            ),
            shape: BoxShape.circle,
            border: selected ? Border.all(color: Colors.white, width: 3) : null,
            boxShadow: [
              BoxShadow(
                color: base.withValues(alpha: selected ? 0.55 : 0.3),
                offset: const Offset(0, 4),
                blurRadius: selected ? 12 : 8,
              ),
            ],
          ),
          child: selected
              ? const Icon(Icons.check_rounded, color: Colors.white, size: 22)
              : null,
        ),
      ),
    );
  }
}

/// Botón-campo (fila blanca con icono a la izquierda) que abre un selector.
class _FieldButton extends StatelessWidget {
  const _FieldButton({required this.icon, required this.child, required this.onTap});
  final IconData icon;
  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE5E7F1), width: 2),
          ),
          child: Row(children: [
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(width: 10),
            Expanded(child: child),
            const Icon(Icons.expand_more_rounded, color: Color(0xFFB9BDD0), size: 22),
          ]),
        ),
      ),
    );
  }
}

/// Selector de país con BUSCADOR (filtra por nombre; muestra bandera + nombre).
class _CountryPickerSheet extends StatefulWidget {
  const _CountryPickerSheet();
  @override
  State<_CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends State<_CountryPickerSheet> {
  final _q = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final needle = normalizeSearch(_query.trim());
    final entries = kCountries.entries
        .where((e) => needle.isEmpty || normalizeSearch(e.value.name).contains(needle))
        .toList()
      ..sort((a, b) => a.value.name.compareTo(b.value.name));
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.72,
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                  color: const Color(0xFFD9DBE9), borderRadius: BorderRadius.circular(3)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _q,
              autofocus: true,
              onChanged: (v) => setState(() => _query = v),
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              decoration: InputDecoration(
                hintText: l10n.profileEditCountrySearchHint,
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFE5E7F1), width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFE5E7F1), width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: entries.length,
                itemBuilder: (_, i) {
                  final e = entries[i];
                  return ListTile(
                    leading: Text(e.value.flag, style: const TextStyle(fontSize: 24)),
                    title: Text(e.value.name,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.text)),
                    onTap: () => Navigator.of(context).pop(e.key),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GenderChip extends StatelessWidget {
  const _GenderChip({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: selected ? AppColors.primary : const Color(0xFFE5E7F1), width: 2),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: selected ? Colors.white : AppColors.text)),
      ),
    );
  }
}
