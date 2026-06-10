import '../interview_category_constants.dart';
import '../models/interview_question.dart';

InterviewQuestion _ts(int n, String q, String a,
        {String frequency = 'High', String? code, List<String> tags = const []}) =>
    InterviewQuestion(
      id: 'typescript-${n.toString().padLeft(2, '0')}',
      categoryId: InterviewCategories.typescript,
      question: q,
      detailedAnswer: a,
      frequency: frequency,
      tags: tags,
      codeExample: code,
    );

final List<InterviewQuestion> typescriptInterviewQuestions = [
  _ts(1, 'interface vs type — when to use which?',
      'interface: extendable (extends), declaration merging for libs, best for object shapes and public APIs. type: unions, intersections, mapped/conditional types, primitives. Rule of thumb: interface for object contracts; type for unions and advanced type logic.',
      frequency: 'Very High', tags: ['basics']),
  _ts(2, 'What are generics? Give a React example',
      'Generics parameterize types: function identity<T>(x: T): T. Enable reusable components/hooks preserving type safety. React: useState<User>(), useRef<HTMLInputElement>(null), props<T> for generic components.',
      frequency: 'High', tags: ['generics'],
      code: 'function useLocalStorage<T>(key: string, initial: T) {\n  const [value, setValue] = useState<T>(initial);\n  // ...\n  return [value, setValue] as const;\n}'),
  _ts(3, 'Explain utility types (Partial, Pick, Omit, Record)',
      'Partial<T>: all optional. Pick<T,K>: subset keys. Omit<T,K>: exclude keys. Record<K,V>: object with key type K and value V. Also Readonly, Required, ReturnType, Parameters — essential for API DTOs and form drafts.',
      frequency: 'High', tags: ['utility'],
      code: 'type UserUpdate = Partial<Pick<User, "name" | "email">>;'),
  _ts(4, 'What is type narrowing? How do you do it?',
      'Refine broad types to specific ones: typeof, instanceof, in operator, discriminated unions (kind/tag field), custom type predicates (x is Fish). Enables safe access after checks. Exhaustive switch with never for completeness.',
      frequency: 'Medium', tags: ['advanced']),
  _ts(5, 'How do you type React component props?',
      'interface Props { title: string; onSave: (id: string) => void; children?: React.ReactNode; }. Function component: const Card = ({ title }: Props) => .... Extend HTML attrs: ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement>.',
      frequency: 'Very High', tags: ['react + ts'],
      code: 'type Props = { label: string } & React.ComponentProps<"button">;'),
  _ts(6, "What is 'as const' and when to use it?",
      'as const makes literals readonly and narrows to literal types instead of widened string/number. Tuple inference, enum-like objects, route maps. readonly ["a","b"] tuple vs string[].',
      frequency: 'Medium', tags: ['advanced'],
      code: 'const routes = { home: "/", about: "/about" } as const;'),
  _ts(7, 'Explain discriminated unions with example',
      'Union of objects sharing a discriminant field (type/status). Switch on discriminant — TS narrows each branch. Models API success/error, UI states (loading/success/error). Combine with exhaustive checking.',
      frequency: 'High', tags: ['patterns'],
      code: 'type Result =\n  | { status: "ok"; data: User }\n  | { status: "err"; message: string };'),
  _ts(8, 'How to type event handlers in React?',
      'React.ChangeEvent<HTMLInputElement> for inputs, FormEvent for forms, MouseEvent for clicks. Generic: React.EventHandler. Prefer specific element types. With strictNullChecks, check event.target.value.',
      frequency: 'High', tags: ['react + ts'],
      code: 'const onChange = (e: React.ChangeEvent<HTMLInputElement>) => {\n  setName(e.target.value);\n};'),
  _ts(9, "What is the 'unknown' type vs 'any'?",
      'any disables type checking — avoid. unknown is type-safe top type: must narrow before use. Use unknown for API JSON until validated (zod/io-ts). Prefer unknown over any in catch blocks and dynamic data.',
      frequency: 'High', tags: ['basics']),
  _ts(10, 'How do you type an API response?',
      'Define interface matching contract. Validate at runtime with zod/schema. Use generics on fetch wrapper: api.get<User[]>("/users"). Handle error union. Do not trust raw JSON without validation in production.',
      frequency: 'High', tags: ['practical'],
      code:
          'async function getUser(id: string): Promise<User> {\n'
          '  const res = await fetch("/api/users/" + id);\n'
          '  if (!res.ok) throw new Error("Failed");\n'
          '  return res.json() as Promise<User>;\n'
          '}'),
];
