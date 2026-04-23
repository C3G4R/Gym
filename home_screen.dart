import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/exercise.dart';
import '../models/workout_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/exercise_card.dart';
import '../widgets/add_exercise_sheet.dart';
import '../widgets/rest_timer_overlay.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showTimer = false;
  int _restSeconds = 60;

  void _startRestTimer(int seconds) {
    setState(() {
      _restSeconds = seconds;
      _showTimer = true;
    });
  }

  void _stopTimer() => setState(() => _showTimer = false);

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: AppTheme.bg,
          body: Stack(
            children: [
              CustomScrollView(
                slivers: [
                  _buildAppBar(provider),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDayTabs(provider),
                          const SizedBox(height: 20),
                          _buildProgressCard(provider),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                  _buildExerciseList(provider),
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
              if (_showTimer)
                RestTimerOverlay(
                  seconds: _restSeconds,
                  onDone: _stopTimer,
                ),
            ],
          ),
          floatingActionButton: _buildFAB(provider),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          bottomNavigationBar: _buildBottomBar(provider),
        );
      },
    );
  }

  Widget _buildAppBar(WorkoutProvider provider) {
    return SliverAppBar(
      backgroundColor: AppTheme.surface,
      pinned: true,
      expandedHeight: 80,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'GYMFLOW',
              style: GoogleFonts.bebasNeue(
                fontSize: 28,
                color: AppTheme.accent,
                letterSpacing: 3,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: AppTheme.accent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '🔥 ${provider.streak} días',
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayTabs(WorkoutProvider provider) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: weekDays.length,
        itemBuilder: (context, i) {
          final isActive = provider.currentDay == i;
          final isDone = provider.completedDays.contains(i);
          return GestureDetector(
            onTap: () => provider.switchDay(i),
            child: AnimatedContainer(
              duration: 200.ms,
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: isActive ? AppTheme.accent : AppTheme.card,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: isActive ? AppTheme.accent : AppTheme.border,
                ),
              ),
              child: Text(
                weekDays[i].substring(0, 3).toUpperCase(),
                style: TextStyle(
                  color: isActive
                      ? Colors.black
                      : isDone
                          ? AppTheme.textMuted
                          : AppTheme.textPrimary,
                  fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
                  fontSize: 12,
                  decoration: isDone ? TextDecoration.lineThrough : null,
                ),
              ),
            ).animate(key: ValueKey(i)).fadeIn(duration: 200.ms),
          );
        },
      ),
    );
  }

  Widget _buildProgressCard(WorkoutProvider provider) {
    final progress = provider.todayProgress;
    final total = provider.currentExercises.length;
    final done = provider.completedCount;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                weekDays[provider.currentDay].toUpperCase(),
                style: GoogleFonts.bebasNeue(
                  fontSize: 18,
                  letterSpacing: 2,
                  color: AppTheme.textMuted,
                ),
              ),
              Text(
                '$done / $total ejercicios',
                style: const TextStyle(
                  color: AppTheme.accent,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppTheme.surface,
              valueColor: const AlwaysStoppedAnimation(AppTheme.accent),
              minHeight: 6,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1);
  }

  Widget _buildExerciseList(WorkoutProvider provider) {
    final exercises = provider.currentExercises;

    if (exercises.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.only(top: 60),
          child: Column(
            children: [
              const Text('💪', style: TextStyle(fontSize: 50)),
              const SizedBox(height: 16),
              Text(
                'Sin ejercicios hoy',
                style: GoogleFonts.bebasNeue(
                  fontSize: 22,
                  letterSpacing: 2,
                  color: AppTheme.textMuted,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Toca + para agregar tu primera rutina',
                style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
              ),
            ],
          ).animate().fadeIn(duration: 400.ms),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, i) => ExerciseCard(
            exercise: exercises[i],
            index: i,
            onRestStart: _startRestTimer,
          ).animate().fadeIn(delay: (i * 60).ms).slideY(begin: 0.1),
          childCount: exercises.length,
        ),
      ),
    );
  }

  Widget _buildFAB(WorkoutProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => ChangeNotifierProvider.value(
            value: provider,
            child: const AddExerciseSheet(),
          ),
        ),
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
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_rounded, color: Colors.black, size: 22),
              SizedBox(width: 8),
              Text(
                'AGREGAR EJERCICIO',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(WorkoutProvider provider) {
    return Container(
      height: 70,
      color: AppTheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          _navBtn('🗑', 'Limpiar', () {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                backgroundColor: AppTheme.card,
                title: const Text('¿Limpiar día?',
                    style: TextStyle(color: AppTheme.textPrimary)),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar',
                        style: TextStyle(color: AppTheme.textMuted)),
                  ),
                  TextButton(
                    onPressed: () {
                      provider.clearDay();
                      Navigator.pop(context);
                    },
                    child: const Text('Limpiar',
                        style: TextStyle(color: AppTheme.accentRed)),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(width: 10),
          _navBtn('✅', 'Completado', () {
            provider.markDayDone();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('¡Día completado! 💪'),
                backgroundColor: AppTheme.accent,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }),
          const SizedBox(width: 10),
          _navBtn('📋', 'Copiar', () => _showCopyDialog(provider)),
        ],
      ),
    );
  }

  Widget _navBtn(String icon, String label, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.border),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(icon, style: const TextStyle(fontSize: 16)),
              Text(
                label,
                style: const TextStyle(
                    fontSize: 10,
                    color: AppTheme.textMuted,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCopyDialog(WorkoutProvider provider) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.card,
        title: const Text('Copiar rutina a:',
            style: TextStyle(color: AppTheme.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: weekDays
              .asMap()
              .entries
              .where((e) => e.key != provider.currentDay)
              .map(
                (e) => ListTile(
                  title: Text(e.value,
                      style: const TextStyle(color: AppTheme.textPrimary)),
                  onTap: () {
                    provider.copyDayTo(e.key);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Copiado al ${e.value}'),
                        backgroundColor: AppTheme.accent,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
