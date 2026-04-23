import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/exercise.dart';

class WorkoutProvider extends ChangeNotifier {
  Map<int, List<Exercise>> _exercises = {};
  Set<int> _completedDays = {};
  int _streak = 0;
  String? _lastDoneDate;
  int _currentDay = 0;

  int get currentDay => _currentDay;
  int get streak => _streak;
  Set<int> get completedDays => _completedDays;

  List<Exercise> get currentExercises => _exercises[_currentDay] ?? [];

  double get todayProgress {
    final exs = currentExercises;
    if (exs.isEmpty) return 0;
    return exs.where((e) => e.completed).length / exs.length;
  }

  int get completedCount => currentExercises.where((e) => e.completed).length;

  WorkoutProvider() {
    _currentDay = (DateTime.now().weekday - 1) % 7;
    load();
  }

  void switchDay(int day) {
    _currentDay = day;
    notifyListeners();
  }

  void addExercise(Exercise ex) {
    _exercises[_currentDay] ??= [];
    _exercises[_currentDay]!.add(ex);
    save();
    notifyListeners();
  }

  void deleteExercise(String id) {
    _exercises[_currentDay]?.removeWhere((e) => e.id == id);
    save();
    notifyListeners();
  }

  void toggleComplete(String id) {
    final list = _exercises[_currentDay];
    if (list == null) return;
    final idx = list.indexWhere((e) => e.id == id);
    if (idx == -1) return;
    list[idx] = list[idx].copyWith(completed: !list[idx].completed);
    save();
    notifyListeners();
  }

  void completeSet(String id, int setIdx) {
    final list = _exercises[_currentDay];
    if (list == null) return;
    final idx = list.indexWhere((e) => e.id == id);
    if (idx == -1) return;
    final ex = list[idx];
    final newSetsDone = List<bool>.from(ex.setsDone);
    newSetsDone[setIdx] = true;
    final allDone = newSetsDone.every((s) => s);
    list[idx] = ex.copyWith(
      setsDone: newSetsDone,
      completed: allDone ? true : ex.completed,
    );
    save();
    notifyListeners();
  }

  void logSet(String id, int setIdx, {int? reps, double? weight}) {
    final list = _exercises[_currentDay];
    if (list == null) return;
    final idx = list.indexWhere((e) => e.id == id);
    if (idx == -1) return;
    final ex = list[idx];
    final newReps = List<int>.from(ex.loggedReps);
    final newWeight = List<double>.from(ex.loggedWeight);
    if (reps != null) newReps[setIdx] = reps;
    if (weight != null) newWeight[setIdx] = weight;
    list[idx] = ex.copyWith(loggedReps: newReps, loggedWeight: newWeight);
    save();
    notifyListeners();
  }

  void markDayDone() {
    _completedDays.add(_currentDay);
    final today = DateTime.now().toIso8601String().substring(0, 10);
    if (_lastDoneDate != today) {
      _streak++;
      _lastDoneDate = today;
    }
    save();
    notifyListeners();
  }

  void clearDay() {
    _exercises[_currentDay] = [];
    _completedDays.remove(_currentDay);
    save();
    notifyListeners();
  }

  void copyDayTo(int targetDay) {
    final src = _exercises[_currentDay] ?? [];
    final copies = src.map((e) => e.copyWith(
          completed: false,
          setsDone: List.filled(e.sets, false),
          loggedReps: List.filled(e.sets, 0),
          loggedWeight: List.filled(e.sets, e.weight),
        )).toList();
    _exercises[targetDay] ??= [];
    _exercises[targetDay]!.addAll(copies);
    save();
    notifyListeners();
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    final map = _exercises.map(
      (k, v) => MapEntry(k.toString(), v.map((e) => e.toJson()).toList()),
    );
    await prefs.setString('exercises', jsonEncode(map));
    await prefs.setStringList(
        'completedDays', _completedDays.map((e) => e.toString()).toList());
    await prefs.setInt('streak', _streak);
    if (_lastDoneDate != null) {
      await prefs.setString('lastDone', _lastDoneDate!);
    }
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('exercises');
    if (raw != null) {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      _exercises = map.map((k, v) => MapEntry(
            int.parse(k),
            (v as List).map((e) => Exercise.fromJson(e)).toList(),
          ));
    }
    final cd = prefs.getStringList('completedDays') ?? [];
    _completedDays = cd.map(int.parse).toSet();
    _streak = prefs.getInt('streak') ?? 0;
    _lastDoneDate = prefs.getString('lastDone');
    notifyListeners();
  }
}
