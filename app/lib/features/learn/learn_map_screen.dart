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
        const Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            bottom: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [LearnTopBar(), PlanProgressStrip()],
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

  @override
  void initState() {
    super.initState();
    _entries = _flatten();
    // Arrancar centrado en el nodo actual/disponible (sube al avanzar).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_controller.hasClients) _controller.jumpTo(_targetScroll());
    });
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

  @override
  Widget build(BuildContext context) {
    final entries = _entries;
    final n = entries.length;
    final l10n = AppLocalizations.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = math.min(constraints.maxWidth, _maxWidth);
        final contentHeight = _topPad + _bottomPad + (n - 1) * _gap;

        // Centro (x,y) de cada nodo, de abajo (i=0) hacia arriba.
        final centers = <Offset>[
          for (var i = 0; i < n; i++)
            Offset(_laneX(width, i), contentHeight - _bottomPad - i * _gap),
        ];

        // Sendero: nodos + un punto hacia la cima para que suba al certificado.
        final trailPoints = <Offset>[
          ...centers,
          Offset(width * 0.5, _topPad * 0.55),
        ];

        final children = <Widget>[
          // Fondo: gradiente cielo→cima.
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Color(0xFFC8B7F2),
                    Color(0xFFBFD4F5),
                    Color(0xFFD8EEFA),
                    Color(0xFFFFF7E2),
                  ],
                  stops: [0.0, 0.4, 0.74, 1.0],
                ),
              ),
            ),
          ),
          // Escenografía + sendero.
          Positioned.fill(child: CustomPaint(painter: SceneryPainter())),
          Positioned.fill(child: CustomPaint(painter: TrailPainter(trailPoints))),
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

        // Nodos + etiquetas.
        for (var i = 0; i < n; i++) {
          final entry = entries[i];
          final lesson = entry.lesson;
          final c = centers[i];
          final state = _stateFor(lesson, i);
          final size = lesson.type == LessonType.checkpoint ? 88.0 : 72.0;
          final box = size * 1.5;

          // Nodo.
          children.add(Positioned(
            left: c.dx - box / 2,
            top: c.dy - box / 2,
            child: MapNode(
              type: lesson.type,
              state: state,
              size: size,
              onTap: () => _onTapNode(entry, state),
            ),
          ));

          // Etiqueta debajo del nodo.
          children.add(Positioned(
            left: c.dx - 90,
            top: c.dy + size / 2 + 8,
            width: 180,
            child: _NodeLabel(title: lesson.title, available: state == NodeState.available),
          ));

          // Globo "EMPIEZA" sobre el nodo disponible.
          if (state == NodeState.available) {
            children.add(Positioned(
              left: c.dx - 60,
              top: c.dy - size / 2 - 44,
              width: 120,
              child: const Center(child: _StartBubble()),
            ));
            // Mascota junto al nodo disponible.
            children.add(Positioned(
              left: c.dx + size * 0.5,
              top: c.dy - size * 0.95,
              child: ParrotMascot(message: l10n.mapMascotPeak),
            ));
          }
        }

        return SingleChildScrollView(
          controller: _controller,
          child: Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: width,
              height: contentHeight,
              child: Stack(clipBehavior: Clip.none, children: children),
            ),
          ),
        );
      },
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
