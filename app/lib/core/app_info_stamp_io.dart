// Sello de build en runtime — plataformas NO-web (móvil/desktop/VM de tests):
// no hay window global, así que no hay sello inyectado. Cae al compile-time.
String? runtimeBuildStamp() => null;
