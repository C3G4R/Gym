class Exercise {
  final String id;
  String name;
  int sets;
  int reps;
  double weight;
  int restSeconds;
  String muscle;
  String note;
  bool completed;
  List<bool> setsDone;
  List<int> loggedReps;
  List<double> loggedWeight;

  Exercise({
    required this.id,
    required this.name,
    required this.sets,
    required this.reps,
    required this.weight,
    required this.restSeconds,
    required this.muscle,
    this.note = '',
    this.completed = false,
    List<bool>? setsDone,
    List<int>? loggedReps,
    List<double>? loggedWeight,
  })  : setsDone = setsDone ?? List.filled(sets, false),
        loggedReps = loggedReps ?? List.filled(sets, 0),
        loggedWeight = loggedWeight ?? List.filled(sets, weight);

  Exercise copyWith({
    String? name,
    int? sets,
    int? reps,
    double? weight,
    int? restSeconds,
    String? muscle,
    String? note,
    bool? completed,
    List<bool>? setsDone,
    List<int>? loggedReps,
    List<double>? loggedWeight,
  }) {
    return Exercise(
      id: id,
      name: name ?? this.name,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      restSeconds: restSeconds ?? this.restSeconds,
      muscle: muscle ?? this.muscle,
      note: note ?? this.note,
      completed: completed ?? this.completed,
      setsDone: setsDone ?? List.from(this.setsDone),
      loggedReps: loggedReps ?? List.from(this.loggedReps),
      loggedWeight: loggedWeight ?? List.from(this.loggedWeight),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'sets': sets,
        'reps': reps,
        'weight': weight,
        'restSeconds': restSeconds,
        'muscle': muscle,
        'note': note,
        'completed': completed,
        'setsDone': setsDone,
        'loggedReps': loggedReps,
        'loggedWeight': loggedWeight,
      };

  factory Exercise.fromJson(Map<String, dynamic> json) => Exercise(
        id: json['id'],
        name: json['name'],
        sets: json['sets'],
        reps: json['reps'],
        weight: (json['weight'] as num).toDouble(),
        restSeconds: json['restSeconds'],
        muscle: json['muscle'],
        note: json['note'] ?? '',
        completed: json['completed'] ?? false,
        setsDone: List<bool>.from(json['setsDone'] ?? []),
        loggedReps: List<int>.from(json['loggedReps'] ?? []),
        loggedWeight:
            (json['loggedWeight'] as List?)?.map((e) => (e as num).toDouble()).toList() ?? [],
      );
}

const List<String> muscleGroups = [
  'Pecho',
  'Espalda',
  'Piernas',
  'Hombros',
  'Bíceps',
  'Tríceps',
  'Abdomen',
  'Glúteos',
  'Cardio',
];

const List<String> weekDays = [
  'Lunes',
  'Martes',
  'Miércoles',
  'Jueves',
  'Viernes',
  'Sábado',
  'Domingo',
];
