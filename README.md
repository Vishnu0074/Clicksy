# Clicksy

A playful computer-knowledge quiz game for little learners, built with Flutter for the web.

## Run locally

```bash
flutter config --enable-web
flutter pub get
flutter run -d chrome
```

Build with `flutter build web --release`; output is in `build/web`.

## Edit questions

All quiz content is in `lib/data/quiz_questions.dart`. Add, remove, or edit a `QuizQuestion` there. Each question contains its category, prompt, emoji illustration, options, correct option ID, and optional explanation. The UI renders the list automatically.

## Gameplay

- One question per screen.
- Wrong answers get gentle feedback and can be retried.
- Correct answers are highlighted; score and streak update and confetti plays.
- Next unlocks only after a correct answer.
- Results screen shows the final score and offers replay.

The starter version uses Flutter's built-in widgets and animations, with no third-party runtime dependencies.
