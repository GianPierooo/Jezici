import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jezici/features/conversar/friends.dart';
import 'package:jezici/l10n/app_localizations.dart';

/// FIX del sistema de amistad · el cliente ya NO muestra "revisa el código" para
/// TODO error (bug #1). friendErrorMessage traduce el motivo REAL del servidor;
/// sentFriendMessage distingue solicitud enviada de amistad mutua aceptada.
/// (El flujo end-to-end — notificación + sugerencias — se verifica con cliente
/// real en tools/content/verify_friends.py.)
void main() {
  late AppLocalizations es;
  setUpAll(() async {
    es = await AppLocalizations.delegate.load(const Locale('es'));
  });

  Object err(String msg) => Exception(msg);

  test('cada error del servidor mapea a su mensaje específico (no genérico)', () {
    const fallback = 'FALLBACK';
    expect(friendErrorMessage(err('already friends'), es, fallback), es.convErrAlready);
    expect(friendErrorMessage(err('cannot add yourself'), es, fallback), es.convErrSelf);
    expect(friendErrorMessage(err('rate_limited: friend_request/day'), es, fallback),
        es.convErrRate);
    expect(friendErrorMessage(err('social unavailable'), es, fallback), es.convErrUnavailable);
    expect(friendErrorMessage(err('account restricted'), es, fallback), es.convErrUnavailable);
    expect(friendErrorMessage(err('unavailable'), es, fallback), es.convErrBlocked);
    // 'code not found' y desconocidos → el fallback del origen (revisa el código).
    expect(friendErrorMessage(err('code not found'), es, fallback), fallback);
    expect(friendErrorMessage(err('boom'), es, fallback), fallback);
  });

  test('sentFriendMessage: pending vs accepted (mutuo)', () {
    expect(sentFriendMessage({'status': 'pending'}, es), es.convRequestSent);
    expect(sentFriendMessage({'status': 'accepted'}, es), es.convNowFriends);
    expect(sentFriendMessage(null, es), es.convRequestSent);
  });
}
