import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_toast.dart';
import '../../../shared/widgets/glow_card.dart';

/// Drag child pieces into a parent to learn composition.
class ComponentsComposeActivity extends StatefulWidget {
  const ComponentsComposeActivity({super.key});

  @override
  State<ComponentsComposeActivity> createState() =>
      _ComponentsComposeActivityState();
}

class _ComponentsComposeActivityState extends State<ComponentsComposeActivity> {
  static const _order = ['Header', 'Content', 'Footer'];

  final List<String?> _slots = List.filled(3, null);
  bool _success = false;

  static const _pieces = [
    'Header',
    'Content',
    'Footer',
    'Sidebar',
    'Modal',
  ];

  List<String> get _available =>
      _pieces.where((p) => !_slots.contains(p)).toList();

  void _place(int index, String piece) {
    setState(() {
      _slots[index] = piece;
      _success = false;
    });
  }

  void _reset() {
    setState(() {
      for (var i = 0; i < _slots.length; i++) {
        _slots[i] = null;
      }
      _success = false;
    });
  }

  void _check() {
    final ok = List.generate(
      _order.length,
      (i) => _slots[i] == _order[i],
    ).every((v) => v);
    setState(() => _success = ok);
    if (!mounted) return;
    if (ok) {
      AppToast.success(
        context,
        'Nice! Components nest inside parents — small pieces, big UIs.',
      );
    } else {
      AppToast.error(context, 'Order: Header → Content → Footer');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.surfaceElevated,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.primary.withValues(alpha: 0.25)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Compose a Page component',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 6),
                Text(
                  'Drag child components into the parent in top-to-bottom order. '
                  'Each box is its own reusable component.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AnimatedContainer(
            duration: const Duration(milliseconds: 350),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _success
                    ? AppTheme.accent
                    : AppTheme.primary.withValues(alpha: 0.35),
                width: _success ? 2 : 1,
              ),
            ),
            child: GlowCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '<Page>',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontFamily: 'monospace',
                          color: AppTheme.primary,
                        ),
                  ),
                  const SizedBox(height: 12),
                  ...List.generate(3, (i) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _ComposeSlot(
                        index: i,
                        label: _slots[i],
                        onAccept: (p) => _place(i, p),
                        glow: _success && _slots[i] == _order[i],
                      ),
                    );
                  }),
                  const Text(
                    '</Page>',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Component pieces', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children:
                _available.map((p) => _DraggablePiece(label: p)).toList(),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _reset,
                  child: const Text('Reset'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed:
                      _slots.every((s) => s != null) ? _check : null,
                  child: const Text('Check answer'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ComposeSlot extends StatelessWidget {
  const _ComposeSlot({
    required this.index,
    required this.label,
    required this.onAccept,
    this.glow = false,
  });

  final int index;
  final String? label;
  final void Function(String) onAccept;
  final bool glow;

  @override
  Widget build(BuildContext context) {
    return DragTarget<String>(
      onWillAcceptWithDetails: (d) => label == null,
      onAcceptWithDetails: (d) => onAccept(d.data),
      builder: (context, candidate, _) {
        final active = candidate.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          height: 52,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: active
                ? AppTheme.secondary.withValues(alpha: 0.12)
                : AppTheme.background,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: glow
                  ? AppTheme.accent
                  : active
                      ? AppTheme.secondary
                      : AppTheme.textSecondary.withValues(alpha: 0.3),
            ),
          ),
          child: Text(
            label ?? 'Slot ${index + 1} — drop a component',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 13,
              color: label != null
                  ? AppTheme.textPrimary
                  : AppTheme.textSecondary,
            ),
          ),
        );
      },
    );
  }
}

class _DraggablePiece extends StatelessWidget {
  const _DraggablePiece({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Draggable<String>(
      data: label,
      feedback: Material(
        color: Colors.transparent,
        child: _piece(label, dragging: true),
      ),
      childWhenDragging: Opacity(opacity: 0.3, child: _piece(label)),
      child: _piece(label),
    );
  }

  Widget _piece(String text, {bool dragging = false}) {
    return Material(
      elevation: dragging ? 6 : 0,
      borderRadius: BorderRadius.circular(12),
      color: AppTheme.surfaceElevated,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.secondary.withValues(alpha: 0.6)),
        ),
        child: Text(
          '<$text />',
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 13,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
    );
  }
}
