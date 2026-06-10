/// Application-wide constants aligned with [REQUIREMENTS.md].
class AppConstants {
  AppConstants._();

  static const String appName = 'Frontend Lab';

  // MVP learning path (React)
  static const String mvpTopicId = 'TOP-001';
  static const String mvpTopicName = 'React';

  // Full topic catalog (post-MVP expansion)
  static const List<String> allTopicIds = [
    'TOP-001',
    'TOP-002',
    'TOP-003',
    'TOP-004',
    'TOP-005',
    'TOP-006',
    'TOP-007',
    'TOP-008',
    'TOP-009',
    'TOP-010',
  ];

  static const Map<String, String> topicNames = {
    'TOP-001': 'React',
    'TOP-002': 'JavaScript',
    'TOP-003': 'Node.js',
    'TOP-004': 'Express',
    'TOP-005': 'MongoDB',
    'TOP-006': 'System Design',
    'TOP-007': 'Frontend Architecture',
    'TOP-008': 'APIs',
    'TOP-009': 'Authentication',
    'TOP-010': 'Performance Optimization',
  };

  // Interview tracks (FR-AI)
  static const List<InterviewTrack> interviewTracks = [
    InterviewTrack(id: 'INT-001', name: 'Junior Frontend', icon: '🌱'),
    InterviewTrack(id: 'INT-002', name: 'React Developer', icon: '⚛️'),
    InterviewTrack(id: 'INT-003', name: 'MERN Stack', icon: '🧱'),
    InterviewTrack(id: 'INT-004', name: 'Senior Frontend', icon: '🏗️'),
  ];

  // Gamification ranks (FR-GM-01)
  static const List<String> rankTitles = [
    'React Apprentice',
    'Hook Master',
    'Component Crafter',
    'State Strategist',
    'Frontend Architect',
  ];

  static const int defaultQuizPassingScore = 70;
  static const int defaultInterviewQuestions = 5;
  static const int xpPerQuizPass = 50;
  static const int xpPerUnitComplete = 100;
  static const int xpPerInterviewSession = 75;
}

class InterviewTrack {
  const InterviewTrack({
    required this.id,
    required this.name,
    required this.icon,
  });

  final String id;
  final String name;
  final String icon;
}

enum LearningFocus { react, mern, frontend }

enum ExperienceLevel { beginner, intermediate, advanced }

enum InterviewMode {
  text,
  voice, // Post-MVP
  liveCoding, // Post-MVP
}

enum FeaturePhase { mvp, phase2, phase3, phase4 }
