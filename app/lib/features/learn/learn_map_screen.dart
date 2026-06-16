import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/lesson_model.dart';
import '../../data/models/unit_model.dart';
import '../../data/providers.dart';
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

    return Stack(
      children: [
        Positioned.fill(
          child: unitsAsync.when(
            loading: () => const _MapState(
              icon: Icons.terrain_rounded,
              message: 'Cargando tu mapa…',
              showSpinner: true,
            ),
            error: (e, _) => _MapState(
              icon: Icons.cloud_off_rounded,
              message: 'No se pudo cargar el mapa.\n$e',
              onRetry: () => ref.invalidate(mapUnitsProvider),
            ),
            data: (units) {
              if (units.isEmpty) {
                return const _MapState(
                  icon: Icons.map_outlined,
                  message: 'Aún no hay contenido sembrado.',
                );
              }
              return _MapBody(unit: units.first);
            },
          ),
        ),
        // Top bar flotante (siempre visible sobre el mapa).
        const Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(bottom: false, child: LearnTopBar()),
        ),
      ],
    );
  }
}

/// Cuerpo del mapa: posiciona los nodos a lo largo de un sendero serpenteante,
/// de abajo (nodo disponible) hacia arriba (la cima / certificado).
class _MapBody extends StatefulWidget {
  const _MapBody({required this.unit});
  final UnitModel unit;

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

  @override
  void initState() {
    super.initState();
    // Arrancar abajo del todo: el nodo actual/disponible.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_controller.hasClients) {
        _controller.jumpTo(_controller.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Estado local (paso C): primera lección disponible, el resto bloqueadas.
  /// El progreso real se conecta en el paso E.
  int get _availableIndex {
    final lessons = widget.unit.lessons;
    final i = lessons.indexWhere((l) => l.type == LessonType.lesson);
    return i >= 0 ? i : 0;
  }

  double _laneX(double width, int i) {
    // Carriles alternados -> serpenteo. El nodo de abajo (i=0) a la izquierda.
    return i.isEven ? width * 0.30 : width * 0.70;
  }

  void _onTapNode(LessonModel lesson, NodeState state) {
    final msg = state == NodeState.available
        ? 'La lección "${lesson.title}" llega en el paso D 🛠️'
        : 'Bloqueada · completa la lección anterior';
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating));
  }

  @override
  Widget build(BuildContext context) {
    final lessons = widget.unit.lessons;
    final n = lessons.length;
    final availableIndex = _availableIndex;

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

        // Nodos + etiquetas.
        for (var i = 0; i < n; i++) {
          final lesson = lessons[i];
          final c = centers[i];
          final state = i == availableIndex ? NodeState.available : NodeState.locked;
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
              onTap: () => _onTapNode(lesson, state),
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
              child: const ParrotMascot(message: '¡A la cima! 💪'),
            ));
          }
        }

        // Banner de la unidad actual (abajo).
        children.add(Positioned(
          left: 0,
          right: 0,
          bottom: 96,
          child: Center(child: _UnitBanner(unit: widget.unit)),
        ));

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
      child: const Text(
        'EMPIEZA',
        style: TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w900,
          fontSize: 12,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _SummitCertificate extends StatelessWidget {
  const _SummitCertificate();

  @override
  Widget build(BuildContext context) {
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
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'TU META · CERTIFICADO',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.4,
                  color: Color(0xFFC98A12),
                ),
              ),
              SizedBox(height: 3),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.workspace_premium_rounded,
                      color: AppColors.gold, size: 22),
                  SizedBox(width: 6),
                  Text(
                    'B2',
                    style: TextStyle(
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
        const Text(
          '⛰ LA CIMA',
          style: TextStyle(
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
  const _UnitBanner({required this.unit});
  final UnitModel unit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.22),
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
              gradient: const LinearGradient(
                colors: [AppColors.primaryLight, AppColors.primary],
              ),
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(Icons.waving_hand_rounded,
                color: Colors.white, size: 17),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'UNIDAD ${unit.orderIndex} · ${unit.cefrLevel}',
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                  color: AppColors.primaryLight,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                unit.title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: AppColors.text,
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
              TextButton(onPressed: onRetry, child: const Text('Reintentar')),
            ],
          ],
        ),
      ),
    );
  }
}
