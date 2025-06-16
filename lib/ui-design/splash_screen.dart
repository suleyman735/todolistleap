import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todolistleap/blocs/auth_bloc.dart';
import 'package:todolistleap/blocs/auth_event.dart';
import 'package:todolistleap/blocs/auth_state.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Trigger authentication check after a short delay
    Future.delayed(const Duration(seconds: 2), () {
      context.read<AuthBloc>().add(const CheckAuthEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.isAuthenticated) {
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          Navigator.pushReplacementNamed(context, '/login');
        }
      },
      child: const Scaffold(
        body: Center(child: Text('Splash')),
      ),
    );
  }
}

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});
//
//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }
//
// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return  Center(child: Text('spalsh'),);
//   }
// }
