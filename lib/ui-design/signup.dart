import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todolistleap/blocs/auth_bloc.dart';
import 'package:todolistleap/blocs/auth_event.dart';
import 'package:todolistleap/blocs/auth_state.dart';
import 'package:todolistleap/core/constant/colors.dart';
import 'package:todolistleap/core/constant/typography.dart';

class LoginRegisterScreen extends StatefulWidget {
  const LoginRegisterScreen({super.key});

  @override
  State<LoginRegisterScreen> createState() => _LoginRegisterScreenState();
}

class _LoginRegisterScreenState extends State<LoginRegisterScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabSelection);
  }

  Future<void> _handleTabSelection() async {
    if (!_tabController.indexIsChanging) {
      final prefs = await SharedPreferences.getInstance();
      final storedEmail = prefs.getString('email');
      setState(() {
        _emailController.clear();
        _passwordController.clear();
      });
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.isAuthenticated) {
          Navigator.pushReplacementNamed(context, '/home');
        } else if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error!)),
          );
        } else if (state.isRegistered) {
          _tabController.animateTo(0);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registration successful! Please login.')),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Center(
            // Center the entire content
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo or decorative element
                  Padding(
                    padding: const EdgeInsets.only(bottom: 32.0),
                    child: Image.asset(
                      'assets/logo.png', // Add your logo in assets and pubspec.yaml
                      height: 100,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [AppColors.primary, AppColors.primary.withOpacity(0.7)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: const Icon(
                          Icons.task_alt,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  // Welcome text
                  Text(
                    _tabController.index == 0 ? 'Welcome Back' : 'Join Us',
                    style: AppTypography.headlineLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Form container with shadow and rounded corners
                  Container(
                    width: double.infinity,
                    constraints: BoxConstraints(maxWidth: 400), // Responsive width
                    margin: const EdgeInsets.symmetric(horizontal: 24.0),
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // TabBar
                        TabBar(
                          controller: _tabController,
                          labelStyle: AppTypography.headlineMedium,
                          unselectedLabelStyle: AppTypography.bodyMedium,
                          indicatorColor: AppColors.primary,
                          labelColor: AppColors.primary,
                          unselectedLabelColor: AppColors.text.withOpacity(0.6),
                          tabs: const [
                            Tab(text: 'Login'),
                            Tab(text: 'Register'),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // TabBarView
                        SizedBox(
                          height: 300, // Fixed height to prevent overflow
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              // Login Tab
                              _buildForm(context, isLogin: true),
                              // Register Tab
                              _buildForm(context, isLogin: false),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Register prompt
                  GestureDetector(
                    onTap: () => _tabController.animateTo(1),
                    child: Text(
                      _tabController.index == 0
                          ? "Don't have an account? Register"
                          : "Already have an account? Login",
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.primary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context, {required bool isLogin}) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Email', style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(
            controller: _emailController,
            decoration: InputDecoration(
              hintText: 'Enter your Email',
              prefixIcon: Icon(Icons.email_outlined, color: AppColors.text.withOpacity(0.6)),
              border: const UnderlineInputBorder(),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.text.withOpacity(0.2)),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.primary),
              ),
            ),
            style: AppTypography.bodyMedium,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          Text('Password', style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
              hintText: 'Enter your Password',
              prefixIcon: Icon(Icons.lock_outline, color: AppColors.text.withOpacity(0.6)),
              border: const UnderlineInputBorder(),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.text.withOpacity(0.2)),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.primary),
              ),
            ),
            style: AppTypography.bodyMedium,
          ),
          const SizedBox(height: 32),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              return ElevatedButton(
                onPressed: () {
                  if (isLogin) {
                    context.read<AuthBloc>().add(
                      LoginEvent(_emailController.text, _passwordController.text),
                    );
                  } else {
                    context.read<AuthBloc>().add(
                      RegisterEvent(_emailController.text, _passwordController.text),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  elevation: 2,
                ),
                child: state.isAuthenticated
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : Text(
                  isLogin ? 'Login' : 'Register',
                  style: AppTypography.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}