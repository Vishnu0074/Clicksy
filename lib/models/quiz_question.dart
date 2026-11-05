class QuizOption {
  const QuizOption({required this.id, required this.label, required this.emoji});
  final String id;
  final String label;
  final String emoji;
}

class QuizQuestion {
  const QuizQuestion({
    required this.id,
    required this.category,
    required this.question,
    required this.illustration,
    required this.options,
    required this.correctOptionId,
    this.explanation,
  });
  final String id;
  final String category;
  final String question;
  final String illustration;
  final List<QuizOption> options;
  final String correctOptionId;
  final String? explanation;
}
