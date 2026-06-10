import '../models/learning_track.dart';
import '../models/learning_unit.dart';

/// Learning paths: React, CSS, HTML, JavaScript (MVP multi-track).
class LearningRepository {
  static const trackReact = 'react';
  static const trackCss = 'css';
  static const trackHtml = 'html';
  static const trackJs = 'js';

  List<LearningTrack> getTracks() => [
        _reactTrack(),
        _cssTrack(),
        _htmlTrack(),
        _jsTrack(),
      ];

  LearningTrack? getTrack(String trackId) {
    try {
      return getTracks().firstWhere((t) => t.id == trackId);
    } catch (_) {
      return null;
    }
  }

  String trackIdForUnit(String unitId) => unitId.split('-').first;

  List<LearningUnit> getUnitsForTrack(
    String trackId, {
    Set<String> completedIds = const {},
  }) {
    final track = getTrack(trackId);
    if (track == null) return [];
    return _applyProgress(track.units, completedIds);
  }

  LearningUnit? getUnit(String unitId) {
    for (final track in getTracks()) {
      for (final unit in track.units) {
        if (unit.id == unitId) return unit;
      }
    }
    return null;
  }

  /// Back-compat: React path only.
  List<LearningUnit> getReactUnits({Set<String> completedIds = const {}}) =>
      getUnitsForTrack(trackReact, completedIds: completedIds);

  List<LearningUnit> _applyProgress(
    List<LearningUnit> units,
    Set<String> completedIds,
  ) {
    return units.map((unit) {
      if (completedIds.contains(unit.id)) {
        return unit.copyWith(status: UnitStatus.completed);
      }
      final unlocked = unit.order == 1 ||
          completedIds.contains(units[unit.order - 2].id);
      return unit.copyWith(
        status: unlocked ? UnitStatus.inProgress : UnitStatus.locked,
      );
    }).toList();
  }

  LearningTrack _reactTrack() => const LearningTrack(
        id: trackReact,
        name: 'React',
        icon: '⚛️',
        description: 'Components, props, state, hooks, context, Redux.',
        units: [
          LearningUnit(
            id: 'react-components',
            title: 'Components',
            description: 'Reusable UI building blocks.',
            order: 1,
          ),
          LearningUnit(
            id: 'react-props',
            title: 'Props',
            description: 'Pass data parent → child.',
            order: 2,
          ),
          LearningUnit(
            id: 'react-state',
            title: 'State',
            description: 'Data that changes inside a component.',
            order: 3,
          ),
          LearningUnit(
            id: 'react-hooks',
            title: 'Hooks',
            description: 'useState, useEffect, custom hooks.',
            order: 4,
          ),
          LearningUnit(
            id: 'react-useeffect',
            title: 'useEffect',
            description: 'Side effects after render.',
            order: 5,
          ),
          LearningUnit(
            id: 'react-context',
            title: 'Context API',
            description: 'Share data without prop drilling.',
            order: 6,
          ),
          LearningUnit(
            id: 'react-redux',
            title: 'Redux',
            description: 'Global store, actions, reducers.',
            order: 7,
          ),
        ],
      );

  LearningTrack _cssTrack() => const LearningTrack(
        id: trackCss,
        name: 'CSS',
        icon: '🎨',
        description: 'Selectors, box model, flexbox, grid, colors.',
        units: [
          LearningUnit(
            id: 'css-selectors',
            title: 'Selectors',
            description: 'Target elements with CSS rules.',
            order: 1,
          ),
          LearningUnit(
            id: 'css-box-model',
            title: 'Box Model',
            description: 'Margin, border, padding, content.',
            order: 2,
          ),
          LearningUnit(
            id: 'css-flexbox',
            title: 'Flexbox',
            description: 'One-dimensional layouts.',
            order: 3,
          ),
          LearningUnit(
            id: 'css-grid',
            title: 'Grid',
            description: 'Rows and columns together.',
            order: 4,
          ),
          LearningUnit(
            id: 'css-colors',
            title: 'Colors & Units',
            description: 'hex, rgb, rem, em, %.',
            order: 5,
          ),
        ],
      );

  LearningTrack _htmlTrack() => const LearningTrack(
        id: trackHtml,
        name: 'HTML',
        icon: '📄',
        description: 'Structure, semantics, forms, accessibility.',
        units: [
          LearningUnit(
            id: 'html-structure',
            title: 'Page Structure',
            description: 'DOCTYPE, head, body, meta.',
            order: 1,
          ),
          LearningUnit(
            id: 'html-semantic',
            title: 'Semantic HTML',
            description: 'header, nav, main, article, footer.',
            order: 2,
          ),
          LearningUnit(
            id: 'html-forms',
            title: 'Forms',
            description: 'input, label, button, validation attrs.',
            order: 3,
          ),
          LearningUnit(
            id: 'html-media',
            title: 'Media & Links',
            description: 'img, video, a, alt text.',
            order: 4,
          ),
        ],
      );

  LearningTrack _jsTrack() => const LearningTrack(
        id: trackJs,
        name: 'JavaScript',
        icon: '⚡',
        description: 'Variables, functions, DOM, events.',
        units: [
          LearningUnit(
            id: 'js-variables',
            title: 'Variables',
            description: 'let, const, types, scope.',
            order: 1,
          ),
          LearningUnit(
            id: 'js-functions',
            title: 'Functions',
            description: 'Declarations, arrows, parameters.',
            order: 2,
          ),
          LearningUnit(
            id: 'js-dom',
            title: 'DOM',
            description: 'querySelector, textContent, classList.',
            order: 3,
          ),
          LearningUnit(
            id: 'js-events',
            title: 'Events',
            description: 'click, input, addEventListener.',
            order: 4,
          ),
        ],
      );

  String getVisualExplanation(String unitId) {
    final track = trackIdForUnit(unitId);
    return 'Open the **Learn** tab for an animated diagram, '
        'then **Activity** for drag-and-drop practice ($track).';
  }
}
