import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/speech/mic_messages.dart';
import '../../core/speech/speech_lang.dart';
import '../../core/speech/speech_recognizer.dart';
import '../../core/theme/app_colors.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/primary_button.dart';
import '../learn/widgets/parrot_mascot.dart';
import 'friends.dart';

/// CONVERSAR — versión SEGURA y usable (GA7). NADA de chat con desconocidos ni
/// IA: práctica de conversación EN SOLITARIO/asíncrona (tema → escribe o habla →
/// respuesta modelo + autoevaluación), más captura de interés para la
/// conversación EN VIVO (Fase 2, con moderación + verificación de edad).
class ConversarScreen extends ConsumerWidget {
  const ConversarScreen({super.key});

  // Títulos/escenarios en español (compartidos); model+tips por idioma META del curso
  // (en/pt/fr/it/de/nl) → cada usuario ve la respuesta modelo en el idioma que aprende.
  // Autorado por profesores nativos (de/nl añadidos 2026-07-05; el resto vía gen_conversar.py).
  static const topics = <ConvTopic>[
    ConvTopic('cafe', "☕", {
      'en': ConvModel("Hi! Can I have a coffee and a piece of cake, please? How much is it?", ["Can I have…?", "How much is it?", "please / thank you"]),
      'pt': ConvModel("Oi, bom dia! Você pode me ver um café e um pedaço de bolo, por favor? Quanto fica?", ["Você pode me ver um…?", "Um café e um pedaço de bolo, por favor.", "Quanto fica?"]),
      'fr': ConvModel("Bonjour, je voudrais un café et une part de gâteau, s'il vous plaît. Combien ça coûte ?", ["Bonjour, je voudrais…", "…s'il vous plaît.", "Combien ça coûte ?"]),
      'it': ConvModel("Buongiorno! Vorrei un caffè e una fetta di torta, per favore. Quanto costa?", ["Vorrei un caffè…", "…e qualcosa da mangiare, per favore.", "Quanto costa?"]),
      'de': ConvModel("Guten Tag! Ich hätte gern einen Kaffee und ein Stück Kuchen, bitte. Was kostet das?", ["Ich hätte gern…", "…und etwas zu essen, bitte.", "Was kostet das?"]),
      'nl': ConvModel("Hallo! Mag ik een koffie en een stuk taart, alstublieft? Hoeveel kost dat?", ["Mag ik een koffie…?", "…en iets te eten, alstublieft.", "Hoeveel kost dat?"]),
    }),
    ConvTopic('intro', "👋", {
      'en': ConvModel("Hi, I'm Ana. Nice to meet you! I'm from Peru and I work as a teacher.", ["I'm…", "Nice to meet you", "I'm from… / I work as…"]),
      'pt': ConvModel("Oi, muito prazer! Eu sou a Ana, sou do Peru e trabalho como professora.", ["Muito prazer!", "Eu sou o/a…, sou do/da…", "Trabalho como…"]),
      'fr': ConvModel("Bonjour, je m'appelle Ana, enchantée ! Je viens du Pérou et je suis professeure.", ["Je m'appelle…", "Enchanté(e) !", "Je viens de… et je travaille comme…"]),
      'it': ConvModel("Ciao, mi chiamo Ana, piacere! Vengo dal Perù e faccio l'insegnante.", ["Mi chiamo…, piacere!", "Vengo da…", "Faccio l'insegnante / Lavoro come…"]),
      'de': ConvModel("Hallo! Ich heiße Ana. Ich komme aus Spanien und ich bin Lehrerin. Und du?", ["Ich heiße…", "Ich komme aus…", "Ich bin (von Beruf)…"]),
      'nl': ConvModel("Hoi, ik heet Ana, aangenaam! Ik kom uit Peru en ik werk als lerares.", ["Ik heet…, aangenaam!", "Ik kom uit…", "Ik werk als…"]),
    }),
    ConvTopic('airport', "✈️", {
      'en': ConvModel("Excuse me, where is gate 12? What time does the flight to Madrid leave?", ["Excuse me…", "Where is…?", "What time does… leave?"]),
      'pt': ConvModel("Com licença, onde fica o portão 12? E que horas sai o voo para Madri?", ["Com licença, onde fica o portão…?", "Que horas sai o voo para…?", "O voo está no horário?"]),
      'fr': ConvModel("Excusez-moi, où est la porte 12, s'il vous plaît ? À quelle heure part le vol pour Madrid ?", ["Excusez-moi, où est… ?", "À quelle heure part le vol pour… ?", "la porte 12"]),
      'it': ConvModel("Mi scusi, dov'è l'uscita 12? A che ora parte il volo per Madrid?", ["Mi scusi, dov'è l'uscita…?", "A che ora parte il volo per…?", "Da quale gate parte?"]),
      'de': ConvModel("Entschuldigung, von welchem Gate geht mein Flug? Und wann fliegt die Maschine ab?", ["Von welchem Gate geht…?", "Wann fliegt der Flug ab?", "Entschuldigung,…"]),
      'nl': ConvModel("Pardon, waar is gate 12? En hoe laat vertrekt de vlucht naar Madrid?", ["Pardon, waar is…?", "Hoe laat vertrekt de vlucht naar…?", "gate 12"]),
    }),
    ConvTopic('weekend', "🌤️", {
      'en': ConvModel("Last weekend I went to the park with my friends and we had lunch together.", ["Last weekend I…", "went / had / saw", "with my friends"]),
      'pt': ConvModel("No fim de semana passado eu fui ao parque com os meus amigos e a gente almoçou junto.", ["No fim de semana passado eu fui…", "…com os meus amigos.", "A gente almoçou junto."]),
      'fr': ConvModel("Le week-end dernier, je suis allé au parc avec mes amis et nous avons déjeuné ensemble.", ["Le week-end dernier, je suis allé(e)…", "avec mes amis", "nous avons déjeuné ensemble"]),
      'it': ConvModel("Lo scorso fine settimana sono andata al parco con i miei amici e abbiamo pranzato insieme.", ["Lo scorso fine settimana sono andato/a…", "…con i miei amici.", "Abbiamo pranzato insieme."]),
      'de': ConvModel("Am Wochenende bin ich mit Freunden ins Kino gegangen und am Sonntag habe ich lange geschlafen.", ["Am Wochenende bin ich… gegangen", "Ich habe… gemacht", "Das war schön / schön war es"]),
      'nl': ConvModel("Afgelopen weekend ben ik naar het park gegaan met mijn vrienden en hebben we samen geluncht.", ["Afgelopen weekend ben ik… gegaan", "…met mijn vrienden.", "We hebben samen geluncht."]),
    }),
    ConvTopic('interview', "💼", {
      'en': ConvModel("I'm interested in this job because I like working with people and I want to learn.", ["I'm interested because…", "I like…", "I want to…"]),
      'pt': ConvModel("Eu tenho interesse nesta vaga porque gosto de trabalhar com pessoas e quero aprender muito mais.", ["Eu tenho interesse nesta vaga porque…", "Gosto de trabalhar com pessoas.", "Quero aprender…"]),
      'fr': ConvModel("Ce poste m'intéresse parce que j'aime travailler avec les gens et parce que je veux apprendre.", ["Ce poste m'intéresse parce que…", "j'aime travailler avec…", "je veux apprendre"]),
      'it': ConvModel("Sono interessata a questo lavoro perché mi piace lavorare con le persone e ho voglia di imparare.", ["Sono interessato/a a questo lavoro perché…", "Mi piace lavorare con le persone.", "Ho voglia di imparare / Voglio crescere."]),
      'de': ConvModel("Ich möchte die Stelle, weil die Arbeit sehr interessant ist und weil ich gern im Team arbeite.", ["Ich möchte die Stelle, weil…", "…und weil ich gern… arbeite", "Die Arbeit ist interessant."]),
      'nl': ConvModel("Ik wil deze baan graag omdat ik graag met mensen werk en omdat ik veel wil leren.", ["Ik wil deze baan omdat…", "Ik werk graag met mensen.", "Ik wil veel leren."]),
    }),
    ConvTopic('directions', "🧭", {
      'en': ConvModel("Excuse me, how do I get to the train station? Is it far from here?", ["How do I get to…?", "Is it far?", "turn left / right"]),
      'pt': ConvModel("Com licença, como eu chego na estação de trem? É longe daqui?", ["Com licença, como eu chego na…?", "É longe daqui?", "Dá para ir a pé?"]),
      'fr': ConvModel("Excusez-moi, pour aller à la gare, s'il vous plaît ? Est-ce que c'est loin d'ici ?", ["Excusez-moi, pour aller à… ?", "…s'il vous plaît ?", "C'est loin d'ici ?"]),
      'it': ConvModel("Mi scusi, come arrivo alla stazione dei treni? È lontano da qui?", ["Mi scusi, come arrivo a…?", "Per andare alla stazione, per favore?", "È lontano da qui?"]),
      'de': ConvModel("Entschuldigung, wie komme ich zum Bahnhof? Ist das weit von hier?", ["Wie komme ich zum…?", "Ist das weit von hier?", "Entschuldigung,…"]),
      'nl': ConvModel("Pardon, hoe kom ik bij het treinstation? Is het ver hiervandaan?", ["Pardon, hoe kom ik bij…?", "Is het ver hiervandaan?", "Kan ik lopen?"]),
    }),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    // Idioma META del curso activo → la respuesta modelo se muestra en ese idioma.
    final lang = ref.watch(activeCourseTargetProvider).maybeWhen(data: (v) => v, orElse: () => 'en');
    // Nivel REAL de speaking para la pill del header (dato honesto, no inventado).
    final speaking = ref.watch(skillsProvider).maybeWhen(
        data: (s) {
          for (final sk in s) {
            if (sk.skill == 'speaking') return sk.cefrLevel;
          }
          return null;
        },
        orElse: () => null);
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 120),
        children: [
          _Header(speaking: speaking),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // OLA 1 (social async ABIERTO 18+): entradas ricas a Amigos y
                // Co-op — solo visibles con acceso social (adulto verificado).
                // Jerarquía: primero lo que SÍ puedes hacer HOY; el banner de
                // "en vivo · próximamente" (Ola 3) va al final, no arriba.
                const FriendsEntryCard(),
                const CoopEntryCard(),
                const SizedBox(height: 6),
                Text(l10n.convPracticeHeader,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.text)),
                const SizedBox(height: 4),
                Text(l10n.convPracticeSubtitle,
                    style: const TextStyle(
                        fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                const SizedBox(height: 12),
                for (final t in topics)
                  _TopicCard(
                    topic: t,
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => ConversarPracticeScreen(topic: t, lang: lang))),
                  ),
                const SizedBox(height: 8),
                // Visión (honesta) de la conversación EN VIVO/salas (Ola 3).
                _LiveBanner(l10n: l10n),
                const SizedBox(height: 14),
                const _InterestCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Header de COMUNIDAD (Conversar.dc): gradiente violeta full-bleed + kicker +
/// título + guacamayo (SVG) + pill "Tu Speaking: X" con el nivel REAL.
class _Header extends StatelessWidget {
  const _Header({this.speaking});
  final String? speaking;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final top = MediaQuery.paddingOf(context).top;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 18 + top * 0.2, 20, 22),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF7A6BF0), AppColors.primary, Color(0xFF5B4ECF)],
          stops: [0.0, 0.6, 1.0],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(26)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.convKicker,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.6,
                            color: Colors.white.withValues(alpha: 0.72))),
                    const SizedBox(height: 2),
                    Text(l10n.convTitle,
                        style: const TextStyle(
                            fontSize: 27, fontWeight: FontWeight.w900, color: Colors.white)),
                    const SizedBox(height: 4),
                    Text(l10n.convSubtitle,
                        style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            height: 1.3,
                            color: Colors.white.withValues(alpha: 0.82))),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const ParrotArt(size: 54),
            ],
          ),
          const SizedBox(height: 14),
          // Pill de nivel REAL de speaking (si aún no cargó, se omite — honesto).
          if (speaking != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.mic_rounded, size: 16, color: Color(0xFFFFC93C)),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(l10n.convSpeakingPill(speaking!),
                        style: const TextStyle(
                            fontSize: 12.5, fontWeight: FontWeight.w800, color: Colors.white)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Banner honesto de "en vivo · próximamente" (Fase 2). Estilo del mockup
/// (gradiente + punto live) SIN inventar un contador de gente en línea.
class _LiveBanner extends StatelessWidget {
  const _LiveBanner({required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF7A6BF0), AppColors.primary]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.28),
              offset: const Offset(0, 8),
              blurRadius: 20),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(width: 9, height: 9,
                decoration: const BoxDecoration(color: Color(0xFF3FE08A), shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(l10n.convLiveTitle,
                  style: const TextStyle(
                      fontSize: 15.5, fontWeight: FontWeight.w900, color: Colors.white)),
            ),
          ]),
          const SizedBox(height: 6),
          Text(l10n.convLiveBody,
              style: const TextStyle(
                  fontSize: 12.5, fontWeight: FontWeight.w700, color: Colors.white, height: 1.35)),
        ],
      ),
    );
  }
}

/// Respuesta modelo + frases clave de un topic, en UN idioma meta.
class ConvModel {
  const ConvModel(this.model, this.tips);
  final String model;
  final List<String> tips;
}

class ConvTopic {
  const ConvTopic(this.id, this.emoji, this.models);

  /// Slug estable (independiente del idioma) para i18n del título/escenario y
  /// como identificador al guardar el intento/evento (no varía por idioma).
  final String id;
  final String emoji;

  /// model+tips por idioma META del curso ('en'|'pt'|'fr'|'it'|'de'|'nl').
  final Map<String, ConvModel> models;

  /// El modelo en [lang]; si faltara ese idioma, cae a inglés (nunca rompe).
  ConvModel modelFor(String lang) => models[lang] ?? models['en']!;

  /// Título de la situación (CHROME → i18n de la APP es/en/pt).
  String title(AppLocalizations l) => switch (id) {
        'cafe' => l.convTopicCafeTitle,
        'intro' => l.convTopicIntroTitle,
        'airport' => l.convTopicAirportTitle,
        'weekend' => l.convTopicWeekendTitle,
        'interview' => l.convTopicInterviewTitle,
        _ => l.convTopicDirectionsTitle,
      };

  /// Escenario/instrucción de la situación (CHROME → i18n de la APP).
  String scenario(AppLocalizations l) => switch (id) {
        'cafe' => l.convTopicCafeScenario,
        'intro' => l.convTopicIntroScenario,
        'airport' => l.convTopicAirportScenario,
        'weekend' => l.convTopicWeekendScenario,
        'interview' => l.convTopicInterviewScenario,
        _ => l.convTopicDirectionsScenario,
      };
}

/// Color del icon-tile por situación (jerarquía visual del mockup: cada tarjeta
/// distinta, no rectángulos idénticos). (fondo suave, ícono/acento saturado).
const Map<String, (Color, Color)> _topicTint = {
  'cafe': (Color(0xFFFFE7CF), Color(0xFFE8850E)),
  'intro': (Color(0xFFE6ECFF), Color(0xFF5B6BF0)),
  'airport': (Color(0xFFDFF3FB), Color(0xFF1E9BC7)),
  'weekend': (Color(0xFFFFE7EC), Color(0xFFE03457)),
  'interview': (Color(0xFFEAF7EC), Color(0xFF2BA866)),
  'directions': (Color(0xFFF0EBFF), Color(0xFF7A6BF0)),
};

/// Tarjeta de situación con motion de presión (labio 3D que se hunde), fiel al
/// lenguaje del mockup. Reduce-motion-aware (sin hundido si se desactivan animaciones).
class _TopicCard extends StatefulWidget {
  const _TopicCard({required this.topic, required this.onTap});
  final ConvTopic topic;
  final VoidCallback onTap;
  @override
  State<_TopicCard> createState() => _TopicCardState();
}

class _TopicCardState extends State<_TopicCard> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final reduce = MediaQuery.disableAnimationsOf(context);
    final tint = _topicTint[widget.topic.id] ?? _topicTint['directions']!;
    final pressed = _down && !reduce;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _down = true),
        onTapUp: (_) => setState(() => _down = false),
        onTapCancel: () => setState(() => _down = false),
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 90),
          transform: Matrix4.translationValues(0, pressed ? 3 : 0, 0),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                  color: const Color(0xFFECEDF6),
                  offset: Offset(0, pressed ? 2 : 5),
                  blurRadius: 0),
              BoxShadow(
                  color: const Color(0x143C3778),
                  offset: const Offset(0, 10),
                  blurRadius: 22),
            ],
          ),
          child: Row(children: [
            Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: tint.$1, borderRadius: BorderRadius.circular(14)),
              child: Text(widget.topic.emoji, style: const TextStyle(fontSize: 23)),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(widget.topic.title(l10n),
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.text)),
                const SizedBox(height: 3),
                Text(widget.topic.scenario(l10n),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
              ]),
            ),
            const SizedBox(width: 8),
            Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: tint.$1, borderRadius: BorderRadius.circular(10)),
              child: Icon(Icons.chevron_right_rounded, size: 20, color: tint.$2),
            ),
          ]),
        ),
      ),
    );
  }
}

/// Captura de interés en la conversación EN VIVO (Fase 2 · waitlist).
class _InterestCard extends ConsumerStatefulWidget {
  const _InterestCard();
  @override
  ConsumerState<_InterestCard> createState() => _InterestCardState();
}

class _InterestCardState extends ConsumerState<_InterestCard> {
  final _topics = TextEditingController();
  bool? _wouldUse;
  bool _sent = false;

  @override
  void dispose() {
    _topics.dispose();
    super.dispose();
  }

  bool _sending = false;

  Future<void> _send() async {
    if (_sending) return;
    setState(() => _sending = true);
    // logConversarInterest devuelve false si la RPC falló (no relanza): así no
    // mostramos un falso "¡Gracias!" cuando en realidad no se registró.
    final ok = await ref
        .read(progressRepositoryProvider)
        .logConversarInterest(_wouldUse ?? false, _topics.text.trim());
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    if (ok) {
      setState(() => _sent = true);
    } else {
      setState(() => _sending = false);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.convInterestFailed)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.navActiveBg, borderRadius: BorderRadius.circular(18)),
      child: _sent
          ? Row(children: [
              const Icon(Icons.favorite_rounded, color: AppColors.primary),
              const SizedBox(width: 10),
              Expanded(child: Text(l10n.convInterestThanks,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.primary))),
            ])
          : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(l10n.convInterestTitle,
                  style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w900, color: AppColors.text)),
              const SizedBox(height: 10),
              Row(children: [
                _choice(l10n.convInterestYes, true),
                const SizedBox(width: 8),
                _choice(l10n.convInterestNo, false),
              ]),
              const SizedBox(height: 10),
              TextField(
                controller: _topics,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  hintText: l10n.convInterestHint,
                  filled: true, fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE5E7F1), width: 2)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary, width: 2)),
                ),
              ),
              const SizedBox(height: 10),
              // Botón 3D de la casa (labio + hundido).
              PrimaryButton(
                label: _sending ? l10n.convSending : l10n.convSend,
                expand: true,
                onPressed: (_wouldUse == null || _sending) ? null : _send,
              ),
            ]),
    );
  }

  Widget _choice(String label, bool value) {
    final sel = _wouldUse == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _wouldUse = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 11),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: sel ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: sel ? AppColors.primary : const Color(0xFFE5E7F1), width: 2)),
          child: Text(label,
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900,
                  color: sel ? Colors.white : AppColors.text)),
        ),
      ),
    );
  }
}

/// Práctica en solitario: escribe o habla, revela el modelo, autoevalúate, guarda.
class ConversarPracticeScreen extends ConsumerStatefulWidget {
  const ConversarPracticeScreen({super.key, required this.topic, this.lang = 'en'});
  final ConvTopic topic;
  final String lang; // idioma META del curso (en/pt/fr/it) para el modelo + reconocedor
  @override
  ConsumerState<ConversarPracticeScreen> createState() => _ConversarPracticeScreenState();
}

class _ConversarPracticeScreenState extends ConsumerState<ConversarPracticeScreen> {
  final SpeechRecognizer _rec = createSpeechRecognizer();
  final _text = TextEditingController();
  bool _voice = false;
  bool _sttReady = false;
  bool _sttAvailable = false;
  bool _listening = false;
  String? _micError; // código SpeechErrors → mensaje honesto (modo hablar)
  bool _revealed = false;
  int? _selfScore;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _initStt();
  }

  Future<void> _initStt() async {
    final ok = await _rec.init();
    if (mounted) {
      setState(() {
        _sttAvailable = ok;
        _sttReady = true;
      });
    }
  }

  @override
  void dispose() {
    _rec.dispose();
    _text.dispose();
    super.dispose();
  }

  String _sttBase = ''; // texto ya confirmado antes de la sesión de escucha actual

  void _listen() {
    if (!_sttAvailable || _listening) return;
    _sttBase = _text.text.trim(); // conserva lo escrito/confirmado previo
    setState(() {
      _listening = true;
      _micError = null;
    });
    HapticFeedback.selectionClick();
    _rec.listen(
      localeId: SpeechLang.stt, // idioma del curso activo (en/pt/fr/it), no inglés fijo
      listenFor: const Duration(seconds: 12),
      onResult: (transcript, isFinal) {
        if (!mounted) return;
        final clean = transcript.trim();
        final combined = _sttBase.isEmpty
            ? clean
            : (clean.isEmpty ? _sttBase : '$_sttBase $clean');
        setState(() {
          // Vista previa EN VIVO: tanto parciales como finales se muestran ya.
          _text.text = combined;
          _text.selection = TextSelection.collapsed(offset: _text.text.length);
          if (isFinal) {
            // El segmento se confirma y pasa a formar parte de la base.
            _sttBase = combined.trim();
            _listening = false;
          }
        });
      },
      onError: (e) {
        if (!mounted) return;
        setState(() {
          _listening = false;
          // Causa REAL visible (permiso/mic/soporte/red); el modo ESCRIBIR
          // sigue disponible — la sesión nunca se bloquea.
          if (micErrorIsFatal(e)) {
            _sttAvailable = false;
            _micError = e;
          } else if (e == SpeechErrors.network) {
            _micError = e;
          }
        });
      },
      onDone: () {
        if (mounted) setState(() => _listening = false);
      },
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final l10n = AppLocalizations.of(context);
    try {
      // `topic.id` = slug estable (no varía por idioma) → analítica coherente.
      await ref.read(progressRepositoryProvider).saveConversationAttempt(
            topic: widget.topic.id,
            mode: _voice ? 'voice' : 'text',
            content: _text.text.trim(),
            selfScore: _selfScore,
          );
      ref.read(progressRepositoryProvider).logEvent('conversar_attempt', props: {'topic': widget.topic.id});
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.convSaved)));
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.convSaveFailed)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = widget.topic;
    final m = t.modelFor(widget.lang); // respuesta modelo + frases clave en el idioma del curso
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background, elevation: 0, foregroundColor: AppColors.text,
        title: Text(t.title(l10n), style: const TextStyle(fontWeight: FontWeight.w900)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            // Escenario.
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.navActiveBg, borderRadius: BorderRadius.circular(18)),
              child: Row(children: [
                Text(t.emoji, style: const TextStyle(fontSize: 26)),
                const SizedBox(width: 12),
                Expanded(child: Text(t.scenario(l10n),
                    style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: AppColors.text, height: 1.3))),
              ]),
            ),
            const SizedBox(height: 16),
            // Toggle escribir / hablar.
            Row(children: [
              _modeBtn('✍️ ${l10n.convModeWrite}', false),
              const SizedBox(width: 10),
              _modeBtn('🎙️ ${l10n.convModeSpeak}', true),
            ]),
            const SizedBox(height: 12),
            if (_voice) ...[
              Center(child: _micButton()),
              const SizedBox(height: 10),
            ],
            TextField(
              controller: _text,
              maxLines: 4,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                hintText: _voice ? l10n.convHintVoice : l10n.convHintWrite,
                filled: true, fillColor: Colors.white,
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFE5E7F1), width: 2)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2)),
              ),
            ),
            const SizedBox(height: 14),
            if (!_revealed)
              SizedBox(
                width: double.infinity, height: 50,
                child: OutlinedButton.icon(
                  onPressed: () => setState(() => _revealed = true),
                  icon: const Icon(Icons.lightbulb_outline_rounded),
                  label: Text(l10n.convSeeModel, style: const TextStyle(fontWeight: FontWeight.w900)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                ),
              )
            else ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(18),
                  boxShadow: const [BoxShadow(color: Color(0xFFECEDF6), offset: Offset(0, 5), blurRadius: 0)]),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(l10n.convModelAnswer,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 0.5, color: AppColors.textMuted)),
                  const SizedBox(height: 6),
                  Text('“${m.model}”',
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.primary, height: 1.35)),
                  const SizedBox(height: 12),
                  Text(l10n.convKeyPhrases,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 0.5, color: AppColors.textMuted)),
                  const SizedBox(height: 6),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    for (final tip in m.tips)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(color: AppColors.navActiveBg, borderRadius: BorderRadius.circular(10)),
                        child: Text(tip, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.primary))),
                  ]),
                ]),
              ),
              const SizedBox(height: 16),
              // Autoevaluación (rúbrica determinista).
              Text(l10n.convSelfEval,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.text)),
              const SizedBox(height: 8),
              Row(children: [
                for (var i = 1; i <= 5; i++) _scoreChip(i),
              ]),
              const SizedBox(height: 16),
              // Botón 3D de la casa (labio + hundido).
              PrimaryButton(
                label: _saving ? l10n.convSaving : l10n.convSaveFinish,
                expand: true,
                onPressed: _saving ? null : _save,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _modeBtn(String label, bool voice) {
    final sel = _voice == voice;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _voice = voice),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: sel ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: sel ? AppColors.primary : const Color(0xFFE5E7F1), width: 2)),
          child: Text(label,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900,
                  color: sel ? Colors.white : AppColors.text)),
        ),
      ),
    );
  }

  Widget _micButton() {
    final l10n = AppLocalizations.of(context);
    if (!_sttReady) {
      return Text(l10n.convMicPreparing,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textMuted));
    }
    if (!_sttAvailable) {
      // La CAUSA real (sin soporte / permiso bloqueado / sin mic) — y el modo
      // ESCRIBIR sigue disponible justo abajo.
      return Text(micMessageFor(l10n, _micError ?? _rec.unavailableReason),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textMuted));
    }
    return Column(mainAxisSize: MainAxisSize.min, children: [
      GestureDetector(
        onTap: _listen,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          decoration: BoxDecoration(
            color: _listening ? AppColors.coral : AppColors.primary,
            borderRadius: BorderRadius.circular(16)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(_listening ? Icons.mic_rounded : Icons.mic_none_rounded, color: Colors.white),
            const SizedBox(width: 8),
            Text(_listening ? l10n.convListening : l10n.convSpeakBtn,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
          ]),
        ),
      ),
      if (_micError == SpeechErrors.network) ...[
        const SizedBox(height: 8),
        Text(micMessageFor(l10n, _micError),
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.coral)),
      ],
    ]);
  }

  Widget _scoreChip(int i) {
    final sel = _selfScore == i;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => _selfScore = i),
        child: Container(
          width: 44, height: 44, alignment: Alignment.center,
          decoration: BoxDecoration(
            color: sel ? AppColors.primary : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: sel ? AppColors.primary : const Color(0xFFE5E7F1), width: 2)),
          child: Text('$i',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900,
                  color: sel ? Colors.white : AppColors.text)),
        ),
      ),
    );
  }
}
