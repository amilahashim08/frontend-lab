/// Frontend interview prep question with a detailed model answer.
class InterviewQuestion {
  const InterviewQuestion({
    required this.id,
    required this.categoryId,
    required this.question,
    required this.detailedAnswer,
    this.frequency = 'High',
    this.tags = const [],
    this.codeExample,
  });

  final String id;
  final String categoryId;
  final String question;
  final String detailedAnswer;
  final String frequency;
  final List<String> tags;
  final String? codeExample;

  String get narrationScript {
    final buffer = StringBuffer()
      ..write(question)
      ..write('. ')
      ..write(detailedAnswer);
    if (codeExample != null && codeExample!.trim().isNotEmpty) {
      buffer.write(' Code example: ${codeExample!.trim()}');
    }
    return buffer.toString();
  }
}

class InterviewCategoryInfo {
  const InterviewCategoryInfo({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
  });

  final String id;
  final String name;
  final String icon;
  final String description;
}
