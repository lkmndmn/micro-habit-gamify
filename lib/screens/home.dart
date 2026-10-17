import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';
import 'onboarding.dart';

class HomeScreen extends StatefulWidget {
  final Function(Locale) onLocaleChange;
  final Locale locale;
  HomeScreen({required this.onLocaleChange, required this.locale});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<Task> tasks;
  int points = 0;
  Set<String> badges = {};
  bool _loaded = false;

  Map<String, Map<String, String>> _strings = {
    'en': {
      'title': 'Micro Habit — Demo',
      'points': 'Points',
      'badges': 'Badges',
      'complete': 'Complete',
      'reset': 'Reset',
      'locale': 'Language',
      'onboarding_title': 'Welcome to Micro Habit',
    },
    'tr': {
      'title': 'Mikro Alışkanlık — Demo',
      'points': 'Puan',
      'badges': 'Rozetler',
      'complete': 'Tamamla',
      'reset': 'Sıfırla',
      'locale': 'Dil',
      'onboarding_title': 'Mikro Alışkanlığa Hoşgeldiniz',
    }
  };

  String t(String key) {
    return _strings[widget.locale.languageCode]?[key] ?? key;
  }

  @override
  void initState() {
    super.initState();
    tasks = List.generate(10, (i) {
      return Task(
        id: 't$i',
        title: 'Task ${i + 1}',
        description: 'Complete this micro-task ${i + 1}',
        points: (i % 3) + 1,
      );
    });
    _loadState();
    _checkFirstRun();
  }

  Future<void> _checkFirstRun() async {
    final prefs = await SharedPreferences.getInstance();
    final firstRun = prefs.getBool('first_run') ?? true;
    if (firstRun) {
      // show onboarding then set flag
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => OnboardingScreen(onDone: () async {
          final p = await SharedPreferences.getInstance();
          await p.setBool('first_run', false);
          Navigator.of(context).pop();
        })));
      });
    }
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      points = prefs.getInt('points') ?? 0;
      final badgeList = prefs.getStringList('badges') ?? [];
      badges = badgeList.toSet();
      for (var i = 0; i < tasks.length; i++) {
        tasks[i].completed = prefs.getBool('task_${tasks[i].id}_completed') ?? false;
      }
      _loaded = true;
    });
  }

  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('points', points);
    await prefs.setStringList('badges', badges.toList());
    for (var t in tasks) {
      await prefs.setBool('task_${t.id}_completed', t.completed);
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
    if (points >= 10) badges.add('Getting Started');
    if (points >= 20) badges.add('Committed');
    if (points >= 30) badges.add('Habit Hero');
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${t('points')}: $points', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ElevatedButton(onPressed: resetAll, child: Text(t('reset')))
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
n                          ? Icon(Icons.check_circle, color: Colors.green)
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
              children: badges.isEmpty
                  ? [Chip(label: Text('-'))]
                  : badges.map((b) => Chip(label: Text(b))).toList(),
            ),
            SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
