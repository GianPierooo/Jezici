/// Configuración de autenticación (beta).
///
/// En la BETA el acceso es **solo con Google** (datos reales, sin fricción de
/// verificación de correo). El registro/login por email+contraseña se OCULTA
/// tras este flag — NO se borra el código: volverá en el lanzamiento oficial
/// poniendo esto en `true`.
const bool kAuthEmailEnabled = false;
