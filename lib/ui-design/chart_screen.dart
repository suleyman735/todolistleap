import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todolistleap/blocs/auth_bloc.dart';
import 'package:todolistleap/blocs/auth_event.dart';
import 'package:todolistleap/blocs/task_bloc.dart';
import 'package:todolistleap/blocs/task_state.dart';
import 'package:todolistleap/core/constant/colors.dart';
import 'package:todolistleap/core/constant/typography.dart';
import 'package:todolistleap/models/task_model.dart';
import 'package:todolistleap/ui-widgets/custom_app_bar.dart';
import 'package:todolistleap/ui-widgets/custom_bottom_app_bar.dart';
import 'package:todolistleap/ui-widgets/custom_drawer.dart';
import 'package:todolistleap/ui-widgets/task_modals.dart';




class ChartScreen extends StatefulWidget {
  const ChartScreen({super.key});

  @override
  State<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  String? _username;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _touchedIndex = -1; // For pie chart touch interaction

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('email')?.split('@')[0]; // Use email prefix as username
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        username: _username,
        onProfileTap: () => _scaffoldKey.currentState?.openEndDrawer(),
      ),
      endDrawer: CustomDrawer(
        username: _username,
        onLogout: () {
          context.read<AuthBloc>().add(const LogoutEvent());
          _scaffoldKey.currentState?.closeEndDrawer();
        },
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with greeting
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
            child: Text(
              'Hello, ${_username ?? "User"}!',
              style: AppTypography.headlineLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.text,
              ),
              semanticsLabel: 'Greeting for ${_username ?? "User"}',
            ),
          ),
          // Chart section
          Expanded(
            child: BlocBuilder<TaskBloc, TaskState>(
              builder: (context, state) {
                if (state.tasks.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.task_alt, size: 64, color: AppColors.text.withOpacity(0.5)),
                        const SizedBox(height: 16),
                        Text(
                          'No tasks to display. Add a new task!',
                          style: AppTypography.bodyMedium.copyWith(color: AppColors.text.withOpacity(0.5)),
                          semanticsLabel: 'No tasks available',
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            showAddTaskModal(
                              context,
                              categories: ['University', 'Home', 'Work'],
                              defaultCategory: 'University',
                            );
                          },
                          child: Text(
                            'Add Task',
                            style: AppTypography.bodyMedium.copyWith(color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final completionData = _prepareCompletionData(state.tasks);
                final totalTasks = state.tasks.length;

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildSectionHeader('Task Summary'),
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: SizedBox(
                          height: 300,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              PieChart(
                                PieChartData(
                                  sections: _buildCompletionSections(completionData, totalTasks),
                                  sectionsSpace: 4,
                                  centerSpaceRadius: 60,
                                  pieTouchData: PieTouchData(
                                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                                      setState(() {
                                        if (!event.isInterestedForInteractions ||
                                            pieTouchResponse == null ||
                                            pieTouchResponse.touchedSection == null) {
                                          _touchedIndex = -1;
                                          return;
                                        }
                                        _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                                      });
                                    },
                                  ),
                                  borderData: FlBorderData(show: false),
                                ),
                                swapAnimationDuration: const Duration(milliseconds: 300),
                                swapAnimationCurve: Curves.easeInOut,
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '$totalTasks',
                                    style: AppTypography.headlineLarge.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black.withOpacity(0.2),
                                          offset: const Offset(2, 2),
                                          blurRadius: 6,
                                        ),
                                      ],
                                    ),
                                    semanticsLabel: 'Total tasks: $totalTasks',
                                  ),
                                  Text(
                                    'Total Tasks',
                                    style: AppTypography.bodyMedium.copyWith(color: AppColors.text),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatusIndicator(
                            'Pending',
                            completionData.firstWhere((e) => e.key == 'Not Completed').value,
                            Icons.radio_button_unchecked,
                            Colors.purple,
                          ),
                          _buildStatusIndicator(
                            'Completed',
                            completionData.firstWhere((e) => e.key == 'Completed').value,
                            Icons.check_circle,
                            Colors.green,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      // Unchanged CustomBottomNavBar from your original code
      bottomNavigationBar: CustomBottomNavBar(
        currentRoute: '/chart',
        scaffoldKey: _scaffoldKey,
        parentContext: context,
        initialDate: null,
        showCompleted: null,
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        title,
        style: AppTypography.headlineMedium.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
        semanticsLabel: title,
      ),
    );
  }

  List<PieChartSectionData> _buildCompletionSections(List<MapEntry<String, int>> completionData, int totalTasks) {
    return completionData.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      final percentage = (data.value / totalTasks * 100).roundToDouble();
      final isTouched = index == _touchedIndex;
      return PieChartSectionData(
        color: data.key == 'Completed'
            ? Color.lerp(Colors.green, Colors.lightGreen, 0.3)!
            : Color.lerp(Colors.purple, Colors.purpleAccent, 0.3)!,
        value: data.value.toDouble(),
        radius: isTouched ? 130 : 120,
        title: '',
        badgeWidget: _buildPieBadge(data.key, percentage),
        badgePositionPercentageOffset: 0.98,
      );
    }).toList();
  }

  Widget _buildPieBadge(String status, double percentage) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: status == 'Completed' ? Colors.green : Colors.purple,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        '$percentage%',
        style: AppTypography.bodyMedium.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(String title, int count, IconData icon, Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {}); // Trigger rebuild for animation
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24, semanticLabel: title),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyMedium.copyWith(color: color),
                ),
                Text(
                  '$count',
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.text,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<MapEntry<String, int>> _prepareCompletionData(List<Task> tasks) {
    final completed = tasks.where((task) => task.isCompleted).length;
    final notCompleted = tasks.length - completed;
    return [
      MapEntry('Not Completed', notCompleted),
      MapEntry('Completed', completed),
    ];
  }

  Map<String, int> _prepareCategoryPriorityData(List<Task> tasks) {
    final categoryMap = <String, int>{};
    for (var task in tasks) {
      categoryMap[task.category] = (categoryMap[task.category] ?? 0) + 1;
    }
    return categoryMap;
  }
}


// class ChartScreen extends StatefulWidget {
//   @override
//   State<ChartScreen> createState() => _ChartScreenState();
// }
//
// class _ChartScreenState extends State<ChartScreen> {
//   String? _username;
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
//
//   @override
//   void initState() {
//     super.initState();
//     _loadUsername();
//   }
//
//   Future<void> _loadUsername() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       _username = prefs.getString('email');
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       key: _scaffoldKey,
//       appBar: CustomAppBar(
//         username: _username,
//         onProfileTap: () => _scaffoldKey.currentState?.openEndDrawer(),
//       ),
//       endDrawer: CustomDrawer(
//         username: _username,
//         onLogout: () {
//           context.read<AuthBloc>().add(const LogoutEvent());
//           _scaffoldKey.currentState?.closeEndDrawer();
//         },
//       ),
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [AppColors.background, Colors.grey[100]!],
//           ),
//         ),
//         child: BlocBuilder<TaskBloc, TaskState>(
//           builder: (context, state) {
//             if (state.tasks.isEmpty) {
//               return Center(
//                 child: Text(
//                   'No tasks to display',
//                   style: AppTypography.bodyMedium.copyWith(color: AppColors.text),
//                 ),
//               );
//             }
//
//             final completionData = _prepareCompletionData(state.tasks);
//             final totalTasks = state.tasks.length;
//
//             return Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   _buildSectionHeader('Task Summary'),
//                   SizedBox(
//                     height: 300,
//                     child: Stack(
//                       alignment: Alignment.center,
//                       children: [
//                         PieChart(
//                           PieChartData(
//                             sections: _buildCompletionSections(completionData, totalTasks),
//                             sectionsSpace: 2,
//                             centerSpaceRadius: 50,
//                             pieTouchData: PieTouchData(enabled: false),
//                             borderData: FlBorderData(show: false),
//                           ),
//                         ),
//                         Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Text(
//                               '$totalTasks',
//                               style: AppTypography.headlineLarge.copyWith(
//                                 color: AppColors.primary,
//                                 fontWeight: FontWeight.bold,
//                                 shadows: [
//                                   Shadow(color: Colors.black26, offset: Offset(2, 2), blurRadius: 4),
//                                 ],
//                               ),
//                             ),
//                             Text(
//                               'Total Tasks',
//                               style: AppTypography.bodyMedium.copyWith(color: AppColors.text),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                   SizedBox(height: 20),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     children: [
//                       _buildStatusIndicator('Pending', completionData.firstWhere((e) => e.key == 'Not Completed').value,
//                           Icons.radio_button_unchecked, Colors.purple),
//                       _buildStatusIndicator('Completed', completionData.firstWhere((e) => e.key == 'Completed').value,
//                           Icons.check_circle, Colors.green),
//                     ],
//                   ),
//                 ],
//               ),
//             );
//           },
//         ),
//       ),
//       bottomNavigationBar: CustomBottomNavBar(
//         currentRoute: '/chart',
//         scaffoldKey: _scaffoldKey,
//         parentContext: context,
//         initialDate: null,
//         showCompleted: null,
//       ),
//     );
//   }
//
//   Widget _buildSectionHeader(String title) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 10),
//       child: Text(
//         title,
//         style: AppTypography.headlineMedium.copyWith(
//           color: AppColors.primary,
//           fontWeight: FontWeight.bold,
//           letterSpacing: 1.2,
//         ),
//       ),
//     );
//   }
//
//   List<PieChartSectionData> _buildCompletionSections(List<MapEntry<String, int>> completionData, int totalTasks) {
//     return completionData.map((entry) {
//       final percentage = (entry.value / totalTasks * 100).roundToDouble();
//       return PieChartSectionData(
//         color: entry.key == 'Completed'
//             ? Color.lerp(Colors.green, Colors.lightGreen, 0.3)!
//             : Color.lerp(Colors.purple, Colors.purpleAccent, 0.3)!,
//         value: entry.value.toDouble(),
//         radius: 120,
//         title: '',
//         badgeWidget: _buildPieBadge(entry.key, percentage),
//         badgePositionPercentageOffset: 0.98,
//       );
//     }).toList();
//   }
//
//   Widget _buildPieBadge(String status, double percentage) {
//     return Container(
//       padding: EdgeInsets.all(4),
//       decoration: BoxDecoration(
//         color: status == 'Completed' ? Colors.green : Colors.purple,
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: Text(
//         '$percentage%',
//         style: AppTypography.bodyMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
//       ),
//     );
//   }
//
//   Widget _buildStatusIndicator(String title, int count, IconData icon, Color color) {
//     return Row(
//       children: [
//         Icon(icon, color: color, size: 20),
//         SizedBox(width: 8),
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               title,
//               style: AppTypography.bodyMedium.copyWith(color: color),
//             ),
//             Text(
//               '$count',
//               style: AppTypography.bodyLarge.copyWith(
//                 color: AppColors.text,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
//
//   List<MapEntry<String, int>> _prepareCompletionData(List<Task> tasks) {
//     final completed = tasks.where((task) => task.isCompleted).length;
//     final notCompleted = tasks.length - completed;
//     return [
//       MapEntry('Not Completed', notCompleted),
//       MapEntry('Completed', completed),
//     ];
//   }
//
//   Map<String, int> _prepareCategoryPriorityData(List<Task> tasks) {
//     final categoryMap = <String, int>{};
//     for (var task in tasks) {
//       categoryMap[task.category] = (categoryMap[task.category] ?? 0) + 1;
//     }
//     return categoryMap;
//   }
// }


