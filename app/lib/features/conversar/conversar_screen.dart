import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/speech/speech_lang.dart';
import '../../core/speech/speech_recognizer.dart';
import '../../core/theme/app_colors.dart';
import '../../data/providers.dart';

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
    ConvTopic("Pedir un café", "☕", "Estás en una cafetería. Pide un café y algo de comer, y pregunta el precio.", {
      'en': ConvModel("Hi! Can I have a coffee and a piece of cake, please? How much is it?", ["Can I have…?", "How much is it?", "please / thank you"]),
      'pt': ConvModel("Oi, bom dia! Você pode me ver um café e um pedaço de bolo, por favor? Quanto fica?", ["Você pode me ver um…?", "Um café e um pedaço de bolo, por favor.", "Quanto fica?"]),
      'fr': ConvModel("Bonjour, je voudrais un café et une part de gâteau, s'il vous plaît. Combien ça coûte ?", ["Bonjour, je voudrais…", "…s'il vous plaît.", "Combien ça coûte ?"]),
      'it': ConvModel("Buongiorno! Vorrei un caffè e una fetta di torta, per favore. Quanto costa?", ["Vorrei un caffè…", "…e qualcosa da mangiare, per favore.", "Quanto costa?"]),
      'de': ConvModel("Guten Tag! Ich hätte gern einen Kaffee und ein Stück Kuchen, bitte. Was kostet das?", ["Ich hätte gern…", "…und etwas zu essen, bitte.", "Was kostet das?"]),
      'nl': ConvModel("Hallo! Mag ik een koffie en een stuk taart, alstublieft? Hoeveel kost dat?", ["Mag ik een koffie…?", "…en iets te eten, alstublieft.", "Hoeveel kost dat?"]),
    }),
    ConvTopic("Presentarte", "👋", "Conoces a alguien nuevo. Preséntate: nombre, de dónde eres y qué haces.", {
      'en': ConvModel("Hi, I'm Ana. Nice to meet you! I'm from Peru and I work as a teacher.", ["I'm…", "Nice to meet you", "I'm from… / I work as…"]),
      'pt': ConvModel("Oi, muito prazer! Eu sou a Ana, sou do Peru e trabalho como professora.", ["Muito prazer!", "Eu sou o/a…, sou do/da…", "Trabalho como…"]),
      'fr': ConvModel("Bonjour, je m'appelle Ana, enchantée ! Je viens du Pérou et je suis professeure.", ["Je m'appelle…", "Enchanté(e) !", "Je viens de… et je travaille comme…"]),
      'it': ConvModel("Ciao, mi chiamo Ana, piacere! Vengo dal Perù e faccio l'insegnante.", ["Mi chiamo…, piacere!", "Vengo da…", "Faccio l'insegnante / Lavoro come…"]),
      'de': ConvModel("Hallo! Ich heiße Ana. Ich komme aus Spanien und ich bin Lehrerin. Und du?", ["Ich heiße…", "Ich komme aus…", "Ich bin (von Beruf)…"]),
      'nl': ConvModel("Hoi, ik heet Ana, aangenaam! Ik kom uit Peru en ik werk als lerares.", ["Ik heet…, aangenaam!", "Ik kom uit…", "Ik werk als…"]),
    }),
    ConvTopic("En el aeropuerto", "✈️", "Estás en el aeropuerto. Pregunta por tu puerta y la hora del vuelo.", {
      'en': ConvModel("Excuse me, where is gate 12? What time does the flight to Madrid leave?", ["Excuse me…", "Where is…?", "What time does… leave?"]),
      'pt': ConvModel("Com licença, onde fica o portão 12? E que horas sai o voo para Madri?", ["Com licença, onde fica o portão…?", "Que horas sai o voo para…?", "O voo está no horário?"]),
      'fr': ConvModel("Excusez-moi, où est la porte 12, s'il vous plaît ? À quelle heure part le vol pour Madrid ?", ["Excusez-moi, où est… ?", "À quelle heure part le vol pour… ?", "la porte 12"]),
      'it': ConvModel("Mi scusi, dov'è l'uscita 12? A che ora parte il volo per Madrid?", ["Mi scusi, dov'è l'uscita…?", "A che ora parte il volo per…?", "Da quale gate parte?"]),
      'de': ConvModel("Entschuldigung, von welchem Gate geht mein Flug? Und wann fliegt die Maschine ab?", ["Von welchem Gate geht…?", "Wann fliegt der Flug ab?", "Entschuldigung,…"]),
      'nl': ConvModel("Pardon, waar is gate 12? En hoe laat vertrekt de vlucht naar Madrid?", ["Pardon, waar is…?", "Hoe laat vertrekt de vlucht naar…?", "gate 12"]),
    }),
    ConvTopic("Tu fin de semana", "🌤️", "Cuenta qué hiciste el fin de semana pasado (pasado simple).", {
      'en': ConvModel("Last weekend I went to the park with my friends and we had lunch together.", ["Last weekend I…", "went / had / saw", "with my friends"]),
      'pt': ConvModel("No fim de semana passado eu fui ao parque com os meus amigos e a gente almoçou junto.", ["No fim de semana passado eu fui…", "…com os meus amigos.", "A gente almoçou junto."]),
      'fr': ConvModel("Le week-end dernier, je suis allé au parc avec mes amis et nous avons déjeuné ensemble.", ["Le week-end dernier, je suis allé(e)…", "avec mes amis", "nous avons déjeuné ensemble"]),
      'it': ConvModel("Lo scorso fine settimana sono andata al parco con i miei amici e abbiamo pranzato insieme.", ["Lo scorso fine settimana sono andato/a…", "…con i miei amici.", "Abbiamo pranzato insieme."]),
      'de': ConvModel("Am Wochenende bin ich mit Freunden ins Kino gegangen und am Sonntag habe ich lange geschlafen.", ["Am Wochenende bin ich… gegangen", "Ich habe… gemacht", "Das war schön / schön war es"]),
      'nl': ConvModel("Afgelopen weekend ben ik naar het park gegaan met mijn vrienden en hebben we samen geluncht.", ["Afgelopen weekend ben ik… gegaan", "…met mijn vrienden.", "We hebben samen geluncht."]),
    }),
    ConvTopic("Una entrevista breve", "💼", "Te preguntan por qué quieres el trabajo. Responde con 2 razones.", {
      'en': ConvModel("I'm interested in this job because I like working with people and I want to learn.", ["I'm interested because…", "I like…", "I want to…"]),
      'pt': ConvModel("Eu tenho interesse nesta vaga porque gosto de trabalhar com pessoas e quero aprender muito mais.", ["Eu tenho interesse nesta vaga porque…", "Gosto de trabalhar com pessoas.", "Quero aprender…"]),
      'fr': ConvModel("Ce poste m'intéresse parce que j'aime travailler avec les gens et parce que je veux apprendre.", ["Ce poste m'intéresse parce que…", "j'aime travailler avec…", "je veux apprendre"]),
      'it': ConvModel("Sono interessata a questo lavoro perché mi piace lavorare con le persone e ho voglia di imparare.", ["Sono interessato/a a questo lavoro perché…", "Mi piace lavorare con le persone.", "Ho voglia di imparare / Voglio crescere."]),
      'de': ConvModel("Ich möchte die Stelle, weil die Arbeit sehr interessant ist und weil ich gern im Team arbeite.", ["Ich möchte die Stelle, weil…", "…und weil ich gern… arbeite", "Die Arbeit ist interessant."]),
      'nl': ConvModel("Ik wil deze baan graag omdat ik graag met mensen werk en omdat ik veel wil leren.", ["Ik wil deze baan omdat…", "Ik werk graag met mensen.", "Ik wil veel leren."]),
    }),
    ConvTopic("Pedir indicaciones", "🧭", "Pregunta cómo llegar a la estación de tren y si está lejos.", {
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
    // Idioma META del curso activo → la respuesta modelo se muestra en ese idioma.
    final lang = ref.watch(activeCourseTargetProvider).maybeWhen(data: (v) => v, orElse: () => 'en');
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
        children: [
          const Text('Conversar',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppColors.text)),
          const SizedBox(height: 2),
          const Text('Practica conversaciones reales. A tu ritmo, sin presión.',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
          const SizedBox(height: 16),
          // Visión (honesta) de la conversación en vivo.
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                  colors: [Color(0xFF7A6BF0), AppColors.primary]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('🎙️  Conversación en vivo — próximamente',
                    style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w900, color: Colors.white)),
                SizedBox(height: 6),
                Text('Pronto podrás conversar con feedback en tiempo real. Lo lanzaremos con '
                    'moderación y verificación de edad para que sea seguro. Mientras, practica abajo.',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Colors.white, height: 1.35)),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Text('Practica hablando o escribiendo',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.text)),
          const SizedBox(height: 4),
          const Text('Elige una situación, responde, y compárate con una respuesta modelo.',
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
          const SizedBox(height: 12),
          for (final t in topics)
            _TopicCard(
              topic: t,
              onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => ConversarPracticeScreen(topic: t, lang: lang))),
            ),
          const SizedBox(height: 8),
          const _InterestCard(),
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
  const ConvTopic(this.title, this.emoji, this.scenario, this.models);
  final String title;
  final String emoji;
  final String scenario;

  /// model+tips por idioma META del curso ('en'|'pt'|'fr'|'it').
  final Map<String, ConvModel> models;

  /// El modelo en [lang]; si faltara ese idioma, cae a inglés (nunca rompe).
  ConvModel modelFor(String lang) => models[lang] ?? models['en']!;
}

class _TopicCard extends StatelessWidget {
  const _TopicCard({required this.topic, required this.onTap});
  final ConvTopic topic;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(18),
            boxShadow: const [BoxShadow(color: Color(0xFFECEDF6), offset: Offset(0, 5), blurRadius: 0)]),
          child: Row(children: [
            Container(
              width: 46, height: 46, alignment: Alignment.center,
              decoration: BoxDecoration(color: AppColors.navActiveBg, borderRadius: BorderRadius.circular(13)),
              child: Text(topic.emoji, style: const TextStyle(fontSize: 22))),
            const SizedBox(width: 13),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(topic.title,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.text)),
                const SizedBox(height: 2),
                Text(topic.scenario, maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
              ]),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.primary),
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
    if (ok) {
      setState(() => _sent = true);
    } else {
      setState(() => _sending = false);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('No se pudo enviar. Inténtalo de nuevo.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.navActiveBg, borderRadius: BorderRadius.circular(18)),
      child: _sent
          ? const Row(children: [
              Icon(Icons.favorite_rounded, color: AppColors.primary),
              SizedBox(width: 10),
              Expanded(child: Text('¡Gracias! Te avisaremos cuando la conversación en vivo esté lista.',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.primary))),
            ])
          : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('¿Usarías la conversación en vivo?',
                  style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w900, color: AppColors.text)),
              const SizedBox(height: 10),
              Row(children: [
                _choice('Sí, me encantaría', true),
                const SizedBox(width: 8),
                _choice('No por ahora', false),
              ]),
              const SizedBox(height: 10),
              TextField(
                controller: _topics,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  hintText: '¿Sobre qué temas? (opcional)',
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
              SizedBox(
                width: double.infinity, height: 46,
                child: ElevatedButton(
                  onPressed: (_wouldUse == null || _sending) ? null : _send,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary, foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13))),
                  child: Text(_sending ? 'ENVIANDO…' : 'ENVIAR',
                      style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.4)),
                ),
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
    setState(() => _listening = true);
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
      onError: (_) {
        if (mounted) setState(() => _listening = false);
      },
      onDone: () {
        if (mounted) setState(() => _listening = false);
      },
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ref.read(progressRepositoryProvider).saveConversationAttempt(
            topic: widget.topic.title,
            mode: _voice ? 'voice' : 'text',
            content: _text.text.trim(),
            selfScore: _selfScore,
          );
      ref.read(progressRepositoryProvider).logEvent('conversar_attempt', props: {'topic': widget.topic.title});
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('¡Guardado! Cada práctica suma. 🦜')));
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo guardar. Inténtalo de nuevo.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.topic;
    final m = t.modelFor(widget.lang); // respuesta modelo + frases clave en el idioma del curso
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background, elevation: 0, foregroundColor: AppColors.text,
        title: Text(t.title, style: const TextStyle(fontWeight: FontWeight.w900)),
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
                Expanded(child: Text(t.scenario,
                    style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: AppColors.text, height: 1.3))),
              ]),
            ),
            const SizedBox(height: 16),
            // Toggle escribir / hablar.
            Row(children: [
              _modeBtn('✍️ Escribir', false),
              const SizedBox(width: 10),
              _modeBtn('🎙️ Hablar', true),
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
                hintText: _voice ? 'Tu transcripción aparecerá aquí (o edítala)' : 'Escribe tu respuesta…',
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
                  label: const Text('VER RESPUESTA MODELO', style: TextStyle(fontWeight: FontWeight.w900)),
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
                  const Text('Respuesta modelo',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 0.5, color: AppColors.textMuted)),
                  const SizedBox(height: 6),
                  Text('“${m.model}”',
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.primary, height: 1.35)),
                  const SizedBox(height: 12),
                  const Text('Frases clave',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 0.5, color: AppColors.textMuted)),
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
              const Text('¿Qué tan cerca estuviste del modelo?',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.text)),
              const SizedBox(height: 8),
              Row(children: [
                for (var i = 1; i <= 5; i++) _scoreChip(i),
              ]),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity, height: 52,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary, foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                  child: Text(_saving ? 'GUARDANDO…' : 'GUARDAR Y TERMINAR',
                      style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.4)),
                ),
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
    if (!_sttReady) {
      return const Text('Preparando micrófono…',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textMuted));
    }
    if (!_sttAvailable) {
      return const Text('Tu navegador no permite el micrófono. Escribe tu respuesta 🙂',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textMuted));
    }
    return GestureDetector(
      onTap: _listen,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        decoration: BoxDecoration(
          color: _listening ? AppColors.coral : AppColors.primary,
          borderRadius: BorderRadius.circular(16)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(_listening ? Icons.mic_rounded : Icons.mic_none_rounded, color: Colors.white),
          const SizedBox(width: 8),
          Text(_listening ? 'Escuchando…' : 'Hablar',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
        ]),
      ),
    );
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
