import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/app_strings.dart';
import 'models/task.dart';
import 'screens/onboarding.dart';
import 'widgets/badge_widget.dart';

class HomeScreen extends StatefulWidget {
  final Function(Locale) onLocaleChange;
  final Locale locale;

  HomeScreen({required this.onLocaleChange, required this.locale});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late List<Task> tasks;
  int points = 0;
  Set<String> badges = {};
  bool _loaded = false;

  late AnimationController _pulseController;
  late Box _box;

  String t(String key) {
    return AppStrings.strings[widget.locale.languageCode]?[key] ?? AppStrings.strings['en']![key]!;
  }

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: Duration(seconds: 2))..repeat(reverse: true);
    tasks = List.generate(10, (i) {
      return Task(
        id: 't$i',
        title: t('task_${i + 1}'),
        description: 'Complete this micro-task ${i + 1}',
        points: (i % 3) + 1,
      );
    });
    _loadState();
    _checkFirstRun();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _checkFirstRun() async {
    _box = Hive.box('appBox');
    final hasSeenOnboarding = _box.get('seen_onboarding', defaultValue: false) as bool;
    if (!hasSeenOnboarding) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => OnboardingScreen(onDone: () async {
          await _box.put('seen_onboarding', true);
          Navigator.of(context).pop();
        })));
      });
    }
  }

  Future<void> _loadState() async {
    _box = Hive.box('appBox');
    setState(() {
      points = _box.get('points', defaultValue: 0) as int;
      final badgeList = (_box.get('badges', defaultValue: []) as List).cast<String>();
      badges = badgeList.toSet();
      for (var i = 0; i < tasks.length; i++) {
        tasks[i].completed = _box.get('task_${tasks[i].id}_completed', defaultValue: false) as bool;
      }
      _loaded = true;
    });
  }

  Future<void> _saveState() async {
    await _box.put('points', points);
    await _box.put('badges', badges.toList());
    for (var t in tasks) {
      await _box.put('task_${t.id}_completed', t.completed);
    }
  }

  void toggleTask(Task task) {
    setState(() {
      if (!task.completed) {
        task.completed = true;
        points += task.points;
        checkBadges();
        _saveState();
      }
    });
  }

  void resetAll() {
    setState(() {
      for (var t in tasks) {
        t.completed = false;
      }
      points = 0;
      badges.clear();
      _saveState();
    });
  }

  void checkBadges() {
    final before = badges.length;
    if (points >= 10) badges.add('Getting Started');
    if (points >= 20) badges.add('Committed');
    if (points >= 30) badges.add('Habit Hero');
    if (badges.length > before) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(t('new_badge')),
            content: Text(t('nice_work')),
            actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('OK'))],
          ),
        );
      });
    }
  }

  int pointsToNextBadge() {
    if (points < 10) return 10 - points;
    if (points < 20) return 20 - points;
    if (points < 30) return 30 - points;
    return 0;
  }

  double progressToNextBadge() {
    if (points < 10) return points / 10.0;
    if (points < 20) return (points - 10) / 10.0;
    if (points < 30) return (points - 20) / 10.0;
    return 1.0;
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(t('title')),
        actions: [
          PopupMenuButton<Locale>(
            onSelected: (loc) => widget.onLocaleChange(loc),
            itemBuilder: (ctx) => [
              PopupMenuItem(value: Locale('en'), child: Text('English')),
              PopupMenuItem(value: Locale('tr'), child: Text('Türkçe')),
              PopupMenuItem(value: Locale('es'), child: Text('Español')),
              PopupMenuItem(value: Locale('fr'), child: Text('Français')),
            ],
            icon: Icon(Icons.language),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${t('points')}: $points', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      LinearProgressIndicator(value: progressToNextBadge()),
                      SizedBox(height: 6),
                      Text('${t('next_badge')}: ${pointsToNextBadge()} pts')
                    ],
                  ),
                ),
                SizedBox(width: 12),
                ScaleTransition(
                  scale: Tween(begin: 0.95, end: 1.05).animate(_pulseController),
                  child: CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.teal,
                    child: Icon(Icons.emoji_events, color: Colors.white, size: 32),
                  ),
                )
              ],
            ),
            SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (ctx, idx) {
                  final task = tasks[idx];
                  return Card(
                    child: ListTile(
                      title: Text(task.title),
                      subtitle: Text(task.description),
                      trailing: task.completed
                          ? Icon(Icons.check_circle, color: Colors.green)
                          : ElevatedButton(
                              onPressed: () => toggleTask(task),
                              child: Text(t('complete')),
                            ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(t('badges') + ':', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                BadgeWidget(title: 'Getting Started', unlocked: badges.contains('Getting Started'), icon: Icons.star),
                BadgeWidget(title: 'Committed', unlocked: badges.contains('Committed'), icon: Icons.flag),
                BadgeWidget(title: 'Habit Hero', unlocked: badges.contains('Habit Hero'), icon: Icons.verified),
              ],
            ),
            SizedBox(height: 12),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: resetAll,
        tooltip: t('reset'),
        child: Icon(Icons.refresh),
      ),
    );
  }
}
