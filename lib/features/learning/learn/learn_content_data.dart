import 'package:flutter/material.dart';

/// Rich Learn-tab content per unit (text, voice script, diagram steps).
class LearnConceptContent {
  const LearnConceptContent({
    required this.title,
    required this.icon,
    required this.bullets,
    required this.summary,
    required this.voiceScript,
    required this.diagramSteps,
  });

  final String title;
  final IconData icon;
  final List<String> bullets;
  final String summary;
  final String voiceScript;
  final List<String> diagramSteps;
}

LearnConceptContent learnContentFor(String unitId) {
  return _content[unitId] ?? _genericFor(unitId);
}

LearnConceptContent _genericFor(String unitId) {
  if (unitId.startsWith('css-')) {
    return LearnConceptContent(
      title: 'CSS — ${_titleFromId(unitId)}',
      icon: Icons.palette_rounded,
      bullets: const [
        'CSS controls layout, color, spacing, and typography.',
        'Use the animated diagram to see how properties apply.',
        'Practice matching terms in the Activity tab.',
      ],
      summary:
          'Cascading Style Sheets describe presentation. Selectors target elements; '
          'the box model, flexbox, and grid handle layout; units and colors set size and theme.',
      voiceScript:
          'This CSS lesson uses a diagram to show how rules apply to elements. '
          'Read each bullet, replay the animation, then try the drag and drop activity.',
      diagramSteps: const ['Rule', 'Selector', 'Applied style'],
    );
  }
  if (unitId.startsWith('html-')) {
    return LearnConceptContent(
      title: 'HTML — ${_titleFromId(unitId)}',
      icon: Icons.code_rounded,
      bullets: const [
        'HTML defines structure and meaning, not visual design.',
        'Semantic tags help screen readers and search engines.',
        'Forms and media need accessible attributes.',
      ],
      summary:
          'HyperText Markup Language builds the skeleton of a page: headings, sections, '
          'links, forms, and images with meaningful tags.',
      voiceScript:
          'HTML is the structure layer of the web. Follow the diagram steps, '
          'then practice in the Activity tab with drag and drop.',
      diagramSteps: const ['Element', 'Content', 'Browser tree'],
    );
  }
  if (unitId.startsWith('js-')) {
    return LearnConceptContent(
      title: 'JavaScript — ${_titleFromId(unitId)}',
      icon: Icons.javascript_rounded,
      bullets: const [
        'JavaScript adds interactivity in the browser.',
        'Variables store data; functions organize logic.',
        'The DOM and events connect code to the page.',
      ],
      summary:
          'JavaScript runs in the browser to respond to users, update the DOM, '
          'and coordinate data with HTML and CSS.',
      voiceScript:
          'This JavaScript topic explains behavior on the page. '
          'Watch the diagram, listen again if needed, then quiz yourself.',
      diagramSteps: const ['Script', 'DOM', 'User event'],
    );
  }
  return const LearnConceptContent(
    title: 'Concept overview',
    icon: Icons.auto_awesome_rounded,
    bullets: [
      'Read the animated diagram above.',
      'Complete the Activity tab for hands-on practice.',
      'Pass the quiz (≥ 70%) to mark progress.',
    ],
    summary: 'Explore this unit step by step.',
    voiceScript: 'Review the diagram and bullets, then practice in the Activity tab.',
    diagramSteps: ['Concept', 'Practice', 'Quiz'],
  );
}

String _titleFromId(String unitId) {
  final part = unitId.split('-').skip(1).join(' ');
  if (part.isEmpty) return unitId;
  return part[0].toUpperCase() + part.substring(1);
}

final Map<String, LearnConceptContent> _content = {
  'react-components': LearnConceptContent(
    title: 'Components — building blocks',
    icon: Icons.view_module_rounded,
    bullets: [
      'A component is a reusable piece of UI (like LEGO bricks).',
      'Parents wrap children: <Page> contains <Header />, <Content />, etc.',
      'Small components combine into full screens.',
      'Function components return JSX; one file can export many components.',
    ],
    summary:
        'React apps are trees of components. Each component encapsulates markup and logic. '
        'Splitting UI into Header, Card, and List keeps code maintainable and testable.',
    voiceScript:
        'Components are reusable UI pieces. A parent component renders child components inside its JSX. '
        'You combine small components to build full screens. '
        'Next, open the Activity tab to assemble a layout with drag and drop.',
    diagramSteps: ['Parent', 'Child A', 'Child B', 'Composed UI'],
  ),
  'react-props': LearnConceptContent(
    title: 'Props — data from parent to child',
    icon: Icons.call_received_rounded,
    bullets: [
      'Props are read-only inputs passed downward.',
      'The parent owns the data; the child displays it.',
      'Changing props in the parent re-renders the child with new values.',
      'Pass strings, numbers, objects, or callback functions as props.',
      'Destructure props in the child: function Card({ title }) { ... }',
    ],
    summary:
        'Props configure children without hard-coding values inside them. '
        'Think of props as function arguments for your UI: the parent calls <UserCard name="Ada" />.',
    voiceScript:
        'Props are read-only inputs from parent to child. '
        'The parent owns the data and passes it down. When props change, React re-renders the child. '
        'Practice passing name, role, and isActive in the Activity tab.',
    diagramSteps: ['Parent holds data', 'props flow down', 'Child renders'],
  ),
  'react-state': LearnConceptContent(
    title: 'State — data that changes over time',
    icon: Icons.memory_rounded,
    bullets: [
      'State lives inside a component (e.g. useState).',
      'When state updates, React re-renders that component.',
      'State is private — other components cannot mutate it directly.',
      'Do not confuse state with props: props come from outside.',
    ],
    summary:
        'State tracks values that change due to user input or timers. '
        'Calling the setter schedules an update and a fresh render.',
    voiceScript:
        'State is data that changes inside a component. useState gives you a value and a setter. '
        'When you update state, React re-renders. Try the Activity to match state terms.',
    diagramSteps: ['useState', 'setState()', 'Re-render'],
  ),
  'react-hooks': LearnConceptContent(
    title: 'Hooks — power-ups for function components',
    icon: Icons.electrical_services_rounded,
    bullets: [
      'Hooks let you use state and effects without class components.',
      'useState, useEffect, and custom hooks share reusable logic.',
      'Rules: only call hooks at the top level of a component.',
      'Custom hooks must start with use, like useAuth.',
    ],
    summary:
        'Hooks connect function components to React features. '
        'They replaced much of the old class lifecycle pattern.',
    voiceScript:
        'Hooks add state and side effects to function components. '
        'Always call hooks at the top level, never inside conditions or loops. '
        'Custom hooks start with use.',
    diagramSteps: ['useState', 'useEffect', 'Custom useX'],
  ),
  'react-useeffect': LearnConceptContent(
    title: 'useEffect — side effects after render',
    icon: Icons.schedule_rounded,
    bullets: [
      'Runs after paint — fetch data, subscriptions, DOM sync.',
      'Return a cleanup function to run on unmount or before re-run.',
      'Dependency array controls when the effect re-fires.',
      'Empty deps [] runs once on mount (like componentDidMount).',
    ],
    summary:
        'Effects bridge React with the outside world: APIs, timers, listeners. '
        'Cleanup prevents memory leaks.',
    voiceScript:
        'useEffect runs after render for side effects like fetching data. '
        'Return a cleanup function for subscriptions. '
        'The dependency array tells React when to re-run the effect.',
    diagramSteps: ['Render', 'Effect runs', 'Cleanup'],
  ),
  'react-context': LearnConceptContent(
    title: 'Context — share data without prop drilling',
    icon: Icons.account_tree_rounded,
    bullets: [
      'Provider wraps a subtree; consumers read the same value.',
      'Avoid passing props through every intermediate layer.',
      'Great for theme, auth user, locale — not every piece of state.',
      'useContext reads the nearest Provider value.',
    ],
    summary:
        'Context shares one value with many descendants. '
        'Use it when many components need the same data.',
    voiceScript:
        'Context lets you share data without passing props through every level. '
        'Wrap with Provider and read with useContext. Best for theme and user session.',
    diagramSteps: ['Provider', 'value', 'Consumer'],
  ),
  'react-redux': LearnConceptContent(
    title: 'Redux — predictable global store',
    icon: Icons.hub_rounded,
    bullets: [
      'UI dispatches actions describing what happened.',
      'Reducers compute the next state immutably.',
      'Store holds one source of truth; subscribers re-render.',
      'Use for large apps with shared state across many screens.',
    ],
    summary:
        'Redux centralizes state updates in a single store with a clear flow: '
        'dispatch action → reducer → new state → UI updates.',
    voiceScript:
        'Redux keeps global state in one store. Components dispatch actions. '
        'Reducers return new state without mutation. Practice the flow in Activity.',
    diagramSteps: ['dispatch', 'reducer', 'new state'],
  ),
  'css-selectors': LearnConceptContent(
    title: 'Selectors — target the right elements',
    icon: Icons.filter_list_rounded,
    bullets: [
      '.class targets class attribute',
      '#id targets one unique id',
      'div p selects p descendants inside div',
      'Specificity decides which rule wins',
    ],
    summary: 'Selectors connect CSS rules to HTML elements.',
    voiceScript: 'Class selectors use a dot. ID uses hash. Descendant uses a space between tags.',
    diagramSteps: ['.class', '#id', 'div p'],
  ),
  'css-box-model': LearnConceptContent(
    title: 'Box model — margin, border, padding, content',
    icon: Icons.crop_square_rounded,
    bullets: [
      'Every element is a box with four layers.',
      'margin = space outside border',
      'padding = space inside border around content',
      'box-sizing: border-box includes padding in width',
    ],
    summary: 'Layout math starts with the box model.',
    voiceScript: 'From outside in: margin, border, padding, then content. Watch the nested boxes animate.',
    diagramSteps: ['margin', 'border', 'padding', 'content'],
  ),
  'css-flexbox': LearnConceptContent(
    title: 'Flexbox — one-dimensional layout',
    icon: Icons.view_week_rounded,
    bullets: [
      'display: flex on a container',
      'justify-content aligns on main axis',
      'align-items aligns on cross axis',
      'flex-direction: row or column',
    ],
    summary: 'Flexbox lines items along one axis at a time.',
    voiceScript: 'Flexbox lays out items in a row or column. Adjust justify and align in the Activity preview.',
    diagramSteps: ['flex container', 'main axis', 'items'],
  ),
  'css-grid': LearnConceptContent(
    title: 'Grid — rows and columns together',
    icon: Icons.grid_on_rounded,
    bullets: [
      'display: grid defines a grid container',
      'grid-template-columns and rows define tracks',
      'gap adds space between cells',
      'Use for dashboards and page layouts',
    ],
    summary: 'Grid handles two-dimensional layouts.',
    voiceScript: 'CSS Grid places items in rows and columns. Ideal for full page layouts.',
    diagramSteps: ['columns', 'rows', 'cells'],
  ),
  'css-colors': LearnConceptContent(
    title: 'Colors & units — rem, em, hex',
    icon: Icons.color_lens_rounded,
    bullets: [
      'hex, rgb(), hsl() set colors',
      'rem scales from root font size',
      'em scales from element font size',
      '% is relative to parent',
    ],
    summary: 'Consistent units and color formats keep design scalable.',
    voiceScript: 'Use rem for spacing and type. Hex and hsl for colors. Match units in Activity.',
    diagramSteps: ['#hex', 'rem', 'em'],
  ),
  'html-structure': LearnConceptContent(
    title: 'Document structure — valid page skeleton',
    icon: Icons.article_rounded,
    bullets: [
      '<!DOCTYPE html> declares HTML5',
      '<head> holds meta, title, links',
      '<body> holds visible content',
      'Close tags in proper order',
    ],
    summary: 'A valid document helps browsers and assistive tech.',
    voiceScript: 'Start with DOCTYPE, then head for metadata, body for content, close html last.',
    diagramSteps: ['DOCTYPE', 'head', 'body'],
  ),
  'html-semantic': LearnConceptContent(
    title: 'Semantic HTML — meaning, not just looks',
    icon: Icons.account_tree_outlined,
    bullets: [
      '<header>, <footer> for page regions',
      '<nav> for navigation',
      '<main> for primary content once per page',
      '<article> for self-contained blocks',
    ],
    summary: 'Semantic tags describe purpose, improving SEO and a11y.',
    voiceScript: 'Semantic tags tell browsers and screen readers what each region means.',
    diagramSteps: ['header', 'nav', 'main', 'footer'],
  ),
  'html-forms': LearnConceptContent(
    title: 'Forms — inputs users can submit',
    icon: Icons.edit_note_rounded,
    bullets: [
      '<label for="id"> links to <input id="id">',
      'type controls keyboard and validation',
      'required, min, max are validation attrs',
      '<button type="submit"> sends the form',
    ],
    summary: 'Accessible forms pair labels with inputs and clear types.',
    voiceScript: 'Always label inputs. Use correct types like email. Add required when needed.',
    diagramSteps: ['label', 'input', 'submit'],
  ),
  'html-media': LearnConceptContent(
    title: 'Media & links — images and anchors',
    icon: Icons.perm_media_rounded,
    bullets: [
      '<img src alt> — alt is required for accessibility',
      '<a href> creates hyperlinks',
      'loading="lazy" defers off-screen images',
      'Use descriptive link text, not click here',
    ],
    summary: 'Media tags need alt text and meaningful hrefs.',
    voiceScript: 'Images need alt text. Links need clear href and link text.',
    diagramSteps: ['img + alt', 'a href', 'lazy load'],
  ),
  'js-variables': LearnConceptContent(
    title: 'Variables — let, const, types',
    icon: Icons.data_object_rounded,
    bullets: [
      'const for values that will not be reassigned',
      'let for block-scoped reassignable bindings',
      'typeof returns a string type name',
      'Avoid var in modern code',
    ],
    summary: 'Choose const by default; let when you need to reassign.',
    voiceScript: 'Use const unless you need to reassign, then let. typeof checks types.',
    diagramSteps: ['const', 'let', 'typeof'],
  ),
  'js-functions': LearnConceptContent(
    title: 'Functions — reusable logic',
    icon: Icons.functions_rounded,
    bullets: [
      'Functions take parameters and may return values',
      'Arrow syntax: const add = (a, b) => a + b',
      'Callbacks are functions passed as arguments',
    ],
    summary: 'Functions group steps you can call by name.',
    voiceScript: 'Functions accept inputs and return outputs. Arrows are shorter syntax.',
    diagramSteps: ['params', 'body', 'return'],
  ),
  'js-dom': LearnConceptContent(
    title: 'DOM — live page tree in memory',
    icon: Icons.account_tree_rounded,
    bullets: [
      'document.querySelector finds elements',
      'textContent reads/writes text',
      'classList.add toggles CSS classes',
      'Changes update what users see',
    ],
    summary: 'The DOM is how JavaScript reads and updates the page.',
    voiceScript: 'Query elements, change text or classes, and the page updates instantly.',
    diagramSteps: ['document', 'node', 'update UI'],
  ),
  'js-events': LearnConceptContent(
    title: 'Events — respond to users',
    icon: Icons.touch_app_rounded,
    bullets: [
      'click, input, submit are common events',
      'addEventListener registers handlers',
      'preventDefault stops default browser behavior',
      'Event object carries details (target, key, etc.)',
    ],
    summary: 'Events connect user actions to your code.',
    voiceScript: 'Listen for clicks and input. preventDefault blocks defaults like form submit.',
    diagramSteps: ['user action', 'listener', 'handler'],
  ),
};
