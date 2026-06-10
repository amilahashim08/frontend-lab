import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_toast.dart';
import '../../../shared/widgets/glow_card.dart';

/// Drag prop values from the parent onto the child's prop slots.
class PropsPassActivity extends StatefulWidget {
  const PropsPassActivity({super.key});

  @override
  State<PropsPassActivity> createState() => _PropsPassActivityState();
}

class _PropsPassActivityState extends State<PropsPassActivity>
    with SingleTickerProviderStateMixin {
  static const _slots = ['name', 'role', 'isActive'];

  static const _correct = {
    'name': 'Alice Chen',
    'role': 'Frontend Dev',
    'isActive': 'true',
  };

  final Map<String, String?> _filled = {
    for (final s in _slots) s: null,
  };

  late final AnimationController _pulse;
  bool _showSuccess = false;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  List<String> get _pool {
    const all = [
      'Alice Chen',
      'Frontend Dev',
      'true',
      '42',
      'onClick',
      'null',
    ];
    return all.where((v) => !_filled.values.contains(v)).toList();
  }

  void _onAccept(String slot, String value) {
    setState(() {
      _filled[slot] = value;
      _showSuccess = false;
    });
  }

  void _reset() {
    setState(() {
      for (final s in _slots) {
        _filled[s] = null;
      }
      _showSuccess = false;
    });
  }

  void _check() {
    final ok = _slots.every((s) => _filled[s] == _correct[s]);
    setState(() => _showSuccess = ok);
    if (!mounted) return;
    if (ok) {
      AppToast.success(
        context,
        'Correct! Props are read-only inputs passed parent → child.',
      );
    } else {
      AppToast.error(context, 'Match each prop: name, role, isActive');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _InstructionBanner(
            title: 'Pass props to a child',
            body:
                'Drag each value from the Parent into the matching prop on UserCard. '
                'Props let a parent configure a child without changing its code.',
          ),
          const SizedBox(height: 16),
          FadeTransition(
            opacity: Tween(begin: 0.85, end: 1.0).animate(_pulse),
            child: _ParentCard(poolCount: _pool.length),
          ),
          const SizedBox(height: 8),
          Center(
            child: Icon(
              Icons.arrow_downward_rounded,
              color: AppTheme.primary.withValues(alpha: 0.8),
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _showSuccess
                    ? AppTheme.accent
                    : AppTheme.secondary.withValues(alpha: 0.3),
                width: _showSuccess ? 2 : 1,
              ),
            ),
            child: GlowCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.widgets_outlined,
                          color: AppTheme.secondary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '<UserCard />',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontFamily: 'monospace',
                              color: AppTheme.secondary,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ..._slots.map((slot) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _PropSlot(
                          propName: slot,
                          value: _filled[slot],
                          onAccept: (v) => _onAccept(slot, v),
                          highlight: _showSuccess &&
                              _filled[slot] == _correct[slot],
                        ),
                      )),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Drag from parent →',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _pool.map((label) => _DraggableChip(label: label)).toList(),
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
                  onPressed: _slots.every((s) => _filled[s] != null)
                      ? _check
                      : null,
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

class _InstructionBanner extends StatelessWidget {
  const _InstructionBanner({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 6),
          Text(body, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _ParentCard extends StatelessWidget {
  const _ParentCard({required this.poolCount});

  final int poolCount;

  @override
  Widget build(BuildContext context) {
    return GlowCard(
      child: Row(
        children: [
          Icon(Icons.account_tree_outlined, color: AppTheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Parent component',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Text(
                  'Has data to pass down ($poolCount values left)',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PropSlot extends StatelessWidget {
  const _PropSlot({
    required this.propName,
    required this.value,
    required this.onAccept,
    this.highlight = false,
  });

  final String propName;
  final String? value;
  final void Function(String value) onAccept;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return DragTarget<String>(
      onWillAcceptWithDetails: (d) => value == null,
      onAcceptWithDetails: (d) => onAccept(d.data),
      builder: (context, candidate, rejected) {
        final active = candidate.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: active
                ? AppTheme.primary.withValues(alpha: 0.15)
                : AppTheme.background,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: highlight
                  ? AppTheme.accent
                  : active
                      ? AppTheme.primary
                      : AppTheme.textSecondary.withValues(alpha: 0.35),
              width: active || highlight ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Text(
                '$propName = ',
                style: const TextStyle(
                  fontFamily: 'monospace',
                  color: AppTheme.primary,
                  fontSize: 13,
                ),
              ),
              Expanded(
                child: Text(
                  value ?? 'drop value here',
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

class _DraggableChip extends StatelessWidget {
  const _DraggableChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Draggable<String>(
      data: label,
      feedback: Material(
        color: Colors.transparent,
        child: _chipShell(label, elevated: true),
      ),
      childWhenDragging: Opacity(
        opacity: 0.35,
        child: _chipShell(label),
      ),
      child: _chipShell(label),
    );
  }

  Widget _chipShell(String text, {bool elevated = false}) {
    return Material(
      color: AppTheme.surfaceElevated,
      elevation: elevated ? 8 : 0,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.primary.withValues(alpha: 0.5)),
        ),
        child: Text(
          text,
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
