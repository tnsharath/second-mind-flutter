/// Deterministic daily reflection prompts.
///
/// The prompt for a given date never changes, so users see a consistent
/// question throughout the day and can rely on it for their evening review.
class ReflectionPromptService {
  const ReflectionPromptService._();

  static const List<String> _prompts = [
    'What is one thing you learned today?',
    'What are you grateful for right now?',
    'What felt hard today — and what did it teach you?',
    'What is one small win from today worth remembering?',
    'If you could change one thing about today, what would it be?',
    'What is one thing you want to carry into tomorrow?',
    'Who did you help or connect with today?',
    'What made you lose track of time today?',
    'What is one thing your future self will thank you for?',
    'What would make today feel complete?',
    'What is a belief or assumption you questioned today?',
    'What did you say no to — and why?',
    'What is one thing you want to do less of?',
    'What is one thing you want to do more of?',
  ];

  static String forDate(DateTime date) {
    final local = date.toLocal();
    final daysSinceEpoch = DateTime(local.year, local.month, local.day)
        .millisecondsSinceEpoch ~/
        const Duration(days: 1).inMilliseconds;
    final index = daysSinceEpoch % _prompts.length;
    return _prompts[index];
  }

  static String forToday() => forDate(DateTime.now());
}
