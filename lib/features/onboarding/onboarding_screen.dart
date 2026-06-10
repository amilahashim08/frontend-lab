import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/app_providers.dart';
import '../../shared/widgets/glow_card.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  LearningFocus _focus = LearningFocus.react;
  ExperienceLevel _level = ExperienceLevel.beginner;

  Future<void> _continue() async {
    await ref.read(progressServiceProvider).setOnboardingDone(
          focus: _focus,
          level: _level,
        );
    if (!mounted) return;
    context.go('/auth');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Personalize your path',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Select focus and experience (FR-ON-01)',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
              const SizedBox(height: 24),
              Text('Learning focus', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 12),
              _FocusChip(
                label: 'React',
                selected: _focus == LearningFocus.react,
                onTap: () => setState(() => _focus = LearningFocus.react),
              ),
              _FocusChip(
                label: 'MERN',
                selected: _focus == LearningFocus.mern,
                onTap: () => setState(() => _focus = LearningFocus.mern),
              ),
              _FocusChip(
                label: 'Frontend (General)',
                selected: _focus == LearningFocus.frontend,
                onTap: () => setState(() => _focus = LearningFocus.frontend),
              ),
              const SizedBox(height: 24),
              Text('Experience level',
                  style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 12),
              ...ExperienceLevel.values.map(
                (level) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: GlowCard(
                    glowColor: _level == level ? AppTheme.secondary : null,
                    onTap: () => setState(() => _level = level),
                    child: Row(
                      children: [
                        Icon(
                          _level == level
                              ? Icons.check_circle
                              : Icons.circle_outlined,
                          color: _level == level
                              ? AppTheme.secondary
                              : AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 12),
                        Text(level.name),
                      ],
                    ),
                  ),
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _continue,
                child: const Text('Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FocusChip extends StatelessWidget {
  const _FocusChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GlowCard(
        glowColor: selected ? AppTheme.primary : null,
        onTap: onTap,
        child: Row(
          children: [
            Icon(
              selected ? Icons.check_circle : Icons.circle_outlined,
              color: selected ? AppTheme.primary : AppTheme.textSecondary,
            ),
            const SizedBox(width: 12),
            Text(label),
          ],
        ),
      ),
    );
  }
}
