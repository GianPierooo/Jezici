import 'dart:async';
import 'dart:io' show SocketException;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jezici/core/errors/jz_error.dart';
import 'package:jezici/core/errors/jz_error_message.dart';
import 'package:jezici/l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show PostgrestException;

/// ERRORES TIPADOS (deuda #2): el mapeo central `JzError.from` traduce las
/// excepciones de Supabase/Postgres a un TIPO (kind + reason) una sola vez.
/// Antes esto se hacía por `contains()` del texto de Postgres, repartido por
/// pantallas → clases enteras de fallo sin síntoma.
void main() {
  JzError from(String msg) => JzError.from(Exception(msg));

  test('SQLSTATE estructural: 42501=denied (RLS), 23505=conflict (unique)', () {
    expect(JzError.from(const PostgrestException(message: 'x', code: '42501')).kind,
        JzErrorKind.denied);
    expect(JzError.from(const PostgrestException(message: 'x', code: '23505')).kind,
        JzErrorKind.conflict);
    expect(JzError.from(const PostgrestException(message: 'x', code: 'PGRST301')).kind,
        JzErrorKind.auth);
  });

  test('SQLSTATE CUSTOM JZxxx (mig 167): kind por CÓDIGO + reason por MENSAJE', () {
    // Las RPC migradas levantan jz_err(reason, kind) → code 'JZxxx' + message=token.
    JzError jz(String code, String msg) =>
        JzError.from(PostgrestException(message: msg, code: code));
    expect(jz('JZ409', 'handle_taken').kind, JzErrorKind.conflict);
    expect(jz('JZ409', 'handle_taken').reason, 'handle_taken'); // token EXACTO, no substring
    expect(jz('JZ422', 'invalid_handle').kind, JzErrorKind.validation);
    expect(jz('JZ401', 'auth required').kind, JzErrorKind.auth);
    expect(jz('JZ403', 'social_unavailable').kind, JzErrorKind.denied);
    expect(jz('JZ404', 'not_found').kind, JzErrorKind.notFound);
    expect(jz('JZ429', 'handle_change_rate').kind, JzErrorKind.rateLimited);
    // Aunque el MENSAJE se reescriba, el KIND se mantiene (viene del código).
    expect(jz('JZ409', 'ese handle ya existe').kind, JzErrorKind.conflict);
    // Fallback intacto: sin code JZ (RPC no migrada), el texto sigue mapeando.
    expect(from('handle_taken').reason, 'handle_taken');
  });

  test('red / timeout → network (benigno, no se reporta)', () {
    expect(JzError.from(const SocketException('no net')).kind, JzErrorKind.network);
    expect(JzError.from(TimeoutException('slow')).kind, JzErrorKind.network);
    expect(from('Failed host lookup: x').kind, JzErrorKind.network);
    expect(from('ClientException with SocketException').kind, JzErrorKind.network);
    expect(JzError.from(const SocketException('x')).shouldReport, isFalse);
  });

  test('motivos de negocio del servidor → kind + reason (tabla central)', () {
    expect(from('already friends').reason, 'already_friends');
    expect(from('already friends').kind, JzErrorKind.conflict);
    expect(from('rate_limited: friend/day').kind, JzErrorKind.rateLimited);
    expect(from('handle_taken').kind, JzErrorKind.conflict);
    expect(from('handle_taken').reason, 'handle_taken');
    expect(from('handle_change_rate').kind, JzErrorKind.rateLimited);
    expect(from('social unavailable').reason, 'social_unavailable');
    expect(from('account restricted').reason, 'social_unavailable');
    expect(from('unavailable').reason, 'blocked'); // bloqueo pelado
    expect(from('unavailable').kind, JzErrorKind.denied);
    expect(from('gender_required').kind, JzErrorKind.validation);
    expect(from('admin only').kind, JzErrorKind.denied);
    expect(from('not found').kind, JzErrorKind.notFound);
    expect(from('cannot add yourself').reason, 'self');
  });

  test('desconocido → unknown; PostgrestException sin token → server', () {
    expect(from('boom').kind, JzErrorKind.unknown);
    expect(JzError.from(const PostgrestException(message: 'weird db thing')).kind,
        JzErrorKind.server);
  });

  test('shouldReport: solo los INESPERADOS llegan a Sentry', () {
    // Esperados del usuario → NO reportar (no ahogar el dashboard).
    for (final k in [
      JzErrorKind.network,
      JzErrorKind.validation,
      JzErrorKind.conflict,
      JzErrorKind.rateLimited,
      JzErrorKind.denied,
      JzErrorKind.notFound,
    ]) {
      expect(JzError(k).shouldReport, isFalse, reason: k.name);
    }
    // Bugs reales → SÍ reportar.
    for (final k in [JzErrorKind.auth, JzErrorKind.server, JzErrorKind.unknown]) {
      expect(JzError(k).shouldReport, isTrue, reason: k.name);
    }
  });

  test('from es idempotente y adjunta rpc', () {
    final a = from('handle_taken');
    expect(JzError.from(a), same(a));
    expect(JzError.from(a, rpc: 'claim_handle').rpc, 'claim_handle');
  });

  group('i18n del mensaje por TIPO (es/en/pt)', () {
    for (final loc in ['es', 'en', 'pt']) {
      test('$loc: cada kind tiene mensaje no vacío y distinto del token crudo', () async {
        final l10n = await AppLocalizations.delegate.load(Locale(loc));
        for (final k in JzErrorKind.values) {
          final msg = jzErrorMessage(JzError(k), l10n);
          expect(msg.trim().isNotEmpty, isTrue, reason: '$loc/${k.name}');
        }
        // El mensaje NO es el texto crudo de Postgres.
        final crude = errorMessageFor(Exception('rate_limited'), l10n);
        expect(crude, jzErrorMessage(const JzError(JzErrorKind.rateLimited), l10n));
      });
    }
  });
}
