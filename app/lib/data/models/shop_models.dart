/// Estado de la Tienda (de shop_status).
class ShopStatus {
  const ShopStatus({
    required this.gold,
    required this.hearts,
    required this.freezes,
    required this.chestAvailable,
  });
  final int gold;
  final int hearts;
  final int freezes;
  final bool chestAvailable;

  factory ShopStatus.fromJson(Map<String, dynamic> j) => ShopStatus(
        gold: (j['gold'] as num?)?.toInt() ?? 0,
        hearts: (j['hearts'] as num?)?.toInt() ?? 5,
        freezes: (j['freezes'] as num?)?.toInt() ?? 0,
        chestAvailable: j['chest_available'] as bool? ?? true,
      );

  static const empty = ShopStatus(gold: 0, hearts: 5, freezes: 0, chestAvailable: true);
}
