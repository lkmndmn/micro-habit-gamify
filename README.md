# Micro Habit Gamify

Minimal starter Flutter app for a micro-habit, gamified demo.

This repo contains a small Flutter scaffold with a home screen that shows 10 example micro-tasks, allows marking them complete, keeps local points and awards simple badges. It includes a minimal EN/TR i18n stub and a short 2-week roadmap in the README.

Run
```
flutter pub get
flutter run
```

What you'll find:
- lib/main.dart: entry point and simple localization toggle
- lib/screens/home.dart: the demo UI with tasks, scoring and badges (now persisted locally with SharedPreferences)
- lib/screens/onboarding.dart: simple onboarding pages
- lib/models/task.dart: Task model

Roadmap (short): see ROADMAP.md

License: MIT
