import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Versión del contenido legal (Privacidad+Términos). Súbela cuando el texto
/// cambie (p. ej. tras la revisión de abogado) → permite detectar y disparar
/// re-consentimiento (ver `accept_legal`/`my_legal_version`, mig 062).
const kLegalVersion = '2026-06-draft';

/// Páginas legales (Privacidad / Términos). **BORRADOR** para la beta: revisar
/// con un abogado antes de publicar en tiendas (no es asesoría legal acreditada).
class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key, required this.kind});
  final LegalKind kind;

  factory LegalScreen.privacy() => const LegalScreen(kind: LegalKind.privacy);
  factory LegalScreen.terms() => const LegalScreen(kind: LegalKind.terms);

  @override
  Widget build(BuildContext context) {
    final doc = kind == LegalKind.privacy ? _privacy : _terms;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background, elevation: 0, foregroundColor: AppColors.text,
        title: Text(doc.title, style: const TextStyle(fontWeight: FontWeight.w900)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 32),
        children: [
          // Aviso honesto de beta (marca): borrador + datos + certificado interno.
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF4E0),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFF0D49B)),
            ),
            child: const Row(children: [
              Icon(Icons.info_outline_rounded, size: 18, color: Color(0xFFB07B16)),
              SizedBox(width: 9),
              Expanded(
                child: Text(
                  'Versión beta. Este texto es un BORRADOR pendiente de revisión legal. '
                  'Los certificados son internos de Jezici (no oficiales) y los pagos no están activos.',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF8A6314), height: 1.35),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 14),
          Text('Última actualización: junio de 2026 · versión $kLegalVersion',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
          const SizedBox(height: 14),
          for (final s in doc.sections) ...[
            Text(s.$1, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.text)),
            const SizedBox(height: 6),
            Text(s.$2, style: const TextStyle(fontSize: 13.5, height: 1.45, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}

enum LegalKind { privacy, terms }

class _Doc {
  const _Doc(this.title, this.sections);
  final String title;
  final List<(String, String)> sections;
}

const _privacy = _Doc('Política de Privacidad', [
  ('1. Quiénes somos',
      'Jezici es una aplicación para aprender idiomas. Esta política explica qué datos recogemos y cómo los usamos.'),
  ('2. Datos que recogemos',
      'Cuenta: tu correo electrónico y un identificador. Progreso de aprendizaje: lecciones, exámenes, racha, habilidades, vocabulario y certificados. Preferencias: estilo de notificaciones, meta diaria y horarios. Datos técnicos básicos para que la app funcione.'),
  ('3. Micrófono y voz',
      'En los ejercicios de pronunciación usamos el reconocimiento de voz de tu navegador/dispositivo (Web Speech API). La comparación con el texto esperado ocurre en tu dispositivo de forma determinista; no almacenamos grabaciones de tu voz.'),
  ('4. Notificaciones',
      'Si las activas, enviamos recordatorios (racha, meta, repaso) mediante notificaciones locales y/o push. Puedes desactivarlas y definir un horario de silencio en Ajustes.'),
  ('5. Cómo usamos los datos',
      'Para darte tu plan y progreso, calcular tu nivel y las 4 habilidades, emitir certificados, mostrar ligas y mejorar la app con métricas agregadas (sin identificarte individualmente).'),
  ('6. Almacenamiento y proveedores',
      'Los datos se guardan en nuestra infraestructura (Supabase) con control de acceso por fila (RLS). No vendemos tus datos.'),
  ('7. Tus derechos',
      'Puedes acceder, corregir o eliminar tu cuenta y tus datos. Escríbenos a shadowgames.devteam@gmail.com.'),
  ('8. Menores',
      'No está dirigida a menores de la edad mínima legal de tu país sin consentimiento de un tutor.'),
  ('9. Cambios',
      'Podemos actualizar esta política; avisaremos en la app cuando haya cambios relevantes.'),
  ('10. Contacto', 'shadowgames.devteam@gmail.com'),
]);

const _terms = _Doc('Términos y Condiciones', [
  ('1. Aceptación',
      'Al usar Jezici aceptas estos términos. Si no estás de acuerdo, no uses la app.'),
  ('2. Tu cuenta',
      'Eres responsable de la actividad de tu cuenta y de mantener tu acceso seguro.'),
  ('3. Licencia de uso',
      'Te damos una licencia personal, no exclusiva e intransferible para usar la app con fines de aprendizaje.'),
  ('4. Uso aceptable',
      'No abuses del servicio, no intentes vulnerar la seguridad, no extraigas el contenido de forma masiva ni lo redistribuyas.'),
  ('5. Contenido',
      'El contenido educativo, la marca y la mascota son de Jezici. El audio de los ejercicios se genera con voz sintética de texto fijo.'),
  ('6. Certificados',
      'Los certificados acreditan tu desempeño en el examen dentro de Jezici (Fase 1) e incluyen un folio y código de verificación. No equivalen, por sí mismos, a certificaciones oficiales de terceros.'),
  ('7. Premium y pagos',
      'Algunas funciones podrán requerir una suscripción. Los precios y condiciones se mostrarán antes de pagar. (Los pagos no están activos en esta versión.)'),
  ('8. Garantías y responsabilidad',
      'La app se ofrece "tal cual". En la medida que permita la ley, no respondemos por daños indirectos derivados del uso.'),
  ('9. Terminación',
      'Podemos suspender cuentas que incumplan estos términos. Puedes dejar de usar la app y eliminar tu cuenta cuando quieras.'),
  ('10. Contacto', 'shadowgames.devteam@gmail.com'),
]);
