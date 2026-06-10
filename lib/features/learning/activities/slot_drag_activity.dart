import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_toast.dart';
import 'activity_shell.dart';

/// Configurable drag-and-drop matching activity.
class SlotDragActivity extends StatefulWidget {
  const SlotDragActivity({
    super.key,
    required this.title,
    required this.instructions,
    required this.slots,
    required this.correct,
    required this.pool,
    required this.successMessage,
    required this.failMessage,
    this.ordered = false,
    this.slotPrefix,
  });

  final String title;
  final String instructions;
  final List<String> slots;
  final Map<String, String> correct;
  final List<String> pool;
  final String successMessage;
  final String failMessage;
  final bool ordered;
  final String? slotPrefix;

  @override
  State<SlotDragActivity> createState() => _SlotDragActivityState();
}

class _SlotDragActivityState extends State<SlotDragActivity> {
  late final Map<String, String?> _filled;
  bool _success = false;

  @override
  void initState() {
    super.initState();
    _filled = {for (final s in widget.slots) s: null};
  }

  List<String> get _available =>
      widget.pool.where((p) => !_filled.values.contains(p)).toList();

  void _reset() {
    setState(() {
      for (final s in widget.slots) {
        _filled[s] = null;
      }
      _success = false;
    });
  }

  bool _isCorrect() {
    if (widget.ordered) {
      return List.generate(
        widget.slots.length,
        (i) => _filled[widget.slots[i]] == widget.correct[widget.slots[i]],
      ).every((v) => v);
    }
    return widget.slots.every((s) => _filled[s] == widget.correct[s]);
  }

  void _check() {
    final ok = _isCorrect();
    setState(() => _success = ok);
    if (!mounted) return;
    if (ok) {
      AppToast.success(context, widget.successMessage);
    } else {
      AppToast.error(context, widget.failMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final prefix = widget.slotPrefix ?? '';
    return ActivityShell(
      title: widget.title,
      instructions: widget.instructions,
      canCheck: widget.slots.every((s) => _filled[s] != null),
      onReset: _reset,
      onCheck: _check,
      poolSection: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Drag answers →', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _available.map((t) => _DragChip(label: t)).toList(),
          ),
        ],
      ),
      child: Column(
        children: widget.slots.map((slot) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _DropSlot(
              label: '$prefix$slot',
              value: _filled[slot],
              highlight: _success && _filled[slot] == widget.correct[slot],
              onAccept: (v) => setState(() {
                _filled[slot] = v;
                _success = false;
              }),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _DropSlot extends StatelessWidget {
  const _DropSlot({
    required this.label,
    required this.value,
    required this.onAccept,
    this.highlight = false,
  });

  final String label;
  final String? value;
  final void Function(String) onAccept;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return DragTarget<String>(
      onWillAcceptWithDetails: (_) => value == null,
      onAcceptWithDetails: (d) => onAccept(d.data),
      builder: (context, candidate, _) {
        final active = candidate.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: active
                ? AppTheme.primary.withValues(alpha: 0.12)
                : AppTheme.background,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: highlight
                  ? AppTheme.accent
                  : active
                      ? AppTheme.primary
                      : AppTheme.textSecondary.withValues(alpha: 0.35),
              width: highlight || active ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    color: AppTheme.primary,
                    fontSize: 13,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  value ?? 'drop here',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13,
                    color: value != null
                        ? AppTheme.textPrimary
                        : AppTheme.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DragChip extends StatelessWidget {
  const _DragChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Draggable<String>(
      data: label,
      feedback: Material(
        color: Colors.transparent,
        child: _chip(elevated: true),
      ),
      childWhenDragging: Opacity(opacity: 0.35, child: _chip()),
      child: _chip(),
    );
  }

  Widget _chip({bool elevated = false}) {
    return Material(
      elevation: elevated ? 6 : 0,
      borderRadius: BorderRadius.circular(20),
      color: AppTheme.surfaceElevated,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.secondary.withValues(alpha: 0.5)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 12,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
    );
  }
}
