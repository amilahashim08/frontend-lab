enum UnitStatus { locked, inProgress, completed }

class LearningUnit {
  const LearningUnit({
    required this.id,
    required this.title,
    required this.description,
    required this.order,
    this.status = UnitStatus.locked,
    this.hasActivity = true,
    this.hasQuiz = true,
  });

  final String id;
  final String title;
  final String description;
  final int order;
  final UnitStatus status;
  final bool hasActivity;
  final bool hasQuiz;

  LearningUnit copyWith({UnitStatus? status}) {
    return LearningUnit(
      id: id,
      title: title,
      description: description,
      order: order,
      status: status ?? this.status,
      hasActivity: hasActivity,
      hasQuiz: hasQuiz,
    );
  }
}
