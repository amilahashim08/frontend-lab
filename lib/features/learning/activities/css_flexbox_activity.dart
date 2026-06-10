import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_toast.dart';
import 'activity_shell.dart';

/// Pick flex properties and see a live preview row animate.
class CssFlexboxActivity extends StatefulWidget {
  const CssFlexboxActivity({super.key});

  @override
  State<CssFlexboxActivity> createState() => _CssFlexboxActivityState();
}

class _CssFlexboxActivityState extends State<CssFlexboxActivity> {
  String? _justify;
  String? _align;
  bool _success = false;

  static const _justifyCorrect = 'center';
  static const _alignCorrect = 'center';

  List<String> get _justifyPool =>
      ['flex-start', 'center', 'space-between', 'stretch']
          .where((v) => v != _justify)
          .toList();

  List<String> get _alignPool =>
      ['flex-start', 'center', 'stretch', 'flex-end']
          .where((v) => v != _align)
          .toList();

  MainAxisAlignment get _main =>
      _justify == 'center'
          ? MainAxisAlignment.center
          : _justify == 'space-between'
              ? MainAxisAlignment.spaceBetween
              : MainAxisAlignment.start;

  CrossAxisAlignment get _cross =>
      _align == 'center'
          ? CrossAxisAlignment.center
          : _align == 'stretch'
              ? CrossAxisAlignment.stretch
              : CrossAxisAlignment.start;

  @override
  Widget build(BuildContext context) {
    return ActivityShell(
      title: 'Flexbox alignment',
      instructions:
          'Center the three boxes horizontally AND vertically. '
          'Drag values into justify-content and align-items.',
      canCheck: _justify != null && _align != null,
      onReset: () => setState(() {
        _justify = null;
        _align = null;
        _success = false;
      }),
      onCheck: () {
        final ok =
            _justify == _justifyCorrect && _align == _alignCorrect;
        setState(() => _success = ok);
        if (ok) {
          AppToast.success(
            context,
            'Perfect centering: justify-content & align-items: center',
          );
        } else {
          AppToast.error(context, 'Hint: use center for both properties.');
        }
      },
      poolSection: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('justify-content',
              style: Theme.of(context).textTheme.labelMedium),
          Wrap(
            spacing: 8,
            children: _justifyPool
                .map((v) => _drag(v, AppTheme.primary))
                .toList(),
          ),
          const SizedBox(height: 12),
          Text('align-items', style: Theme.of(context).textTheme.labelMedium),
          Wrap(
            spacing: 8,
            children:
                _alignPool.map((v) => _drag(v, AppTheme.secondary)).toList(),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _success
                    ? AppTheme.accent
                    : AppTheme.primary.withValues(alpha: 0.35),
              ),
            ),
            child: Row(
              mainAxisAlignment: _main,
              crossAxisAlignment: _cross,
              children: List.generate(
                3,
                (i) => Container(
                  width: 36,
                  height: 36,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _FlexSlot(
            label: 'justify-content',
            value: _justify,
            onAccept: (v) => setState(() {
              _justify = v;
              _success = false;
            }),
          ),
          const SizedBox(height: 8),
          _FlexSlot(
            label: 'align-items',
            value: _align,
            onAccept: (v) => setState(() {
              _align = v;
              _success = false;
            }),
          ),
        ],
      ),
    );
  }

  Widget _drag(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.only(right: 8, bottom: 8),
      child: Draggable<String>(
        data: label,
        feedback: Material(
          color: Colors.transparent,
          child: Chip(
            label: Text(label, style: TextStyle(color: color)),
          ),
        ),
        child: Chip(
          label: Text(label, style: TextStyle(fontFamily: 'monospace')),
        ),
      ),
    );
  }
}

class _FlexSlot extends StatelessWidget {
  const _FlexSlot({
    required this.label,
    required this.value,
    required this.onAccept,
  });

  final String label;
  final String? value;
  final void Function(String) onAccept;

  @override
  Widget build(BuildContext context) {
    return DragTarget<String>(
      onWillAcceptWithDetails: (_) => value == null,
      onAcceptWithDetails: (d) => onAccept(d.data),
      builder: (context, candidate, _) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: candidate.isNotEmpty
                ? AppTheme.secondary.withValues(alpha: 0.12)
                : AppTheme.surfaceElevated,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$label: ${value ?? "drop value"}',
            style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
          ),
        );
      },
    );
  }
}
