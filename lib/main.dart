import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todolistleap/blocs/task_bloc.dart';
import 'package:todolistleap/core/constant/theme.dart';
import 'package:todolistleap/ui-design/calendar_screen.dart';
import 'package:todolistleap/ui-design/chart_screen.dart';
import 'package:todolistleap/ui-design/home_screen.dart';
import 'package:todolistleap/ui-design/signup.dart';
import 'package:todolistleap/ui-design/splash_screen.dart';

import 'blocs/auth_bloc.dart';
import 'blocs/task_event.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthBloc()),
        BlocProvider(create: (context) => TaskBloc()..add(FilterTasksEvent(filterDate: DateTime.now()))),
      ],
      child: MaterialApp(
        title: 'Todo List Leap',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: '/splash',
        routes: {
          '/splash': (context) => const SplashScreen(),
          '/login': (context) => const LoginRegisterScreen(),
          '/home': (context) =>  HomePage(),
          '/calendar': (context) =>  CalendarScreen(),
          '/chart': (context) =>  ChartScreen(),
        },
      ),
    );
  }
}



