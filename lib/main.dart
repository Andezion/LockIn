import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockin/screens/daily/daily_view.dart';
import 'package:lockin/screens/profile/profile_view.dart';
import 'package:lockin/screens/statistics/statistics_view.dart';
import 'package:lockin/services/hive_service.dart';
import 'package:lockin/providers/penalty_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await HiveService.initialize(clearData: true);

  runApp(const ProviderScope(child: LockInApp()));
}

class LockInApp extends StatelessWidget {
  const LockInApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LockIn',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      home: const MainNavigator(),
    );
  }
}

class MainNavigator extends ConsumerStatefulWidget {
  const MainNavigator({super.key});

  @override
  ConsumerState<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends ConsumerState<MainNavigator> {
  int _currentIndex = 0;
  bool _penaltiesChecked = false;

  final List<Widget> _screens = const [
    DailyView(),
    StatisticsView(),
    ProfileView(),
  ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPenalties();
    });
  }

  Future<void> _checkPenalties() async {
    if (_penaltiesChecked) return;
    _penaltiesChecked = true;

    try {
      final result = await ref.read(penaltyProvider).checkAndApplyPenalties();

      if (result.hasPenalties && mounted) {
        _showPenaltyDialog(result);
      }
    } catch (e) {
      debugPrint('Error checking penalties: $e');
    }
  }

  void _showPenaltyDialog(PenaltyResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange[700]),
            const SizedBox(width: 8),
            const Text('Penalties for Incomplete Tasks'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'For incomplete tasks, you lost:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Text(
              '-${result.totalPenalty} XP',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              result.penaltiesByDate.length == 1
                  ? 'For 1 missed day'
                  : 'For ${result.penaltiesByDate.length} missed days',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline,
                      color: Colors.blue[700], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Penalty = (Difficulty + 1) for each incomplete task\n',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[900],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Understood'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.calendar_today),
            selectedIcon: Icon(Icons.calendar_today),
            label: 'Daily',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Statistics',
          ),
          NavigationDestination(
            icon: Icon(Icons.person),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
