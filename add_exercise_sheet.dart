import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/exercise.dart';
import '../models/workout_provider.dart';
import '../theme/app_theme.dart';

class AddExerciseSheet extends StatefulWidget {
  const AddExerciseSheet({super.key});

  @override
  State<AddExerciseSheet> createState() => _AddExerciseSheetState();
}

class _AddExerciseSheetState extends State<AddExerciseSheet> {
  final _nameCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  int _sets = 3;
  int _reps = 12;
  double _weight = 0;
  int _rest = 60;
  String _muscle = muscleGroups.first;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa el nombre del ejercicio')),
      );
      return;
    }
    final ex = Exercise(
      id: const Uuid().v4(),
      name: _nameCtrl.text.trim(),
      sets: _sets,
      reps: _reps,
      weight: _weight,
      restSeconds: _rest,
      muscle: _muscle,
      note: _noteCtrl.text.trim(),
    );
    context.read<WorkoutProvider>().addExercise(ex);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppTheme.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              'NUEVO EJERCICIO',
              style: GoogleFonts.bebasNeue(
                fontSize: 22,
                letterSpacing: 3,
                color: AppTheme.accent,
              ),
            ),
            const SizedBox(height: 20),

            // Name
            _label('NOMBRE'),
            const SizedBox(height: 6),
            TextField(
              controller: _nameCtrl,
              autofocus: true,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(
                hintText: 'Ej: Press de banca',
              ),
            ),
            const SizedBox(height: 16),

            // Sets / Reps / Weight / Rest
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('SERIES'),
                      const SizedBox(height: 6),
                      _stepper(
                        value: _sets,
                        onMinus: () => setState(
                            () => _sets = (_sets - 1).clamp(1, 10)),
                        onPlus: () => setState(
                            () => _sets = (_sets + 1).clamp(1, 10)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('REPS'),
                      const SizedBox(height: 6),
                      _stepper(
                        value: _reps,
                        onMinus: () => setState(
                            () => _reps = (_reps - 1).clamp(1, 99)),
                        onPlus: () => setState(
                            () => _reps = (_reps + 1).clamp(1, 99)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('PESO (kg)'),
                      const SizedBox(height: 6),
                      TextField(
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        style:
                            const TextStyle(color: AppTheme.textPrimary),
                        decoration: const InputDecoration(hintText: '0'),
                        onChanged: (v) =>
                            _weight = double.tryParse(v) ?? 0,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('DESCANSO (s)'),
                      const SizedBox(height: 6),
                      _stepper(
                        value: _rest,
                        step: 15,
                        onMinus: () => setState(
                            () => _rest = (_rest - 15).clamp(15, 300)),
                        onPlus: () => setState(
                            () => _rest = (_rest + 15).clamp(15, 300)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Muscle
            _label('MÚSCULO'),
            const SizedBox(height: 6),
            SizedBox(
              height: 36,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: muscleGroups.length,
                itemBuilder: (context, i) {
                  final selected = muscleGroups[i] == _muscle;
                  return GestureDetector(
                    onTap: () => setState(() => _muscle = muscleGroups[i]),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: selected ? AppTheme.accent : AppTheme.card,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color:
                              selected ? AppTheme.accent : AppTheme.border,
                        ),
                      ),
                      child: Text(
                        muscleGroups[i],
                        style: TextStyle(
                          color: selected ? Colors.black : AppTheme.textMuted,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Note
            _label('NOTA (opcional)'),
            const SizedBox(height: 6),
            TextField(
              controller: _noteCtrl,
              maxLines: 2,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(
                hintText: 'Ej: Bajar lento, mantener espalda recta...',
              ),
            ),
            const SizedBox(height: 24),

            // Submit
            GestureDetector(
              onTap: _submit,
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: AppTheme.accent,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accent.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'AGREGAR',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: const TextStyle(
          color: AppTheme.textMuted,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
      );

  Widget _stepper({
    required int value,
    int step = 1,
    required VoidCallback onMinus,
    required VoidCallback onPlus,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onMinus,
            child: const SizedBox(
              width: 36,
              height: 44,
              child: Icon(Icons.remove_rounded,
                  color: AppTheme.textMuted, size: 16),
            ),
          ),
          Expanded(
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ),
          GestureDetector(
            onTap: onPlus,
            child: const SizedBox(
              width: 36,
              height: 44,
              child: Icon(Icons.add_rounded,
                  color: AppTheme.textMuted, size: 16),
            ),
          ),
        ],
      ),
    );
  }
}
