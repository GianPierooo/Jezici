import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/plan/estimation.dart';
import '../../core/theme/app_colors.dart';
import '../../core/ui/jz_transitions.dart';
import '../../l10n/app_localizations.dart';
import '../../data/models/lesson_model.dart';
import '../../data/models/unit_model.dart';
import '../../data/providers.dart';
import '../checkpoint/checkpoint_intro_screen.dart';
import '../lesson/lesson_preview_screen.dart';
import 'mission_screen.dart';
import 'widgets/checkpoint_portal.dart';
import 'widgets/cloud_cover_painter.dart';
import '../../core/ui/tour_keys.dart';
import 'widgets/learn_top_bar.dart';
import 'widgets/map_node.dart';
import 'widgets/parrot_mascot.dart';
import 'widgets/scenery_painter.dart';
import 'widgets/trail_painter.dart';

/// Pantalla "Aprender" = el MAPA (home). Renderiza el viaje ascendente
/// serpenteante leyendo units/lessons de Supabase.
class LearnMapScreen extends ConsumerWidget {
  const LearnMapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unitsAsync = ref.watch(mapUnitsProvider);
    final l10n = AppLocalizations.of(context);

    return Stack(
      children: [
        Positioned.fill(
          child: unitsAsync.when(
            loading: () => _MapState(
              icon: Icons.terrain_rounded,
              message: l10n.mapLoading,
              showSpinner: true,
            ),
            error: (e, _) => _MapState(
              icon: Icons.cloud_off_rounded,
              message: l10n.mapLoadError(e.toString()),
              onRetry: () => ref.invalidate(mapUnitsProvider),
            ),
            data: (units) {
              if (units.isEmpty) {
                return _MapState(
                  icon: Icons.map_outlined,
                  message: l10n.mapEmptyState,
                );
              }
              // Estados de nodo REALES desde user_lesson_progress (paso E).
              final progress = ref.watch(lessonProgressProvider).value ?? const {};
              // Nivel de ENTRADA del plan (del placement): las unidades por DEBAJO
              // se pintan doradas ("te saltaste estos niveles → conquistados"),
              // aunque en BD sean 'completed' (no se toca el estado: 'golden' en BD
              // dispararía el logro "impecable" sin haberlo ganado).
              final entryLevel = ref.watch(userPlanProvider).value?.currentLevel ?? 'A1';
              return _MapBody(units: units, progress: progress, entryLevel: entryLevel);
            },
          ),
        ),
        // Top bar flotante + barra de progreso del plan persistente (GA9·C).
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            bottom: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                KeyedSubtree(key: TourKeys.topBar, child: const LearnTopBar()),
                const PlanProgressStrip(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Una entrada del mapa: una lección con la unidad a la que pertenece.
class _Entry {
  const _Entry({required this.lesson, required this.unit, required this.firstOfUnit});
  final LessonModel lesson;
  final UnitModel unit;
  final bool firstOfUnit; // primer nodo de su unidad → ancla del banner de región
}

/// Cuerpo del mapa: posiciona los nodos de TODAS las unidades a lo largo de un
/// sendero serpenteante continuo, de abajo (Unidad 1) hacia arriba (la cima).
/// Las unidades superiores quedan bloqueadas hasta aprobar el checkpoint previo.
class _MapBody extends StatefulWidget {
  const _MapBody({required this.units, required this.progress, required this.entryLevel});
  final List<UnitModel> units;
  final Map<String, String> progress; // lesson_id -> status (real)
  final String entryLevel; // nivel de entrada del plan (placement) → dorado por debajo

  @override
  State<_MapBody> createState() => _MapBodyState();
}

class _MapBodyState extends State<_MapBody> {
  final ScrollController _controller = ScrollController();

  // Layout
  static const double _topPad = 250; // zona de la cima
  static const double _bottomPad = 220; // banner de unidad + nav
  static const double _gap = 152; // separación vertical entre nodos
  static const double _maxWidth = 430;

  late List<_Entry> _entries;

  // ── VENTANA de widgets (perf 2ª pasada) ────────────────────────────────────
  // La 1ª pasada culled los PAINTERS (−93% ms/paint) pero el Stack seguía
  // construyendo ~500 Positioned y ~185 RepaintBoundaries (capas del compositor)
  // para TODO el curso → 19,5 ms/frame de layout+composición al hacer scroll.
  // Ahora solo se CONSTRUYEN los nodos de la banda visible (scroll ± margen);
  // el listener hace setState únicamente cuando la ventana cambia de índices.
  static const double _winMargin = 700;
  int _winLo = 0;
  int _winHi = 1 << 30;
  bool _farFromTarget = false; // botón "ir a donde me quedé"
  double _lastViewH = 0;

  @override
  void initState() {
    super.initState();
    _entries = _flatten();
    _controller.addListener(_onScroll);
    // Arrancar centrado en el nodo actual/disponible (sube al avanzar).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_controller.hasClients) _controller.jumpTo(_targetScroll());
    });
  }

  /// Ventana [lo, hi] de índices de nodo cuya y cae en scroll ± margen.
  (int, int) _windowFor(double offset, double viewH) {
    final n = _entries.length;
    final contentH = _topPad + _bottomPad + (n - 1) * _gap;
    final yTop = offset - _winMargin;
    final yBot = offset + viewH + _winMargin;
    // y_i = contentH - _bottomPad - i*_gap  →  i = (contentH - _bottomPad - y)/_gap
    var lo = ((contentH - _bottomPad - yBot) / _gap).floor() - 1;
    var hi = ((contentH - _bottomPad - yTop) / _gap).ceil() + 1;
    lo = lo.clamp(0, n - 1);
    hi = hi.clamp(0, n - 1);
    return (lo, hi);
  }

  void _onScroll() {
    if (!_controller.hasClients || _lastViewH <= 0) return;
    final (lo, hi) = _windowFor(_controller.offset, _lastViewH);
    final far = (_controller.offset - _targetScroll()).abs() >
        _controller.position.viewportDimension * 1.2;
    if (lo != _winLo || hi != _winHi || far != _farFromTarget) {
      setState(() {
        _winLo = lo;
        _winHi = hi;
        _farFromTarget = far;
      });
    }
  }

  /// Aplana las lecciones de todas las unidades en un solo sendero ascendente.
  List<_Entry> _flatten() {
    final list = <_Entry>[];
    for (final u in widget.units) {
      for (var j = 0; j < u.lessons.length; j++) {
        list.add(_Entry(lesson: u.lessons[j], unit: u, firstOfUnit: j == 0));
      }
    }
    return list;
  }

  /// Offset para dejar el nodo disponible en la zona inferior-media del viewport.
  double _targetScroll() {
    final n = _entries.length;
    final contentHeight = _topPad + _bottomPad + (n - 1) * _gap;
    final max = _controller.position.maxScrollExtent;
    var availIndex = -1;
    for (var i = 0; i < n; i++) {
      if (_stateFor(_entries[i].lesson, i) == NodeState.available) {
        availIndex = i;
        break;
      }
    }
    if (availIndex < 0) return max; // nada disponible (curso completo)
    final y = contentHeight - _bottomPad - availIndex * _gap;
    final viewport = _controller.position.viewportDimension;
    return (y - viewport * 0.58).clamp(0.0, max);
  }

  @override
  void didUpdateWidget(covariant _MapBody old) {
    super.didUpdateWidget(old);
    _entries = _flatten();
    // El progreso llega async; al cambiar el nodo disponible, recentrar.
    if (!_mapEquals(old.progress, widget.progress)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_controller.hasClients) _controller.jumpTo(_targetScroll());
      });
    }
  }

  bool _mapEquals(Map<String, String> a, Map<String, String> b) {
    if (a.length != b.length) return false;
    for (final e in a.entries) {
      if (b[e.key] != e.value) return false;
    }
    return true;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Fallback local si aún no hay progreso (p. ej. auth no lista): primera
  /// lección (no-misión) del curso.
  int get _fallbackAvailableIndex {
    // GA10: el primer nodo (la misión) debe verse disponible mientras carga el
    // progreso — no saltar a la primera lección dejando la misión bloqueada.
    final i = _entries.indexWhere((e) =>
        e.lesson.type == LessonType.mission || e.lesson.type == LessonType.lesson);
    return i >= 0 ? i : 0;
  }

  /// ¿La unidad de este nodo está por DEBAJO del nivel de entrada del plan?
  /// (el placement la marcó 'completed'; visualmente la pintamos dorada).
  bool _belowEntry(int index) {
    if (index < 0 || index >= _entries.length) return false;
    return CefrTable.rank(_entries[index].unit.cefrLevel) < CefrTable.rank(widget.entryLevel);
  }

  /// Estado del nodo: del progreso REAL (user_lesson_progress); si no hay
  /// progreso cargado, heurística local (primera lección disponible).
  NodeState _stateFor(LessonModel lesson, int index) {
    final status = widget.progress[lesson.id];
    if (status != null) {
      switch (status) {
        case 'completed':
          // Lo que quedó por debajo de tu nivel de entrada (placement) se pinta
          // DORADO (conquistado), no verde-completado. Sigue accesible/rejugable.
          return _belowEntry(index) ? NodeState.mastered : NodeState.completed;
        case 'golden':
          return NodeState.mastered;
        case 'available':
        case 'in_progress':
          return NodeState.available;
        default:
          return NodeState.locked;
      }
    }
    if (widget.progress.isEmpty) {
      return index == _fallbackAvailableIndex ? NodeState.available : NodeState.locked;
    }
    return NodeState.locked;
  }

  double _laneX(double width, int i) {
    // Carriles alternados -> serpenteo. El nodo de abajo (i=0) a la izquierda.
    return i.isEven ? width * 0.30 : width * 0.70;
  }

  /// Avance de la unidad (0..1): lecciones dominadas/completadas / total. Alimenta
  /// el ANILLO del nodo disponible (Aprender.dc). No cambia ninguna lógica.
  double _unitProgress(String unitId) {
    var done = 0, total = 0;
    for (var k = 0; k < _entries.length; k++) {
      if (_entries[k].unit.id != unitId) continue;
      total++;
      final s = _stateFor(_entries[k].lesson, k);
      if (s == NodeState.completed || s == NodeState.mastered) done++;
    }
    return total == 0 ? 0 : done / total;
  }

  void _onTapNode(_Entry entry, NodeState state) {
    final lesson = entry.lesson;
    // Bloqueada → aviso. Disponible/completada → checkpoint o lección.
    if (state != NodeState.locked) {
      Navigator.of(context).push(jzRoute(switch (lesson.type) {
        LessonType.checkpoint => CheckpointIntroScreen(lesson: lesson, unitTitle: entry.unit.title),
        LessonType.mission => MissionScreen(lesson: lesson),
        _ => LessonPreviewScreen(lesson: lesson),
      }));
      return;
    }
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(entry.firstOfUnit
            ? l10n.mapNodeLockedNextUnit
            : l10n.mapNodeLockedNextLesson),
        behavior: SnackBarBehavior.floating,
      ));
  }

  /// Índice más alto NO bloqueado (frontera de avance). −1 si nada desbloqueado.
  int get _frontierIndex {
    var f = -1;
    for (var i = 0; i < _entries.length; i++) {
      if (_stateFor(_entries[i].lesson, i) != NodeState.locked) f = i;
    }
    return f;
  }

  @override
  Widget build(BuildContext context) {
    final entries = _entries;
    final n = entries.length;
    final l10n = AppLocalizations.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        // En pantalla ancha el fondo (cielo + escenografía) es full-bleed y la
        // COLUMNA de nodos queda centrada en un ancho tipo-móvil → sin franjas
        // vacías. En móvil layoutWidth≈colWidth → dx0≈0 → layout idéntico.
        final layoutWidth = constraints.maxWidth;
        final colWidth = math.min(constraints.maxWidth, _maxWidth);
        final dx0 = (layoutWidth - colWidth) / 2;
        final contentHeight = _topPad + _bottomPad + (n - 1) * _gap;

        // Ventana de nodos a CONSTRUIR (perf): scroll actual ± margen.
        _lastViewH = constraints.maxHeight;
        final offsetNow = _controller.hasClients ? _controller.offset : 0.0;
        final (winLo, winHi) = _windowFor(offsetNow, constraints.maxHeight);
        _winLo = winLo;
        _winHi = winHi;

        // NUBES de progreso (fog-of-war): lo que está por encima de la frontera
        // (+2 nodos de "teaser" bloqueados visibles) queda cubierto — y NI SE
        // CONSTRUYE (perf). La cima (certificado) queda visible como meta.
        const teaser = 2;
        final frontier = _frontierIndex;
        final visMax = frontier < 0 ? (n - 1) : (frontier + teaser).clamp(0, n - 1);
        final cloudTopY = _topPad * 0.55;
        final cloudBottomY =
            contentHeight - _bottomPad - visMax * _gap - _gap * 0.85;
        final cloudsActive = visMax < n - 1 && cloudBottomY > cloudTopY + 220;

        // Centro (x,y) de cada nodo, de abajo (i=0) hacia arriba (columna centrada).
        final centers = <Offset>[
          for (var i = 0; i < n; i++)
            Offset(dx0 + _laneX(colWidth, i), contentHeight - _bottomPad - i * _gap),
        ];

        // Sendero: nodos + un punto hacia la cima para que suba al certificado.
        final trailPoints = <Offset>[
          ...centers,
          Offset(dx0 + colWidth * 0.5, _topPad * 0.55),
        ];

        final children = <Widget>[
          // Fondo: degradado vertical SUAVE del mockup (8 paradas, pie→cima). Es
          // el que da la transición entre regiones (ciudad-morado abajo → cielo/mar
          // azul-cian en medio → cima crema arriba); la escenografía se integra
          // encima. Nada de bandas de color plano.
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Color(0xFFC8B7F2),
                    Color(0xFFBBA8EE),
                    Color(0xFFB9C2F2),
                    Color(0xFFBFD4F5),
                    Color(0xFFC8E2F3),
                    Color(0xFFD8EEFA),
                    Color(0xFFEAF4FF),
                    Color(0xFFFFF7E2),
                  ],
                  stops: [0.0, 0.08, 0.26, 0.44, 0.60, 0.74, 0.86, 1.0],
                ),
              ),
            ),
          ),
          // Escenografía + sendero — con VIEWPORT CULLING (solo pintan el tramo
          // visible, driven por el scroll → no repintan la escena de 27.000px
          // cada frame). isComplex+willChange dan mejores hints al compositor.
          Positioned.fill(
            child: RepaintBoundary(
              child: CustomPaint(
                painter: SceneryPainter(scroll: _controller, viewH: constraints.maxHeight),
                isComplex: true,
                willChange: true,
              ),
            ),
          ),
          Positioned.fill(
            child: RepaintBoundary(
              child: CustomPaint(
                painter: TrailPainter(trailPoints,
                    scroll: _controller,
                    viewH: constraints.maxHeight,
                    // El sendero tapado por nubes ni se construye ni se pinta.
                    topCutY: cloudsActive ? cloudBottomY - 20 : null),
                isComplex: true,
                willChange: true,
              ),
            ),
          ),
          // Certificado de la cima.
          Positioned(
            top: _topPad * 0.18,
            left: 0,
            right: 0,
            child: const Center(child: _SummitCertificate()),
          ),
        ];

        // Banner de región por unidad (debajo del primer nodo de cada unidad).
        // Una unidad está "bloqueada" solo si TODOS sus nodos están bloqueados
        // (la misión inicial de la U1 está locked, pero la U1 no lo está).
        for (var i = 0; i < n; i++) {
          // Fuera de la ventana visible o tapado por nubes → NO se construye.
          if (i < winLo || i > winHi || (cloudsActive && i > visMax)) continue;
          if (!entries[i].firstOfUnit) continue;
          final unit = entries[i].unit;
          final unitLocked = [
            for (var k = 0; k < n; k++)
              if (entries[k].unit.id == unit.id) _stateFor(entries[k].lesson, k)
          ].every((s) => s == NodeState.locked);
          children.add(Positioned(
            left: 0,
            right: 0,
            top: centers[i].dy + _gap * 0.46,
            child: Center(child: _UnitBanner(unit: unit, locked: unitLocked)),
          ));
        }

        // Nodos + etiquetas — SOLO los de la ventana visible y no tapados por
        // nubes (el resto ni se construye: era el grueso del coste de frame).
        for (var i = 0; i < n; i++) {
          if (i < winLo || i > winHi || (cloudsActive && i > visMax)) continue;
          final entry = entries[i];
          final lesson = entry.lesson;
          final c = centers[i];
          final state = _stateFor(lesson, i);
          final isCheckpoint = lesson.type == LessonType.checkpoint;
          final size = isCheckpoint ? 88.0 : 72.0;

          // Nodo: el CHECKPOINT es un PORTAL de examen (Aprender.dc); el resto,
          // nodo circular con anillo de progreso cuando está disponible.
          if (isCheckpoint) {
            const portalW = 108.0;
            const portalBox = portalW * 1.5;
            children.add(Positioned(
              left: c.dx - portalBox / 2,
              top: c.dy - portalBox / 2,
              // RepaintBoundary: el halo pulsante del portal NO invalida la
              // escenografía/sendero (aísla la animación en su propia capa).
              child: RepaintBoundary(
                child: CheckpointPortal(
                  state: state,
                  width: portalW,
                  onTap: () => _onTapNode(entry, state),
                ),
              ),
            ));
            // Pill "EXAMEN · UNIDAD N" en el HUECO bajo el portal (no encima del
            // arco). El portal (art ~100px, centrado en c.dy) llega a ~c.dy+50;
            // el siguiente nodo empieza ~c.dy+98 → la pill se centra en medio.
            children.add(Positioned(
              left: c.dx - 90,
              top: c.dy + 62,
              width: 180,
              child: Center(child: _ExamPill(unitOrder: entry.unit.orderIndex)),
            ));
          } else {
            final box = size * 1.5;
            children.add(Positioned(
              left: c.dx - box / 2,
              top: c.dy - box / 2,
              // RepaintBoundary: el pulso del nodo disponible se aísla → no
              // repinta la escena gigante cada frame.
              child: RepaintBoundary(
                child: MapNode(
                  type: lesson.type,
                  state: state,
                  size: size,
                  progress: state == NodeState.available ? _unitProgress(entry.unit.id) : 0,
                  onTap: () => _onTapNode(entry, state),
                ),
              ),
            ));
            // Etiqueta debajo del nodo.
            children.add(Positioned(
              left: c.dx - 90,
              top: c.dy + size / 2 + 8,
              width: 180,
              child: _NodeLabel(title: lesson.title, available: state == NodeState.available),
            ));
          }

          // Globo "EMPIEZA" sobre el nodo disponible.
          if (state == NodeState.available) {
            children.add(Positioned(
              left: c.dx - 60,
              top: c.dy - size / 2 - 44,
              width: 120,
              child: const Center(child: _StartBubble()),
            ));
            // Mascota junto al nodo disponible. RepaintBoundary: su bob (bucle
            // continuo) se aísla → NO invalida la escenografía cada frame (era
            // la causa #1 del lag continuo, incluso estando quieto).
            children.add(Positioned(
              left: c.dx + size * 0.5,
              top: c.dy - size * 0.95,
              child: RepaintBoundary(child: ParrotMascot(message: l10n.mapMascotPeak)),
            ));
          }
        }

        // NUBES por ENCIMA de todo lo cubierto. El borde inferior se ANIMA al
        // despejarse (la frontera sube al desbloquear) — reduce-motion salta.
        if (cloudsActive) {
          final reduce = MediaQuery.disableAnimationsOf(context);
          children.add(Positioned.fill(
            child: IgnorePointer(
              child: RepaintBoundary(
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: cloudBottomY, end: cloudBottomY),
                  duration: reduce ? Duration.zero : const Duration(milliseconds: 950),
                  curve: Curves.easeInOutCubic,
                  builder: (context, animatedBottom, _) => CustomPaint(
                    painter: CloudCoverPainter(
                      topY: cloudTopY,
                      bottomY: animatedBottom,
                      scroll: _controller,
                      viewH: constraints.maxHeight,
                    ),
                    isComplex: true,
                    willChange: true,
                  ),
                ),
              ),
            ),
          ));
        }

        return Stack(children: [
          SingleChildScrollView(
            controller: _controller,
            child: SizedBox(
              width: layoutWidth,
              height: contentHeight,
              child: Stack(clipBehavior: Clip.none, children: children),
            ),
          ),
          // Botón flotante "ir a donde me quedé" — solo cuando estás lejos del
          // nodo actual. No tapa la barra inferior ni el contenido.
          Positioned(
            right: 16,
            bottom: 108,
            child: IgnorePointer(
              ignoring: !_farFromTarget,
              child: AnimatedOpacity(
                opacity: _farFromTarget ? 1 : 0,
                duration: const Duration(milliseconds: 220),
                child: _JumpToCurrentButton(
                  goesUp: _controller.hasClients &&
                      _targetScroll() < _controller.offset,
                  onTap: () {
                    final target = _targetScroll();
                    if (MediaQuery.disableAnimationsOf(context)) {
                      _controller.jumpTo(target);
                    } else {
                      _controller.animateTo(target,
                          duration: const Duration(milliseconds: 650),
                          curve: Curves.easeInOutCubic);
                    }
                  },
                ),
              ),
            ),
          ),
        ]);
      },
    );
  }
}

/// Botón flotante discreto "ir a donde me quedé": pill blanca con labio + flecha
/// según la dirección del nodo actual. Aparece solo lejos del objetivo.
class _JumpToCurrentButton extends StatelessWidget {
  const _JumpToCurrentButton({required this.goesUp, required this.onTap});
  final bool goesUp;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(color: Color(0xFFD8D3F5), offset: Offset(0, 4), blurRadius: 0),
            BoxShadow(color: Color(0x33283266), offset: Offset(0, 10), blurRadius: 18),
          ],
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(goesUp ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
              size: 18, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(l10n.mapJumpToCurrent,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.primary)),
        ]),
      ),
    );
  }
}

class _NodeLabel extends StatelessWidget {
  const _NodeLabel({required this.title, required this.available});
  final String title;
  final bool available;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: available ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(11),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF28326E).withValues(alpha: 0.12),
              offset: const Offset(0, 4),
              blurRadius: 10,
            ),
          ],
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: available ? Colors.white : AppColors.textMuted,
            fontWeight: FontWeight.w900,
            fontSize: 11.5,
          ),
        ),
      ),
    );
  }
}

/// Rótulo del portal de examen: pill oscura "EXAMEN · UNIDAD N" (Aprender.dc).
class _ExamPill extends StatelessWidget {
  const _ExamPill({required this.unitOrder});
  final int unitOrder;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.text,
        borderRadius: BorderRadius.circular(11),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.25), offset: const Offset(0, 4), blurRadius: 10),
        ],
      ),
      child: Text(
        AppLocalizations.of(context).mapExamUnit(unitOrder),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 10,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _StartBubble extends StatelessWidget {
  const _StartBubble();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.30),
            offset: const Offset(0, 6),
            blurRadius: 12,
          ),
        ],
      ),
      child: Text(
        AppLocalizations.of(context).mapStartBubble,
        style: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w900,
          fontSize: 12,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _SummitCertificate extends ConsumerWidget {
  const _SummitCertificate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goal = ref.watch(userPlanProvider).value?.goalLevel ?? 'B2';
    final l10n = AppLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Color(0xFFFFF6E2)],
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: AppColors.gold.withValues(alpha: 0.45),
                offset: const Offset(0, 10),
                blurRadius: 22,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.mapSummitCertLabel,
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.4,
                  color: Color(0xFFC98A12),
                ),
              ),
              const SizedBox(height: 3),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.workspace_premium_rounded,
                      color: AppColors.gold, size: 22),
                  const SizedBox(width: 6),
                  Text(
                    goal,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: AppColors.text,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          l10n.mapSummitPeak,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

class _UnitBanner extends StatelessWidget {
  const _UnitBanner({required this.unit, this.locked = false});
  final UnitModel unit;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    final accent = locked ? AppColors.lockedDark : AppColors.primary;
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.22),
            offset: const Offset(0, 8),
            blurRadius: 20,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: locked
                  ? const LinearGradient(colors: [AppColors.locked, AppColors.lockedDark])
                  : const LinearGradient(colors: [AppColors.primaryLight, AppColors.primary]),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(locked ? Icons.lock_rounded : Icons.waving_hand_rounded,
                color: Colors.white, size: 17),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                locked
                    ? l10n.mapUnitBannerLocked(unit.orderIndex, unit.cefrLevel)
                    : l10n.mapUnitBanner(unit.orderIndex, unit.cefrLevel),
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                  color: locked ? AppColors.lockedDark : AppColors.primaryLight,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                unit.title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: locked ? AppColors.textMuted : AppColors.text,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MapState extends StatelessWidget {
  const _MapState({
    required this.icon,
    required this.message,
    this.onRetry,
    this.showSpinner = false,
  });

  final IconData icon;
  final String message;
  final VoidCallback? onRetry;
  final bool showSpinner;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showSpinner)
              const CircularProgressIndicator(color: AppColors.primary)
            else
              Icon(icon, size: 48, color: AppColors.textMuted),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              TextButton(
                onPressed: onRetry,
                child: Text(AppLocalizations.of(context).commonRetry),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
