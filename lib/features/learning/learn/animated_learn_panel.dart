import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_toast.dart';
import '../../../shared/widgets/glow_card.dart';
import 'animated_speaker_button.dart';
import 'learn_content_data.dart';
import 'learn_narration.dart';

/// Animated diagrams for the Learn tab (no extra packages).
class AnimatedLearnPanel extends StatefulWidget {
  const AnimatedLearnPanel({super.key, required this.unitId});

  final String unitId;

  @override
  State<AnimatedLearnPanel> createState() => _AnimatedLearnPanelState();
}

class _AnimatedLearnPanelState extends State<AnimatedLearnPanel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4200),
    )..repeat();
  }

  @override
  void dispose() {
    LearnNarration.instance.stop();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _listen() async {
    try {
      final ok = await LearnNarration.instance.toggleLesson(
        title: _content.title,
        summary: _content.summary,
        bullets: _content.bullets,
        steps: _content.diagramSteps,
      );
      if (!ok && mounted && !LearnNarration.instance.isSpeaking) {
        AppToast.info(
          context,
          'Voice unavailable: ${LearnNarration.instance.status}',
        );
      }
    } catch (_) {
      if (mounted) {
        AppToast.info(
          context,
          'Voice unavailable. Turn up media volume or enable Google TTS in Settings.',
        );
      }
    }
  }

  void _replay() {
    _controller
      ..reset()
      ..forward()
      ..repeat();
  }

  LearnConceptContent get _content => learnContentFor(widget.unitId);

  @override
  Widget build(BuildContext context) {
    final t = _controller;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GlowCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(_content.icon, color: AppTheme.primary, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _content.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  AnimatedSpeakerButton(onPressed: _listen),
                  ValueListenableBuilder<bool>(
                    valueListenable: LearnNarration.instance.speaking,
                    builder: (context, isSpeaking, _) {
                      if (!isSpeaking) return const SizedBox.shrink();
                      return IconButton(
                        tooltip: 'Stop voice',
                        onPressed: () => LearnNarration.instance.stop(),
                        icon: Icon(
                          Icons.stop_circle_outlined,
                          size: 22,
                          color: AppTheme.accent,
                        ),
                      );
                    },
                  ),
                  IconButton(
                    tooltip: 'Replay animation',
                    onPressed: _replay,
                    icon: const Icon(Icons.replay_rounded, size: 22),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 220,
                width: double.infinity,
                child: AnimatedBuilder(
                  animation: t,
                  builder: (context, _) => _DiagramCanvas(
                    unitId: widget.unitId,
                    progress: t.value,
                    steps: _content.diagramSteps,
                  ),
                ),
              ),
              if (_content.diagramSteps.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: _content.diagramSteps.asMap().entries.map((e) {
                    final active =
                        (t.value * _content.diagramSteps.length).floor() ==
                            e.key;
                    return Chip(
                      label: Text(
                        '${e.key + 1}. ${e.value}',
                        style: TextStyle(
                          fontSize: 11,
                          color: active ? AppTheme.accent : AppTheme.textSecondary,
                        ),
                      ),
                      backgroundColor: active
                          ? AppTheme.primary.withValues(alpha: 0.2)
                          : AppTheme.background,
                      side: BorderSide(
                        color: active
                            ? AppTheme.primary
                            : AppTheme.textSecondary.withValues(alpha: 0.3),
                      ),
                      visualDensity: VisualDensity.compact,
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
        GlowCard(
          padding: const EdgeInsets.all(14),
          child: Text(
            _content.summary,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
          ),
        ),
        const SizedBox(height: 16),
        ..._content.bullets.map(
          (b) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('▸ ', style: TextStyle(color: AppTheme.primary)),
                Expanded(
                  child: Text(
                    b,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.45,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Activity = hands-on · Quiz = topic questions for this unit.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.accent,
              ),
        ),
      ],
    );
  }
}

class _DiagramCanvas extends StatelessWidget {
  const _DiagramCanvas({
    required this.unitId,
    required this.progress,
    required this.steps,
  });

  final String unitId;
  final double progress;
  final List<String> steps;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _UnitDiagramPainter(unitId: unitId, progress: progress),
      child: const SizedBox.expand(),
    );
  }
}

class _UnitDiagramPainter extends CustomPainter {
  _UnitDiagramPainter({required this.unitId, required this.progress});

  final String unitId;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    switch (unitId) {
      case 'react-components':
        _paintComponents(canvas, size);
      case 'react-props':
        _paintProps(canvas, size);
      case 'react-state':
        _paintState(canvas, size);
      case 'react-hooks':
        _paintHooks(canvas, size);
      case 'react-useeffect':
        _paintEffect(canvas, size);
      case 'react-context':
        _paintContext(canvas, size);
      case 'react-redux':
        _paintRedux(canvas, size);
      case 'css-box-model':
        _paintBoxModel(canvas, size);
      case 'css-flexbox':
        _paintFlexRow(canvas, size);
      case 'css-grid':
        _paintGrid(canvas, size);
      case 'css-selectors':
        _paintSelectors(canvas, size);
      case 'html-semantic':
        _paintHtmlTree(canvas, size);
      case 'js-dom':
        _paintDomTree(canvas, size);
      case 'html-structure':
        _paintHtmlStructure(canvas, size);
      case 'html-forms':
        _paintHtmlForms(canvas, size);
      case 'css-colors':
        _paintColors(canvas, size);
      case 'js-events':
        _paintEvents(canvas, size);
      case 'js-variables':
        _paintVariables(canvas, size);
      default:
        _paintGeneric(canvas, size, unitId);
    }
  }

  void _paintBoxModel(Canvas canvas, Size size) {
    var inset = 8.0;
    final colors = [AppTheme.primary, AppTheme.secondary, AppTheme.accent];
    for (var i = 0; i < 3; i++) {
      final phase = ((progress * 3) - i).clamp(0.0, 1.0);
      final r = Rect.fromLTWH(inset, inset, size.width - inset * 2, size.height - inset * 2);
      canvas.drawRRect(
        RRect.fromRectAndRadius(r, const Radius.circular(6)),
        Paint()
          ..color = colors[i].withValues(alpha: 0.15 + 0.25 * phase)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      inset += 14 * phase;
    }
    _drawLabel(canvas, size, 'margin → border → padding', size.height - 12, AppTheme.textSecondary);
  }

  void _paintFlexRow(Canvas canvas, Size size) {
    final y = size.height * 0.45;
    for (var i = 0; i < 3; i++) {
      final phase = ((progress * 3) - i).clamp(0.0, 1.0);
      final x = 40 + i * (size.width - 120) / 2;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(x, y), width: 40 * phase, height: 36 * phase),
          const Radius.circular(6),
        ),
        Paint()..color = AppTheme.primary.withValues(alpha: 0.5 + phase * 0.5),
      );
    }
    _drawLabel(canvas, size, 'flex row →', size.height - 12, AppTheme.primary);
  }

  void _paintGrid(Canvas canvas, Size size) {
    final cell = (size.width - 60) / 3;
    for (var r = 0; r < 2; r++) {
      for (var c = 0; c < 3; c++) {
        final i = r * 3 + c;
        final phase = ((progress * 6) - i).clamp(0.0, 1.0);
        if (phase <= 0) continue;
        final rect = Rect.fromLTWH(30 + c * cell, 40 + r * 50, cell - 8, 42);
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(4)),
          Paint()..color = AppTheme.secondary.withValues(alpha: 0.3 + phase * 0.5),
        );
      }
    }
  }

  void _paintSelectors(Canvas canvas, Size size) {
    _drawBox(canvas, Rect.fromLTWH(40, 60, size.width - 80, 50), '.class', AppTheme.primary);
    final phase = (progress * 2) % 1.0;
    canvas.drawCircle(
      Offset(50 + 20 * phase, 85),
      8,
      Paint()..color = AppTheme.accent,
    );
  }

  void _paintHtmlTree(Canvas canvas, Size size) {
    _drawBox(canvas, Rect.fromLTWH(size.width * 0.35, 20, size.width * 0.3, 28), 'body', AppTheme.primary);
    for (var i = 0; i < 2; i++) {
      final phase = ((progress * 2) - i).clamp(0.0, 1.0);
      _drawBox(
        canvas,
        Rect.fromLTWH(50 + i * 80.0, 70, 70, 28),
        i == 0 ? 'header' : 'main',
        AppTheme.secondary.withValues(alpha: phase),
      );
    }
  }

  void _paintHtmlStructure(Canvas canvas, Size size) {
    final layers = ['DOCTYPE', 'head', 'body'];
    for (var i = 0; i < layers.length; i++) {
      final phase = ((progress * 3) - i).clamp(0.0, 1.0);
      _drawBox(
        canvas,
        Rect.fromLTWH(50, 30 + i * 52.0, size.width - 100, 40),
        layers[i],
        AppTheme.primary.withValues(alpha: 0.4 + phase * 0.6),
      );
    }
  }

  void _paintHtmlForms(Canvas canvas, Size size) {
    _drawBox(canvas, Rect.fromLTWH(40, 50, 100, 32), 'label', AppTheme.primary);
    _drawBox(canvas, Rect.fromLTWH(160, 50, size.width - 200, 32), 'input', AppTheme.secondary);
    final phase = (progress * 2) % 1.0;
    _drawBox(
      canvas,
      Rect.fromLTWH(size.width * 0.35, 120, size.width * 0.3, 36),
      'submit',
      AppTheme.accent.withValues(alpha: 0.5 + phase * 0.5),
    );
  }

  void _paintColors(Canvas canvas, Size size) {
    final swatches = [AppTheme.primary, AppTheme.secondary, AppTheme.accent];
    for (var i = 0; i < swatches.length; i++) {
      final phase = ((progress * 3) - i).clamp(0.0, 1.0);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(40 + i * 70.0, 70, 50 * phase, 50 * phase),
          const Radius.circular(8),
        ),
        Paint()..color = swatches[i].withValues(alpha: 0.6 + phase * 0.4),
      );
    }
    _drawLabel(canvas, size, '#hex  rem  em', size.height - 14, AppTheme.textSecondary);
  }

  void _paintEvents(Canvas canvas, Size size) {
    _drawBox(canvas, Rect.fromLTWH(40, 40, 80, 36), 'click', AppTheme.accent);
    final phase = (progress * 2) % 1.0;
    canvas.drawLine(
      Offset(120, 58),
      Offset(120 + 80 * phase, 58),
      Paint()
        ..color = AppTheme.primary
        ..strokeWidth = 2,
    );
    _drawBox(
      canvas,
      Rect.fromLTWH(200, 40, size.width - 240, 36),
      'handler()',
      AppTheme.primary.withValues(alpha: 0.5 + phase * 0.5),
    );
  }

  void _paintVariables(Canvas canvas, Size size) {
    final keys = ['const', 'let', 'typeof'];
    for (var i = 0; i < keys.length; i++) {
      final phase = ((progress * 3) - i).clamp(0.0, 1.0);
      _drawBox(
        canvas,
        Rect.fromLTWH(40 + i * 75.0, 80, 65, 40),
        keys[i],
        AppTheme.secondary.withValues(alpha: 0.4 + phase * 0.6),
      );
    }
  }

  void _paintDomTree(Canvas canvas, Size size) {
    _drawBox(canvas, Rect.fromLTWH(size.width * 0.3, 25, size.width * 0.4, 32), 'document', AppTheme.accent);
    final phase = (progress * 3).floor() % 3;
    _drawBox(
      canvas,
      Rect.fromLTWH(60, 90, size.width - 120, 36),
      ['querySelector', 'textContent', 'classList'][phase],
      AppTheme.primary,
    );
  }

  void _paintComponents(Canvas canvas, Size size) {
    final labels = ['Header', 'Content', 'Footer'];
    final boxH = 36.0;
    final startY = 24.0;
    for (var i = 0; i < labels.length; i++) {
      final phase = ((progress * 3) - i).clamp(0.0, 1.0);
      if (phase <= 0) continue;
      final y = startY + i * (boxH + 10);
      _drawBox(
        canvas,
        Rect.fromLTWH(40, y, size.width - 80, boxH),
        labels[i],
        AppTheme.primary.withValues(alpha: phase),
        scale: 0.85 + 0.15 * phase,
      );
    }
    _drawLabel(canvas, size, '<Page>', 8, AppTheme.secondary);
  }

  void _paintProps(Canvas canvas, Size size) {
    final parent = Rect.fromLTWH(size.width * 0.15, 20, size.width * 0.7, 44);
    final child = Rect.fromLTWH(size.width * 0.2, 120, size.width * 0.6, 56);
    _drawBox(canvas, parent, 'Parent', AppTheme.primary);
    _drawBox(canvas, child, 'Child', AppTheme.secondary);

    final path = Path()
      ..moveTo(parent.center.dx, parent.bottom)
      ..quadraticBezierTo(
        size.width * 0.5,
        90,
        child.center.dx,
        child.top,
      );
    final paint = Paint()
      ..shader = null
      ..color = AppTheme.accent.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawPath(path, paint);

    final dotT = (progress * 2) % 1.0;
    final metric = path.computeMetrics().first;
    final pos = metric.getTangentForOffset(metric.length * dotT)?.position;
    if (pos != null) {
      canvas.drawCircle(
        pos,
        6,
        Paint()..color = AppTheme.accent,
      );
    }
    _drawLabel(canvas, size, 'props flow ↓', size.height - 18, AppTheme.textSecondary);
  }

  void _paintState(Canvas canvas, Size size) {
    final box = Rect.fromLTWH(size.width * 0.25, 50, size.width * 0.5, 70);
    final count = (progress * 5).floor() % 6;
    _drawBox(canvas, box, 'count: $count', AppTheme.primary);
    final pulse = (math.sin(progress * math.pi * 4) + 1) / 2;
    canvas.drawCircle(
      box.center,
      48 + pulse * 8,
      Paint()
        ..color = AppTheme.accent.withValues(alpha: 0.12 + pulse * 0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    _drawLabel(canvas, size, 'setState → re-render', size.height - 16, AppTheme.accent);
  }

  void _paintHooks(Canvas canvas, Size size) {
    final hooks = ['useState', 'useEffect', 'custom'];
    final colors = [AppTheme.primary, AppTheme.secondary, AppTheme.accent];
    final comp = Rect.fromLTWH(size.width * 0.2, 100, size.width * 0.6, 50);
    _drawBox(canvas, comp, 'Function Component', AppTheme.surfaceElevated);
    for (var i = 0; i < hooks.length; i++) {
      final phase = ((progress * 3.5) - i * 0.35).clamp(0.0, 1.0);
      final x = 50.0 + i * (size.width - 100) / 2;
      canvas.drawCircle(
        Offset(x, 48),
        14 * phase,
        Paint()..color = colors[i].withValues(alpha: phase),
      );
      if (phase > 0.3) {
        _drawText(
          canvas,
          hooks[i],
          Offset(x - 28, 68),
          colors[i].withValues(alpha: phase),
          11,
        );
        canvas.drawLine(
          Offset(x, 62),
          Offset(comp.left + comp.width * (i + 1) / 4, comp.top),
          Paint()
            ..color = colors[i].withValues(alpha: 0.6 * phase)
            ..strokeWidth = 2,
        );
      }
    }
  }

  void _paintEffect(Canvas canvas, Size size) {
    final phases = ['Mount', 'Update', 'Cleanup'];
    final w = (size.width - 60) / 3;
    for (var i = 0; i < 3; i++) {
      final active = ((progress * 3) % 3).floor() == i;
      final r = Rect.fromLTWH(30 + i * w, 70, w - 12, 50);
      _drawBox(
        canvas,
        r,
        phases[i],
        active ? AppTheme.accent : AppTheme.surfaceElevated,
      );
      if (i < 2) {
        canvas.drawLine(
          Offset(r.right + 2, r.center.dy),
          Offset(r.right + 14, r.center.dy),
          Paint()
            ..color = AppTheme.primary.withValues(alpha: 0.4)
            ..strokeWidth = 2,
        );
      }
    }
    _drawLabel(canvas, size, 'useEffect lifecycle', 16, AppTheme.primary);
  }

  void _paintContext(Canvas canvas, Size size) {
    final levels = [
      ('Provider', 0.0),
      ('Layout', 0.35),
      ('Page', 0.65),
      ('Button', 0.9),
    ];
    for (final (label, threshold) in levels) {
      final lit = progress >= threshold;
      final y = 30 + threshold * 130;
      _drawBox(
        canvas,
        Rect.fromLTWH(50 + threshold * 40, y, size.width - 100 - threshold * 40, 32),
        label,
        lit ? AppTheme.primary : AppTheme.surfaceElevated,
      );
      if (lit && threshold > 0) {
        canvas.drawLine(
          Offset(size.width * 0.45, y - 8),
          Offset(size.width * 0.45, y - 28),
          Paint()
            ..color = AppTheme.accent.withValues(alpha: 0.7)
            ..strokeWidth = 2,
        );
      }
    }
  }

  void _paintRedux(Canvas canvas, Size size) {
    final nodes = ['UI', 'Action', 'Reducer', 'Store'];
    final step = (progress * 4).floor() % 4;
    final w = (size.width - 40) / 4;
    for (var i = 0; i < 4; i++) {
      final r = Rect.fromLTWH(20 + i * w, 80, w - 8, 44);
      _drawBox(
        canvas,
        r,
        nodes[i],
        i == step ? AppTheme.accent : AppTheme.primary.withValues(alpha: 0.5),
      );
      if (i < 3) {
        canvas.drawLine(
          Offset(r.right, r.center.dy),
          Offset(r.right + 10, r.center.dy),
          Paint()
            ..color = AppTheme.textSecondary.withValues(alpha: 0.5)
            ..strokeWidth = 2,
        );
      }
    }
  }

  void _paintGeneric(Canvas canvas, Size size, String unitId) {
    final label = unitId.split('-').first.toUpperCase();
    final angle = progress * math.pi * 2;
    final c = Offset(size.width / 2, size.height / 2);
    for (var i = 0; i < 3; i++) {
      final a = angle + i * 2 * math.pi / 3;
      final p = c + Offset(math.cos(a) * 50, math.sin(a) * 40);
      canvas.drawCircle(
        p,
        18,
        Paint()..color = AppTheme.primary.withValues(alpha: 0.4 + i * 0.2),
      );
    }
    _drawLabel(canvas, size, label, size.height / 2 - 8, AppTheme.textPrimary);
  }

  void _drawBox(
    Canvas canvas,
    Rect rect,
    String label,
    Color color, {
    double scale = 1,
  }) {
    final center = rect.center;
    final scaled = Rect.fromCenter(
      center: center,
      width: rect.width * scale,
      height: rect.height * scale,
    );
    final rrect = RRect.fromRectAndRadius(scaled, const Radius.circular(10));
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = color.withValues(alpha: 0.25)
        ..style = PaintingStyle.fill,
    );
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    _drawText(
      canvas,
      label,
      Offset(scaled.left + 10, scaled.center.dy - 7),
      AppTheme.textPrimary,
      12,
    );
  }

  void _drawLabel(Canvas canvas, Size size, String text, double y, Color color) {
    _drawText(canvas, text, Offset(size.width * 0.5 - text.length * 3.2, y), color, 12);
  }

  void _drawText(Canvas canvas, String text, Offset offset, Color color, double size) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: size,
          fontFamily: 'monospace',
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _UnitDiagramPainter old) =>
      old.progress != progress || old.unitId != unitId;
}
