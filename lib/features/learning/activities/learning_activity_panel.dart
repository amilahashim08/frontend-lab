import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import 'components_compose_activity.dart';
import 'css_box_model_activity.dart';
import 'css_flexbox_activity.dart';
import 'props_pass_activity.dart';
import 'redux_flow_activity.dart';
import 'slot_drag_activity.dart';

/// Interactive activity for each learning unit (React, CSS, HTML, JS).
class LearningActivityPanel extends StatelessWidget {
  const LearningActivityPanel({super.key, required this.unitId});

  final String unitId;

  @override
  Widget build(BuildContext context) {
    final activity = _buildActivity(unitId);
    return activity ?? const _ComingSoonActivity();
  }

  Widget? _buildActivity(String id) {
    switch (id) {
      // React — custom UIs
      case 'react-components':
        return const ComponentsComposeActivity();
      case 'react-props':
        return const PropsPassActivity();
      case 'react-redux':
        return const ReduxFlowActivity();
      case 'react-state':
        return const SlotDragActivity(
          title: 'State updates',
          instructions:
              'Match each term to how React state behaves. Drag answers into each slot.',
          slots: ['useState', 'setState', 're-render'],
          correct: {
            'useState': 'hook that holds value',
            'setState': 'function that schedules update',
            're-render': 'UI updates after change',
          },
          pool: [
            'hook that holds value',
            'function that schedules update',
            'UI updates after change',
            'props from parent',
            'global Redux store',
          ],
          successMessage: 'State lives in the component; updating it refreshes the UI.',
          failMessage: 'useState → setState → re-render',
        );
      case 'react-hooks':
        return const SlotDragActivity(
          title: 'Hooks rules',
          instructions: 'Match each hook to its main purpose.',
          slots: ['useState', 'useEffect', 'useContext'],
          correct: {
            'useState': 'local state',
            'useEffect': 'side effects',
            'useContext': 'read context value',
          },
          pool: [
            'local state',
            'side effects',
            'read context value',
            'CSS styles',
            'routing only',
          ],
          successMessage: 'Hooks add state, effects, and context to function components.',
          failMessage: 'useState = state, useEffect = effects, useContext = context',
        );
      case 'react-useeffect':
        return const SlotDragActivity(
          title: 'useEffect lifecycle',
          instructions: 'Order what happens when a component mounts and unmounts.',
          slots: ['1. Render', '2. Effect', '3. Cleanup'],
          correct: {
            '1. Render': 'component renders',
            '2. Effect': 'effect runs',
            '3. Cleanup': 'cleanup on unmount',
          },
          pool: [
            'component renders',
            'effect runs',
            'cleanup on unmount',
            'props deleted',
            'CSS parsed first',
          ],
          ordered: true,
          slotPrefix: '',
          successMessage: 'Render → effect → cleanup is the classic flow.',
          failMessage: 'Order: render, effect runs, cleanup on unmount',
        );
      case 'react-context':
        return const SlotDragActivity(
          title: 'Context flow',
          instructions: 'Match each piece of the Context API pattern.',
          slots: ['Provider', 'value', 'Consumer'],
          correct: {
            'Provider': 'wraps subtree',
            'value': 'data shared',
            'Consumer': 'reads value',
          },
          pool: [
            'wraps subtree',
            'data shared',
            'reads value',
            'HTTP request',
            'database row',
          ],
          successMessage: 'Provider shares value; children consume without prop drilling.',
          failMessage: 'Provider wraps tree, passes value, Consumer/useContext reads it',
        );

      // CSS
      case 'css-selectors':
        return const SlotDragActivity(
          title: 'CSS selectors',
          instructions: 'Match each selector syntax to what it targets.',
          slots: ['.card', '#hero', 'div p'],
          correct: {
            '.card': 'class="card"',
            '#hero': 'id="hero"',
            'div p': 'p inside div',
          },
          pool: [
            'class="card"',
            'id="hero"',
            'p inside div',
            'all links only',
            'first child always',
          ],
          successMessage: 'Classes use ., IDs use #, descendant uses a space.',
          failMessage: '.class  #id  descendant (space)',
        );
      case 'css-box-model':
        return const CssBoxModelActivity();
      case 'css-flexbox':
        return const CssFlexboxActivity();
      case 'css-grid':
        return const SlotDragActivity(
          title: 'CSS Grid vs Flexbox',
          instructions: 'When should you pick Grid vs Flexbox?',
          slots: ['flexbox', 'grid'],
          correct: {
            'flexbox': 'one row or column flow',
            'grid': 'rows AND columns together',
          },
          pool: [
            'one row or column flow',
            'rows AND columns together',
            'only for fonts',
            'replaces HTML',
          ],
          successMessage: 'Flexbox = 1D layout. Grid = 2D rows + columns.',
          failMessage: 'Flexbox for one axis; Grid for two-dimensional layouts',
        );
      case 'css-colors':
        return const SlotDragActivity(
          title: 'CSS units & colors',
          instructions: 'Match each unit/format to its best use.',
          slots: ['rem', '#ff00aa', '1.5em'],
          correct: {
            'rem': 'scalable spacing from root font',
            '#ff00aa': 'hex color code',
            '1.5em': 'relative to element font',
          },
          pool: [
            'scalable spacing from root font',
            'hex color code',
            'relative to element font',
            'SQL query',
            'React hook',
          ],
          successMessage: 'rem/em for type & spacing; hex/rgb/hsl for colors.',
          failMessage: 'rem = root em, # = hex color, em = local font multiple',
        );

      // HTML
      case 'html-structure':
        return const SlotDragActivity(
          title: 'HTML document structure',
          instructions: 'Order the main sections of a valid HTML page (top → bottom).',
          slots: ['Slot 1', 'Slot 2', 'Slot 3', 'Slot 4'],
          correct: {
            'Slot 1': '<!DOCTYPE html>',
            'Slot 2': '<head>',
            'Slot 3': '<body>',
            'Slot 4': '</html>',
          },
          pool: [
            '<!DOCTYPE html>',
            '<head>',
            '<body>',
            '</html>',
            '<footer only>',
          ],
          ordered: true,
          successMessage: 'DOCTYPE → head (meta, title) → body → close html.',
          failMessage: 'Order: DOCTYPE, head, body, closing html',
        );
      case 'html-semantic':
        return const SlotDragActivity(
          title: 'Semantic tags',
          instructions: 'Match each tag to its meaning.',
          slots: ['<nav>', '<main>', '<article>'],
          correct: {
            '<nav>': 'navigation links',
            '<main>': 'primary page content',
            '<article>': 'self-contained post/section',
          },
          pool: [
            'navigation links',
            'primary page content',
            'self-contained post/section',
            'inline style only',
            'database table',
          ],
          successMessage: 'Semantic tags describe meaning, not just looks.',
          failMessage: 'nav = links, main = core content, article = standalone block',
        );
      case 'html-forms':
        return const SlotDragActivity(
          title: 'Form accessibility',
          instructions: 'Match the pattern to the correct HTML approach.',
          slots: ['label', 'type', 'required'],
          correct: {
            'label': 'for/id links text to input',
            'type': 'email, password, text…',
            'required': 'attribute for validation',
          },
          pool: [
            'for/id links text to input',
            'email, password, text…',
            'attribute for validation',
            'CSS flexbox',
            'Redux action',
          ],
          successMessage: 'Labels + types + attributes make forms usable.',
          failMessage: 'label for=, input type=, required attribute',
        );
      case 'html-media':
        return const SlotDragActivity(
          title: 'Media & accessibility',
          instructions: 'Match the attribute or tag to its purpose.',
          slots: ['alt', '<a href>', 'loading'],
          correct: {
            'alt': 'describe image for screen readers',
            '<a href>': 'hyperlink destination',
            'loading': 'lazy-load images',
          },
          pool: [
            'describe image for screen readers',
            'hyperlink destination',
            'lazy-load images',
            'change font color only',
            'React useState',
          ],
          successMessage: 'alt for a11y, href for links, loading for performance.',
          failMessage: 'alt describes images; href is link target; loading lazy',
        );

      // JavaScript
      case 'js-variables':
        return const SlotDragActivity(
          title: 'Variables in JS',
          instructions: 'Match keyword or concept to its behavior.',
          slots: ['const', 'let', 'typeof'],
          correct: {
            'const': 'cannot reassign binding',
            'let': 'block-scoped variable',
            'typeof': 'returns type string',
          },
          pool: [
            'cannot reassign binding',
            'block-scoped variable',
            'returns type string',
            'CSS selector',
            'HTML tag only',
          ],
          successMessage: 'const for constants, let for reassignable, typeof checks type.',
          failMessage: 'const = no reassignment, let = block scope, typeof = type check',
        );
      case 'js-functions':
        return const SlotDragActivity(
          title: 'Functions',
          instructions: 'Match syntax to its description.',
          slots: ['arrow', 'return', 'params'],
          correct: {
            'arrow': '() => {} concise syntax',
            'return': 'sends value back to caller',
            'params': 'inputs listed in ( )',
          },
          pool: [
            '() => {} concise syntax',
            'sends value back to caller',
            'inputs listed in ( )',
            'margin: auto',
            '<div>',
          ],
          successMessage: 'Functions take params, optionally return values; arrows are shorthand.',
          failMessage: 'arrow = => syntax, return = output, params = inputs',
        );
      case 'js-dom':
        return const SlotDragActivity(
          title: 'DOM APIs',
          instructions: 'Match API call to what it does.',
          slots: ['querySelector', 'textContent', 'classList.add'],
          correct: {
            'querySelector': 'find first matching element',
            'textContent': 'read/write text inside node',
            'classList.add': 'add CSS class name',
          },
          pool: [
            'find first matching element',
            'read/write text inside node',
            'add CSS class name',
            'compile TypeScript',
            'SQL JOIN',
          ],
          successMessage: 'DOM methods let JS read and update the page.',
          failMessage: 'querySelector finds nodes; textContent sets text; classList toggles classes',
        );
      case 'js-events':
        return const SlotDragActivity(
          title: 'Events',
          instructions: 'Match event pattern to description.',
          slots: ['click', 'addEventListener', 'preventDefault'],
          correct: {
            'click': 'user pressed element',
            'addEventListener': 'register handler',
            'preventDefault': 'stop default browser action',
          },
          pool: [
            'user pressed element',
            'register handler',
            'stop default browser action',
            'change CSS flex direction',
            'mount React root',
          ],
          successMessage: 'Events react to users; listeners handle them; preventDefault blocks defaults.',
          failMessage: 'click = interaction, addEventListener = subscribe, preventDefault = block default',
        );
      default:
        return null;
    }
  }
}

class _ComingSoonActivity extends StatelessWidget {
  const _ComingSoonActivity();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'Activity for this unit is not available yet.\n'
          'Choose React, CSS, HTML, or JavaScript from the learning hub.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
        ),
      ),
    );
  }
}
