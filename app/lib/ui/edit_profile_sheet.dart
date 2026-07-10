import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../core/theme/app_colors.dart';
import '../l10n/app_localizations.dart';
import '../data/models/profile_models.dart';
import '../data/providers.dart';
import 'app_avatar.dart';
import 'primary_button.dart';

/// Abre la hoja de edición de perfil (nombre, país, color de avatar, bio).
/// También sirve para pedir el nombre a usuarios existentes sin nombre.
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
    if (name.isEmpty) {
      setState(() => _error = l10n.profileEditNameError);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      // Zona horaria: best-effort silencioso (offset actual del dispositivo).
      final off = DateTime.now().timeZoneOffset;
      final tz = 'UTC${off.isNegative ? '-' : '+'}${off.inHours.abs()}'
          '${off.inMinutes.abs() % 60 == 0 ? '' : ':30'}';
      await ref.read(progressRepositoryProvider).setProfile(
            name: name,
            country: _country,
            bio: _bio.text.trim(),
            avatarColor: _color,
            birthdayDay: _bDay,
            birthdayMonth: _bMonth,
            gender: _gender,
            timezone: tz,
          );
      ref.invalidate(profileProvider);
      ref.invalidate(leagueProvider); // el nombre aparece en ligas
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = l10n.profileEditSaveError;
        });
      }
    }
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
              Center(child: AppAvatar(initial: initial, colorHex: _color, size: 84)),
              const SizedBox(height: 18),
              Text(l10n.authFieldName,
                  style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.text)),
              const SizedBox(height: 8),
              TextField(
                controller: _name,
                textCapitalization: TextCapitalization.words,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                decoration: _dec(l10n.profileEditNameHint),
              ),
              const SizedBox(height: 16),
              Text(l10n.profileEditAvatarColor,
                  style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.text)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final c in kAvatarColors)
                    GestureDetector(
                      onTap: () => setState(() => _color = c),
                      child: AppAvatar(
                          initial: initial, colorHex: c, size: 44, selected: _color == c),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text(l10n.profileEditCountry,
                  style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.text)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final entry in kCountries.entries)
                    _CountryChip(
                      iso: entry.key,
                      flag: entry.value.flag,
                      name: entry.value.name,
                      selected: _country == entry.key,
                      onTap: () => setState(() =>
                          _country = _country == entry.key ? null : entry.key),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              // Cumpleaños OPCIONAL — SOLO día y mes (sin año, a propósito:
              // sirve para saludos, no calcula edad). Deseleccionable.
              Text(l10n.profileEditBirthday,
                  style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.text)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int?>(
                      initialValue: _bDay,
                      decoration: _dec(l10n.profileEditDay),
                      items: [
                        DropdownMenuItem(value: null, child: Text('—')),
                        for (var d = 1; d <= 31; d++)
                          DropdownMenuItem(value: d, child: Text('$d')),
                      ],
                      onChanged: (v) => setState(() => _bDay = v),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<int?>(
                      initialValue: _bMonth,
                      decoration: _dec(l10n.profileEditMonth),
                      items: [
                        DropdownMenuItem(value: null, child: Text('—')),
                        for (var m = 1; m <= 12; m++)
                          DropdownMenuItem(
                            value: m,
                            child: Text(DateFormat.MMMM(
                                    Localizations.localeOf(context).toString())
                                .format(DateTime(2024, m))),
                          ),
                      ],
                      onChanged: (v) => setState(() => _bMonth = v),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Género OPCIONAL (con "prefiero no decirlo"); tocar de nuevo
              // deselecciona.
              Text(l10n.profileEditGender,
                  style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.text)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final (code, label) in [
                    ('female', l10n.genderFemale),
                    ('male', l10n.genderMale),
                    ('other', l10n.genderOther),
                    ('prefer_not_to_say', l10n.genderPreferNot),
                  ])
                    _GenderChip(
                      label: label,
                      selected: _gender == code,
                      onTap: () => setState(
                          () => _gender = _gender == code ? null : code),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text(l10n.profileEditBio,
                  style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.text)),
              const SizedBox(height: 8),
              TextField(
                controller: _bio,
                maxLength: 160,
                maxLines: 2,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                decoration: _dec(l10n.profileEditBioHint),
              ),
              if (_error != null)
                Text(_error!,
                    style: const TextStyle(
                        color: AppColors.hearts, fontWeight: FontWeight.w800, fontSize: 12.5)),
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

class _CountryChip extends StatelessWidget {
  const _CountryChip(
      {required this.iso,
      required this.flag,
      required this.name,
      required this.selected,
      required this.onTap});
  final String iso, flag, name;
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
        child: Text('$flag $name',
            style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: selected ? Colors.white : AppColors.text)),
      ),
    );
  }
}
