import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_toast.dart';
import '../../../shared/widgets/glow_card.dart';

/// Order Redux flow steps with drag-and-drop.
class ReduxFlowActivity extends StatefulWidget {
  const ReduxFlowActivity({super.key});

  @override
  State<ReduxFlowActivity> createState() => _ReduxFlowActivityState();
}

class _ReduxFlowActivityState extends State<ReduxFlowActivity> {
  static const _correct = ['Actions', 'Reducers', 'Store'];

  final List<String?> _slots = List.filled(3, null);
  bool _success = false;

  static const _pool = ['Actions', 'Reducers', 'Store', 'Components'];

  List<String> get _available =>
      _pool.where((p) => !_slots.contains(p)).toList();

  void _place(int index, String label) {
    setState(() {
      _slots[index] = label;
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
      _correct.length,
      (i) => _slots[i] == _correct[i],
    ).every((v) => v);
    setState(() => _success = ok);
    if (!mounted) return;
    if (ok) {
      AppToast.success(context, 'Correct! UI → Actions → Reducers → Store → UI');
    } else {
      AppToast.error(context, 'Try: Actions → Reducers → Store');
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
            child: Text(
              'Drag the Redux pipeline in order after a dispatch.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(3, (i) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _FlowSlot(
                step: i + 1,
                label: _slots[i],
                onAccept: (v) => _place(i, v),
                highlight: _success && _slots[i] == _correct[i],
              ),
            );
          }),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _available
                .map((label) => _DraggableStep(label: label))
                .toList(),
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

class _FlowSlot extends StatelessWidget {
  const _FlowSlot({
    required this.step,
    required this.label,
    required this.onAccept,
    this.highlight = false,
  });

  final int step;
  final String? label;
  final void Function(String) onAccept;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return DragTarget<String>(
      onWillAcceptWithDetails: (_) => label == null,
      onAcceptWithDetails: (d) => onAccept(d.data),
      builder: (context, candidate, _) {
        final active = candidate.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          child: GlowCard(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: active
                      ? AppTheme.primary
                      : AppTheme.surfaceElevated,
                  child: Text(
                    '$step',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label ?? 'Drop step $step',
                    style: TextStyle(
                      color: label != null
                          ? AppTheme.textPrimary
                          : AppTheme.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

Widget _stepChip(String label) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: AppTheme.surfaceElevated,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppTheme.primary.withValues(alpha: 0.4)),
    ),
    child: Text(label, style: const TextStyle(color: AppTheme.textPrimary)),
  );
}

class _DraggableStep extends StatelessWidget {
  const _DraggableStep({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Draggable<String>(
      data: label,
      feedback: Material(
        color: Colors.transparent,
        child: Chip(
          label: Text(label),
          backgroundColor: AppTheme.surfaceElevated,
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.35,
        child: _stepChip(label),
      ),
      child: _stepChip(label),
    );
  }
}
