import '../interview_category_constants.dart';
import '../models/interview_question.dart';

InterviewQuestion _mc(int n, String q, String a,
        {String frequency = 'High', String? code, List<String> tags = const []}) =>
    InterviewQuestion(
      id: 'machine_coding-${n.toString().padLeft(2, '0')}',
      categoryId: InterviewCategories.machineCoding,
      question: q,
      detailedAnswer: a,
      frequency: frequency,
      tags: tags,
      codeExample: code,
    );

final List<InterviewQuestion> machineCodingInterviewQuestions = [
  _mc(1, 'Build a Todo app',
      'Plan in 5 minutes: TodoList state (id, text, done), TodoItem component, add/toggle/delete handlers. Use controlled input, filter tabs (all/active/done), empty state. Edge cases: empty submit, duplicate text, keyboard Enter. Style minimally after logic works. Time: 45–60 min.',
      frequency: '45-60 min', tags: ['react', 'state'],
      code: 'const [todos, setTodos] = useState([]);\nconst add = text => setTodos(t => [...t, { id: crypto.randomUUID(), text, done: false }]);'),
  _mc(2, 'Build an autocomplete/typeahead',
      'Debounce input (300ms), fetch suggestions API, show dropdown with keyboard nav (arrows, Enter, Escape). Highlight match, handle loading/error/empty, click outside to close. Accessibility: aria-expanded, listbox role. Core skill: debounce + async race conditions (abort controller).',
      frequency: '45-60 min', tags: ['debounce', 'api']),
  _mc(3, 'Build a star rating component',
      'Props: maxStars, value, onChange, readOnly. Hover preview vs committed value. Support half stars optionally. Keyboard: arrow keys. Reusable controlled component — parent owns state. Test edge cases: 0 stars, disabled mode.',
      frequency: '30-45 min', tags: ['component design']),
  _mc(4, 'Build a carousel/slider',
      'Track active index, prev/next buttons, optional dots, wrap or clamp ends. Touch swipe optional. Auto-play with pause on hover. Avoid layout shift — fixed width slides. Edge: single item, empty list, infinite loop duplicate slides trick.',
      frequency: '45-60 min', tags: ['dom', 'state']),
  _mc(5, 'Build a modal with portal',
      'ReactDOM.createPortal to document.body. Focus trap, Escape to close, click backdrop to close, aria-modal and role=dialog. Lock body scroll. Return focus to trigger on close. Reusable Modal component with children slot.',
      frequency: '30-45 min', tags: ['portal', 'a11y']),
  _mc(6, 'Build a data table with sort/filter',
      'Column defs (key, label, sortable), sort state (key, direction), filter input per column or global search. Memoize sorted/filtered rows. Pagination for large data. Performance: virtualize if 1000+ rows. Empty and loading states.',
      frequency: '60 min', tags: ['performance', 'state']),
  _mc(7, 'Build infinite scroll',
      'IntersectionObserver on sentinel element at list bottom. Append page on intersect, guard duplicate fetches with loading flag. Show spinner and end-of-list message. Reset on filter change. Alternative: cursor-based API pagination.',
      frequency: '45 min', tags: ['intersection observer'],
      code: 'useEffect(() => {\n  const io = new IntersectionObserver(([e]) => {\n    if (e.isIntersecting) loadMore();\n  });\n  io.observe(sentinelRef.current);\n  return () => io.disconnect();\n}, []);'),
  _mc(8, 'Build a file explorer (tree view)',
      'Recursive TreeNode component for nested folders/files. Expand/collapse state per folder id. Icons for file types. Optional lazy-load children. Keyboard: arrows to navigate. State: Set of expanded ids or nested data mutation.',
      frequency: '45-60 min', tags: ['recursion', 'composition']),
  _mc(9, 'Build a multi-step form',
      'Steps array with validation per step. Local state or useReducer for form data. Next validates current step only; Back preserves data. Progress indicator. Submit on final step. Disable Next until valid. Summary review step optional.',
      frequency: '45-60 min', tags: ['forms', 'validation']),
  _mc(10, 'Implement drag and drop',
      'HTML5 drag events (dragstart, dragover, drop) or pointer events for custom UX. Visual feedback: ghost element, drop zones highlight. Reorder list: track dragIndex, dropIndex, immutably splice array. Touch support harder — mention library (dnd-kit) if time short.',
      frequency: '60 min', tags: ['events', 'ui feedback']),
];
