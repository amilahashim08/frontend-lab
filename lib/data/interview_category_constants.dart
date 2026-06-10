import 'models/interview_question.dart';

/// Categories from the Frontend Interview question bank.
class InterviewCategories {
  InterviewCategories._();

  static const javascript = 'javascript';
  static const react = 'react';
  static const css = 'css';
  static const machineCoding = 'machine_coding';
  static const typescript = 'typescript';

  static const List<InterviewCategoryInfo> all = [
    InterviewCategoryInfo(
      id: javascript,
      name: 'JavaScript',
      icon: '🟨',
      description: '30 most-asked JS fundamentals — closures, async, DOM, and more.',
    ),
    InterviewCategoryInfo(
      id: react,
      name: 'React',
      icon: '⚛️',
      description: '20 core React questions — hooks, performance, state, and architecture.',
    ),
    InterviewCategoryInfo(
      id: css,
      name: 'CSS',
      icon: '🎨',
      description: '15 layout and styling questions — box model, flex, grid, specificity.',
    ),
    InterviewCategoryInfo(
      id: machineCoding,
      name: 'Machine Coding',
      icon: '⌨️',
      description: '10 live-build challenges — todo, autocomplete, carousel, and more.',
    ),
    InterviewCategoryInfo(
      id: typescript,
      name: 'TypeScript',
      icon: '🔷',
      description: '10 typing questions — generics, utility types, React + TS patterns.',
    ),
  ];

  static InterviewCategoryInfo? byId(String id) {
    for (final c in all) {
      if (c.id == id) return c;
    }
    return null;
  }
}
