# Clicksy

**Clicksy** is a playful computer-knowledge quiz game for young learners and beginners, built with Flutter for the web.

🎮 **Play:** https://vishnu0074.github.io/Clicksy/

## About
Clicksy makes practising computer basics approachable through short quiz questions, friendly feedback, score tracking and streaks.

## Features
- One question per screen.
- Wrong answers receive gentle feedback and can be retried.
- Correct answers are highlighted.
- Score and streak update as learners progress.
- The next question unlocks after a correct answer.
- Results screen with a replay option.

## Run locally
```bash
flutter config --enable-web
flutter pub get
flutter run -d chrome
```

Build with `flutter build web --release`; output is in `build/web`.

## Edit questions
Quiz content is maintained in `lib/data/quiz_questions.dart`. Each question contains its category, prompt, emoji illustration, options, correct option ID, and optional explanation.

## Technology
- Flutter / Dart
- Flutter Web
- No third-party runtime dependencies in the starter version

## SEO and discovery
The published site includes descriptive page metadata, Open Graph and social sharing tags, structured data, a sitemap, robots.txt and an AI-readable project summary.

- Website: https://vishnu0074.github.io/Clicksy/
- Source: https://github.com/Vishnu0074/Clicksy
- AI/search reference: https://vishnu0074.github.io/Clicksy/llms.txt

## License
See the repository for licensing information.
