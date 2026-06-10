import 'learning_unit.dart';

/// A technology path (React, CSS, HTML, JavaScript, …).
class LearningTrack {
  const LearningTrack({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
    required this.units,
  });

  final String id;
  final String name;
  final String icon;
  final String description;
  final List<LearningUnit> units;
}
