import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todolistleap/blocs/task_bloc.dart';
import 'package:todolistleap/blocs/task_event.dart';

import 'package:todolistleap/core/constant/colors.dart';
import 'package:todolistleap/ui-widgets/task_modals.dart';

class CustomBottomNavBar extends StatelessWidget {
  final String currentRoute; // To highlight the active page
  final GlobalKey<ScaffoldState>? scaffoldKey; // For opening the drawer
  final BuildContext parentContext; // For navigation and modal
  final DateTime? initialDate; // For CalendarScreen's selected date
  final bool? showCompleted; // For CalendarScreen's filter

  const CustomBottomNavBar({
    required this.currentRoute,
    this.scaffoldKey,
    required this.parentContext,
    this.initialDate,
    this.showCompleted,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: AppColors.background,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(
                Icons.list,
                color: currentRoute == '/home' ? AppColors.primary : AppColors.text,
              ),
              onPressed: () {
                if (currentRoute != '/home') {
                  Navigator.pushReplacementNamed(parentContext, '/home');
                }
              },
            ),
            IconButton(
              icon: Icon(
                Icons.calendar_today,
                color: currentRoute == '/calendar' ? AppColors.primary : AppColors.text,
              ),
              onPressed: () {
                if (currentRoute != '/calendar') {
                  Navigator.pushReplacementNamed(parentContext, '/calendar');
                }
              },
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.add, color: Colors.white),
                onPressed: () {
                  showAddTaskModal(
                    parentContext,
                    categories: ['University', 'Home', 'Work'],
                    defaultCategory: 'University',
                    initialDate: initialDate,
                  );
                  // Refresh tasks if on CalendarScreen
                  if (currentRoute == '/calendar') {
                    final taskBloc = parentContext.read<TaskBloc>();
                    taskBloc.add(FilterTasksEvent(
                      filterDate: initialDate,
                      showCompleted: showCompleted,
                    ));
                  }
                },
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.watch_later,
                color: currentRoute == '/chart' ? AppColors.primary : AppColors.text,
              ),
              onPressed: () {
                if (currentRoute != '/chart') {
                  Navigator.pushReplacementNamed(parentContext, '/chart');
                }
              },
            ),
            IconButton(
              icon: Icon(
                Icons.person,
                color: currentRoute == '/profile' ? AppColors.primary : AppColors.text,
              ),
              onPressed: () {
                scaffoldKey?.currentState?.openEndDrawer();
              },
            ),
          ],
        ),
      ),
    );
  }
}

// class CustomBottomNavBar extends StatelessWidget {
//   final Function(BuildContext)? onAddTask;
//   final GlobalKey<ScaffoldState>? scaffoldKey;
//   final int currentIndex;
//   final Function(int) onTap;
//
//   CustomBottomNavBar({
//     this.onAddTask,
//     this.scaffoldKey,
//     required this.currentIndex,
//     required this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final items = [
//       {'icon': Icons.list, 'route': '/home', 'activeColor': AppColors.primary},
//       {'icon': Icons.calendar_today, 'route': '/calendar', 'activeColor': AppColors.text},
//       {'icon': null, 'route': null, 'activeColor': null}, // Placeholder for add button
//       {'icon': Icons.watch_later, 'route': '/chart', 'activeColor': AppColors.text},
//       {'icon': Icons.person, 'route': null, 'activeColor': AppColors.text},
//     ];
//
//     return BottomAppBar(
//       color: AppColors.background,
//       elevation: 8,
//       shape: CircularNotchedRectangle(),
//       notchMargin: 8,
//       child: Padding(
//         padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceAround,
//           children: List.generate(items.length, (index) {
//             if (index == 2) {
//               return Padding(
//                 padding: EdgeInsets.only(bottom: 20),
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: AppColors.primary,
//                     shape: BoxShape.circle,
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black26,
//                         blurRadius: 6,
//                         offset: Offset(0, 2),
//                       ),
//                     ],
//                   ),
//                   child: IconButton(
//                     icon: Icon(Icons.add, color: Colors.white),
//                     onPressed: () => onAddTask?.call(context),
//                   ),
//                 ),
//               );
//             }
//             final item = items[index];
//             return IconButton(
//               icon: Icon(item['icon'] as IconData),
//               // color: currentIndex == index ? item['activeColor'] : AppColors.text.withOpacity(0.6),
//               onPressed: item['route'] != null
//                   ? () {
//                 onTap(index);
//                 // Navigator.pushReplacementNamed(context, item['route']);
//               }
//                   : index == 4
//                   ? () => scaffoldKey?.currentState?.openEndDrawer()
//                   : null,
//             );
//           }),
//         ),
//       ),
//     );
//   }
// }

// class CustomBottomAppBar extends StatelessWidget {
//   final VoidCallback onPersonTap;
//
//   const CustomBottomAppBar({super.key, required this.onPersonTap});
//
//   @override
//   Widget build(BuildContext context) {
//     return BottomAppBar(
//       color: AppColors.background,
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 8),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceAround,
//           children: [
//             IconButton(
//               icon: const Icon(Icons.list, color: AppColors.primary),
//               onPressed: () {},
//             ),
//             IconButton(
//               icon: const Icon(Icons.calendar_today, color: AppColors.text),
//               onPressed: () {},
//             ),
//             Builder(
//               builder: (context) {
//                 return Container(
//                   margin: const EdgeInsets.only(bottom: 20),
//                   decoration: const BoxDecoration(
//                     color: AppColors.primary,
//                     shape: BoxShape.circle,
//                   ),
//                   child: IconButton(
//                     icon: const Icon(Icons.add, color: Colors.white),
//                     onPressed: () {
//                       // Task.showAddTaskModal(context);
//                     },
//                   ),
//                 );
//               },
//             ),
//             IconButton(
//               icon: const Icon(Icons.watch_later, color: AppColors.text),
//               onPressed: () {},
//             ),
//             IconButton(
//               icon: const Icon(Icons.person, color: AppColors.text),
//               onPressed: onPersonTap,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }