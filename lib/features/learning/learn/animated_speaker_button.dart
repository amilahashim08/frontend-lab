import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import 'learn_narration.dart';

/// Volume button that pulses while TTS is speaking.
class AnimatedSpeakerButton extends StatefulWidget {
  const AnimatedSpeakerButton({
    super.key,
    required this.onPressed,
    this.size = 22,
  });

  final VoidCallback onPressed;
  final double size;

  @override
  State<AnimatedSpeakerButton> createState() => _AnimatedSpeakerButtonState();
}

class _AnimatedSpeakerButtonState extends State<AnimatedSpeakerButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  late final Animation<double> _scale;
  late final Animation<double> _waveOpacity;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _scale = Tween<double>(begin: 1.0, end: 1.22).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
    );
    _waveOpacity = Tween<double>(begin: 0.25, end: 0.85).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
    );
    LearnNarration.instance.speaking.addListener(_onSpeakingChanged);
    _syncPulse(LearnNarration.instance.speaking.value);
  }

  void _onSpeakingChanged() {
    _syncPulse(LearnNarration.instance.speaking.value);
  }

  void _syncPulse(bool active) {
    if (!mounted) return;
    if (active) {
      if (!_pulse.isAnimating) _pulse.repeat(reverse: true);
    } else {
      _pulse
        ..stop()
        ..value = 0;
    }
    setState(() {});
  }

  @override
  void dispose() {
    LearnNarration.instance.speaking.removeListener(_onSpeakingChanged);
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: LearnNarration.instance.speaking,
      builder: (context, isSpeaking, _) {
        return IconButton(
          tooltip: isSpeaking ? 'Speaking…' : 'Listen (text-to-speech)',
          onPressed: widget.onPressed,
          icon: AnimatedBuilder(
            animation: _pulse,
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  if (isSpeaking) ...[
                    _SoundRing(
                      size: widget.size + 14,
                      opacity: _waveOpacity.value * 0.5,
                    ),
                    _SoundRing(
                      size: widget.size + 22,
                      opacity: _waveOpacity.value * 0.3,
                    ),
                  ],
                  Transform.scale(
                    scale: isSpeaking ? _scale.value : 1,
                    child: Icon(
                      isSpeaking
                          ? Icons.volume_up_rounded
                          : Icons.volume_up_outlined,
                      size: widget.size,
                      color: isSpeaking ? AppTheme.accent : null,
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _SoundRing extends StatelessWidget {
  const _SoundRing({required this.size, required this.opacity});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppTheme.accent.withValues(alpha: opacity),
          width: 1.5,
        ),
      ),
    );
  }
}
