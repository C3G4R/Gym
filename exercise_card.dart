import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/exercise.dart';
import '../models/workout_provider.dart';
import '../theme/app_theme.dart';

class ExerciseCard extends StatefulWidget {
  final Exercise exercise;
  final int index;
  final void Function(int seconds) onRestStart;

  const ExerciseCard({
    super.key,
    required this.exercise,
    required this.index,
    required this.onRestStart,
  });

  @override
  State<ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends State<ExerciseCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final ex = widget.exercise;
    final provider = context.read<WorkoutProvider>();

    return AnimatedContainer(
      duration: 300.ms,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: ex.completed ? AppTheme.accent : AppTheme.border,
          width: ex.completed ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          // Header
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Complete button
                  GestureDetector(
                    onTap: () => provider.toggleComplete(ex.id),
                    child: AnimatedContainer(
                      duration: 200.ms,
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: ex.completed ? AppTheme.accent : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: ex.completed ? AppTheme.accent : AppTheme.textMuted,
                          width: 1.5,
                        ),
                      ),
                      child: ex.completed
                          ? const Icon(Icons.check_rounded,
                              color: Colors.black, size: 18)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ex.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: ex.completed
                                ? AppTheme.textMuted
                                : AppTheme.textPrimary,
                            decoration: ex.completed
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.accent.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: AppTheme.accent.withOpacity(0.4)),
                          ),
                          child: Text(
                            ex.muscle.toUpperCase(),
                            style: const TextStyle(
                              color: AppTheme.accent,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Stats pills
                  Row(
                    children: [
                      _pill('${ex.sets}×${ex.reps}'),
                      const SizedBox(width: 6),
                      _pill(ex.weight > 0 ? '${ex.weight}kg' : 'BW'),
                    ],
                  ),
                  const SizedBox(width: 8),
                  // Expand icon
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: 200.ms,
                    child: const Icon(Icons.keyboard_arrow_down_rounded,
                        color: AppTheme.textMuted, size: 20),
                  ),
                ],
              ),
            ),
          ),

          // Expanded sets
          AnimatedSize(
            duration: 300.ms,
            curve: Curves.easeInOut,
            child: _expanded
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(color: AppTheme.border, height: 1),
                        const SizedBox(height: 12),
                        if (ex.note.isNotEmpty) ...[
                          Row(
                            children: [
                              Container(
                                width: 3,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: AppTheme.accent.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  ex.note,
                                  style: const TextStyle(
                                    color: AppTheme.textMuted,
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                        ],
                        // Sets header
                        Row(
                          children: [
                            const SizedBox(width: 28),
                            _setHeader('SERIE'),
                            _setHeader('REPS'),
                            _setHeader('KG'),
                            const Spacer(),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ...List.generate(
                          ex.sets,
                          (s) => _SetRow(
                            exercise: ex,
                            setIndex: s,
                            onComplete: () {
                              provider.completeSet(ex.id, s);
                              final allDone = ex.setsDone
                                  .asMap()
                                  .entries
                                  .where((e) => e.key != s)
                                  .every((e) => e.value);
                              if (!allDone) {
                                widget.onRestStart(ex.restSeconds);
                              }
                            },
                            onLogReps: (v) =>
                                provider.logSet(ex.id, s, reps: v),
                            onLogWeight: (v) =>
                                provider.logSet(ex.id, s, weight: v),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Delete button
                        GestureDetector(
                          onTap: () => provider.deleteExercise(ex.id),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.delete_outline_rounded,
                                  color: AppTheme.accentRed, size: 16),
                              SizedBox(width: 4),
                              Text(
                                'Eliminar ejercicio',
                                style: TextStyle(
                                  color: AppTheme.accentRed,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _pill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.border),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppTheme.textPrimary,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _setHeader(String text) {
    return Expanded(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AppTheme.textMuted,
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _SetRow extends StatelessWidget {
  final Exercise exercise;
  final int setIndex;
  final VoidCallback onComplete;
  final void Function(int) onLogReps;
  final void Function(double) onLogWeight;

  const _SetRow({
    required this.exercise,
    required this.setIndex,
    required this.onComplete,
    required this.onLogReps,
    required this.onLogWeight,
  });

  @override
  Widget build(BuildContext context) {
    final done = exercise.setsDone[setIndex];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          // Set number
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: done ? AppTheme.accent : AppTheme.surface,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                '${setIndex + 1}',
                style: TextStyle(
                  color: done ? Colors.black : AppTheme.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          // Reps input
          Expanded(
            child: _NumberInput(
              hint: '${exercise.reps}',
              value: exercise.loggedReps[setIndex],
              onChanged: (v) => onLogReps(v.toInt()),
            ),
          ),
          const SizedBox(width: 6),
          // Weight input
          Expanded(
            child: _NumberInput(
              hint: '${exercise.weight}',
              value: exercise.loggedWeight[setIndex],
              isDecimal: true,
              onChanged: onLogWeight,
            ),
          ),
          const SizedBox(width: 6),
          // Done button
          GestureDetector(
            onTap: done ? null : onComplete,
            child: AnimatedContainer(
              duration: 200.ms,
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: done ? AppTheme.accent : AppTheme.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: done ? AppTheme.accent : AppTheme.border,
                ),
              ),
              child: Text(
                done ? '✓' : 'OK',
                style: TextStyle(
                  color: done ? Colors.black : AppTheme.textMuted,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NumberInput extends StatelessWidget {
  final String hint;
  final num value;
  final bool isDecimal;
  final void Function(double) onChanged;

  const _NumberInput({
    required this.hint,
    required this.value,
    this.isDecimal = false,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: value > 0 ? value.toString() : '',
      keyboardType:
          TextInputType.numberWithOptions(decimal: isDecimal),
      textAlign: TextAlign.center,
      style: const TextStyle(
          color: AppTheme.textPrimary,
          fontSize: 13,
          fontWeight: FontWeight.w700),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        isDense: true,
      ),
      onChanged: (v) => onChanged(double.tryParse(v) ?? 0),
    );
  }
}
