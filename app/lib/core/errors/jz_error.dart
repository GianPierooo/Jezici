import 'dart:async';
import 'dart:io' show SocketException;

import 'package:supabase_flutter/supabase_flutter.dart'
    show AuthException, PostgrestException;

/// TIPO de error de dominio de Jezici (deuda #2 de ARQUITECTURA_ANALISIS: "los
/// errores nunca se diseñaron"). Antes: excepciones crudas de Supabase llegaban al
/// widget y la i18n se hacía por `contains()` del texto de Postgres, repartido por
/// pantallas → clases enteras de fallo sin NINGÚN síntoma (ni UI ni Sentry).
///
/// Ahora la capa de datos traduce UNA vez (`JzError.from`) a un tipo con `kind` +
/// `reason`. La UI decide el mensaje por el TIPO (i18n), y Sentry ve el fallo real.
/// Robusto: usa el SQLSTATE de Postgres donde existe (42501 RLS, 23505 unique,
/// PGRST* de PostgREST); los errores de negocio son `raise exception '<texto>'`
/// (SQLSTATE P0001 genérico) → su TEXTO es el contrato del servidor, así que se
/// mapea por un token conocido en UNA tabla central+testeada (no substring suelto).
enum JzErrorKind {
  network, // sin conexión / timeout
  auth, // sesión inválida / no autenticado
  denied, // RLS / 18+ / bloqueo / no permitido (403/42501)
  rateLimited, // demasiadas acciones
  conflict, // ya existe (amigos, @handle tomado, unique)
  notFound, // no existe
  validation, // datos inválidos (campo requerido / formato)
  server, // fallo del servidor conocido (P0001 sin token) / 5xx
  unknown, // no clasificado
}

class JzError implements Exception {
  const JzError(this.kind, {this.reason, this.cause, this.rpc});

  final JzErrorKind kind;

  /// Token estable del servidor (p.ej. 'already_friends', 'handle_taken',
  /// 'rate_limited', 'social_unavailable'…) para la copia FINA de la UI. null si
  /// no se reconoció un motivo específico.
  final String? reason;

  /// Excepción original (para Sentry / depuración). No se muestra al usuario.
  final Object? cause;

  /// Nombre de la RPC / operación donde ocurrió (contexto de Sentry, sin PII).
  final String? rpc;

  /// Los de red son ruido benigno de una beta chica: no se reportan a Sentry
  /// (el `beforeSend` de Sentry también los filtra; esto evita el envío).
  bool get isBenign => kind == JzErrorKind.network;

  /// ¿Merece llegar a Sentry? Solo los INESPERADOS (bug real): fallo de servidor,
  /// no clasificado o de sesión. Los errores ESPERADOS del usuario (validación,
  /// conflicto tipo @handle tomado, rate limit, denegado, no encontrado) se
  /// muestran en la UI pero NO se reportan → no ahogan el dashboard.
  bool get shouldReport => switch (kind) {
        JzErrorKind.network ||
        JzErrorKind.validation ||
        JzErrorKind.conflict ||
        JzErrorKind.rateLimited ||
        JzErrorKind.denied ||
        JzErrorKind.notFound =>
          false,
        JzErrorKind.auth || JzErrorKind.server || JzErrorKind.unknown => true,
      };

  JzError withRpc(String? name) =>
      rpc == name ? this : JzError(kind, reason: reason, cause: cause, rpc: name ?? rpc);

  @override
  String toString() =>
      'JzError(${kind.name}${reason == null ? '' : ':$reason'}${rpc == null ? '' : ' @$rpc'})';

  /// Traduce CUALQUIER error (excepción de Supabase, de red, o un `Exception`
  /// con el texto del servidor) a un `JzError`. Idempotente. UN solo lugar.
  factory JzError.from(Object? e, {String? rpc}) {
    if (e is JzError) return rpc == null ? e : e.withRpc(rpc);

    final msg = (e?.toString() ?? '').toLowerCase();

    // 1) RED (offline / timeout): antes de nada, para no reportar ruido.
    if (e is SocketException ||
        e is TimeoutException ||
        _hasAny(msg, const [
          'socketexception',
          'clientexception',
          'failed host lookup',
          'connection closed',
          'connection reset',
          'connection refused',
          'network is unreachable',
          'timeout',
          'timed out',
        ])) {
      return JzError(JzErrorKind.network, cause: e, rpc: rpc);
    }

    // 2) AUTH (sesión): tipo dedicado o token de sesión.
    if (e is AuthException ||
        _hasAny(msg, const ['not authenticated', 'auth required', 'jwt', 'invalid token'])) {
      final reason = _hasAny(msg, const ['already registered', 'already been registered'])
          ? 'already_registered'
          : (_hasAny(msg, const ['password']) ? 'password' : null);
      // "ya registrado" es un conflicto de alta, no un fallo de sesión.
      if (reason == 'already_registered') {
        return JzError(JzErrorKind.conflict, reason: reason, cause: e, rpc: rpc);
      }
      return JzError(JzErrorKind.auth, reason: reason, cause: e, rpc: rpc);
    }

    // 3) SQLSTATE estructural (robusto, no depende del texto).
    final code = e is PostgrestException ? (e.code ?? '') : '';
    if (code == '42501') return JzError(JzErrorKind.denied, reason: 'rls', cause: e, rpc: rpc);
    if (code == '23505') {
      return JzError(JzErrorKind.conflict, reason: 'unique', cause: e, rpc: rpc);
    }
    if (code.startsWith('PGRST30')) {
      // PGRST301/302 = JWT expirado/ausente.
      return JzError(JzErrorKind.auth, cause: e, rpc: rpc);
    }

    // 3b) SQLSTATE CUSTOM 'JZxxx' (2ª pasada de errores tipados): las RPC de
    //     negocio MIGRADAS levantan `jz_err(reason, kind)` → el KIND viene del
    //     CÓDIGO (robusto ante reescrituras del texto) y el reason es el MENSAJE
    //     = token estable EXACTO (no substring). Las RPC aún no migradas siguen
    //     cayendo a la tabla de tokens por texto (paso 4) → compatibilidad total.
    if (code.length == 5 && code.startsWith('JZ')) {
      final r = e is PostgrestException ? e.message.trim() : '';
      return JzError(
        switch (code) {
          'JZ401' => JzErrorKind.auth,
          'JZ403' => JzErrorKind.denied,
          'JZ404' => JzErrorKind.notFound,
          'JZ409' => JzErrorKind.conflict,
          'JZ429' => JzErrorKind.rateLimited,
          _ => JzErrorKind.validation, // JZ422 + cualquier otro JZ
        },
        reason: r.isEmpty ? null : r,
        cause: e,
        rpc: rpc,
      );
    }

    // 4) Errores de NEGOCIO (raise exception, SQLSTATE P0001): el texto es el
    //    contrato. Tabla ORDENADA de tokens conocidos → (reason, kind). El orden
    //    importa (p.ej. 'social unavailable' antes que 'unavailable').
    for (final row in _tokens) {
      if (_hasAny(msg, row.needles)) {
        return JzError(row.kind, reason: row.reason, cause: e, rpc: rpc);
      }
    }

    // 5) Sin clasificar: server si venía de Postgres, unknown si no.
    return JzError(e is PostgrestException ? JzErrorKind.server : JzErrorKind.unknown,
        cause: e, rpc: rpc);
  }
}

class _Tok {
  const _Tok(this.reason, this.kind, this.needles);
  final String reason;
  final JzErrorKind kind;
  final List<String> needles;
}

/// Tabla ÚNICA de motivos de negocio del servidor (los `raise exception` de las
/// RPC). ORDENADA: lo más específico primero. Cambiar aquí, no en las pantallas.
const List<_Tok> _tokens = [
  _Tok('rate_limited', JzErrorKind.rateLimited, ['rate_limited', 'rate limit', 'too many']),
  _Tok('handle_change_rate', JzErrorKind.rateLimited, ['handle_change_rate']),
  _Tok('already_friends', JzErrorKind.conflict, ['already friends', 'already_friends']),
  _Tok('self', JzErrorKind.validation, ['cannot add yourself', 'cannot_add_yourself']),
  _Tok('handle_taken', JzErrorKind.conflict, ['handle_taken']),
  _Tok('handle_reserved', JzErrorKind.conflict, ['handle_reserved']),
  _Tok('invalid_handle', JzErrorKind.validation, ['invalid_handle']),
  _Tok('gender_required', JzErrorKind.validation, ['gender_required']),
  _Tok('birthday_required', JzErrorKind.validation, ['birthday_required']),
  _Tok('insufficient_gold', JzErrorKind.conflict, ['insufficient_gold']),
  // 18+/moderación/bloqueo → denegado. 'social unavailable'/'account restricted'
  // llevan reason propio para la copia de Conversar; el 'unavailable' pelado =
  // el otro te bloqueó.
  _Tok('social_unavailable', JzErrorKind.denied,
      ['social unavailable', 'account restricted', 'not adult', 'adult only', '18+']),
  _Tok('admin_only', JzErrorKind.denied, ['admin only']),
  _Tok('blocked', JzErrorKind.denied, ['blocked', 'unavailable', 'restricted', 'not allowed']),
  _Tok('not_found', JzErrorKind.notFound, ['not found', 'no rows', 'does not exist']),
  _Tok('required', JzErrorKind.validation, ['required', 'invalid', 'missing']),
];

bool _hasAny(String haystack, List<String> needles) {
  for (final n in needles) {
    if (haystack.contains(n)) return true;
  }
  return false;
}
