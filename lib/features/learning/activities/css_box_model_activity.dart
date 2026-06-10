import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_toast.dart';
import 'activity_shell.dart';

/// Stack margin → border → padding → content by drag-and-drop.
class CssBoxModelActivity extends StatefulWidget {
  const CssBoxModelActivity({super.key});

  @override
  State<CssBoxModelActivity> createState() => _CssBoxModelActivityState();
}

class _CssBoxModelActivityState extends State<CssBoxModelActivity> {
  static const _layers = ['margin', 'border', 'padding', 'content'];
  static const _correct = {
    'margin': 'outer space',
    'border': 'edge line',
    'padding': 'inner space',
    'content': 'text & images',
  };

  final Map<String, String?> _filled = {for (final l in _layers) l: null};
  bool _success = false;

  List<String> get _pool => [
        'outer space',
        'edge line',
        'inner space',
        'text & images',
        'flex-grow',
        'z-index',
      ].where((v) => !_filled.values.contains(v)).toList();

  @override
  Widget build(BuildContext context) {
    return ActivityShell(
      title: 'CSS box model',
      instructions:
          'Match each layer to what it does. Imagine boxes nested inside each other.',
      canCheck: _layers.every((l) => _filled[l] != null),
      onReset: () => setState(() {
        for (final l in _layers) {
          _filled[l] = null;
        }
        _success = false;
      }),
      onCheck: () {
        final ok = _layers.every((l) => _filled[l] == _correct[l]);
        setState(() => _success = ok);
        if (ok) {
          AppToast.success(
            context,
            'Correct! margin → border → padding → content (outside in).',
          );
        } else {
          AppToast.error(
            context,
            'Think outside-in: margin, border, padding, then content.',
          );
        }
      },
      poolSection: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: _pool
            .map(
              (t) => Draggable<String>(
                data: t,
                feedback: Material(
                  color: Colors.transparent,
                  child: Chip(label: Text(t)),
                ),
                child: Chip(label: Text(t)),
              ),
            )
            .toList(),
      ),
      child: Column(
        children: [
          _NestedBoxPreview(filled: _filled, success: _success),
          const SizedBox(height: 16),
          ..._layers.map(
            (layer) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _LayerSlot(
                layer: layer,
                value: _filled[layer],
                onAccept: (v) => setState(() {
                  _filled[layer] = v;
                  _success = false;
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NestedBoxPreview extends StatelessWidget {
  const _NestedBoxPreview({required this.filled, required this.success});

  final Map<String, String?> filled;
  final bool success;

  @override
  Widget build(BuildContext context) {
    Widget box(Color c, String label, Widget child, {double pad = 12}) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.all(pad),
        decoration: BoxDecoration(
          color: c.withValues(alpha: filled[label] != null ? 0.35 : 0.15),
          border: Border.all(
            color: success && filled[label] != null
                ? AppTheme.accent
                : AppTheme.primary.withValues(alpha: 0.4),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: child,
      );
    }

    return box(
      AppTheme.primary,
      'margin',
      box(
        AppTheme.secondary,
        'border',
        box(
          AppTheme.accent,
          'padding',
          box(
            AppTheme.surfaceElevated,
            'content',
            const Center(
              child: Text('Hello', style: TextStyle(fontFamily: 'monospace')),
            ),
            pad: 20,
          ),
          pad: 14,
        ),
        pad: 10,
      ),
      pad: 8,
    );
  }
}

class _LayerSlot extends StatelessWidget {
  const _LayerSlot({
    required this.layer,
    required this.value,
    required this.onAccept,
  });

  final String layer;
  final String? value;
  final void Function(String) onAccept;

  @override
  Widget build(BuildContext context) {
    return DragTarget<String>(
      onWillAcceptWithDetails: (_) => value == null,
      onAcceptWithDetails: (d) => onAccept(d.data),
      builder: (context, candidate, _) {
        return Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: candidate.isNotEmpty
                ? AppTheme.primary.withValues(alpha: 0.1)
                : AppTheme.background,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.textSecondary.withValues(alpha: 0.3)),
          ),
          child: Text(
            '$layer → ${value ?? "drop meaning"}',
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          ),
        );
      },
    );
  }
}
