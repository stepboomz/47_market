import 'package:brand_store_app/core/util/validators.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<ShadFormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void _signUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await AuthService().signUp(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );

        // Log the user in automatically after sign-up
        await AuthService().signIn(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );

        if (mounted) {
          // Navigate to HomeScreen after successful sign-up and login
          Navigator.pushReplacementNamed(
            context,
            '/main',
          );
        }
      } catch (e) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) {
              return ShadDialog(
                gap: 10,
                description: Text(e.toString()),
                title: const Text('Error'),
                actionsMainAxisSize: MainAxisSize.min,
                actions: [
                  ShadButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Hero(
              tag: 'auth-bar',
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.black,
                  image: DecorationImage(
                    image: AssetImage("assets/images/auth-background.jpg"),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      'Create a New Account',
                      style: GoogleFonts.raleway(
                        color: Colors.white,
                        fontSize: MediaQuery.textScalerOf(context).scale(36),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 7,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  ShadForm(
                    key: _formKey,
                    child: Column(
                      children: [
                        ShadInputFormField(
                          controller: _emailController,
                          placeholder: const Text('Enter your email'),
                          label: const Text('Email'),
                          validator: Validators.emailValidator,
                        ),
                        const SizedBox(height: 16),
                        ShadInputFormField(
                          controller: _passwordController,
                          placeholder: const Text('Enter your password'),
                          label: const Text('Password'),
                          obscureText: true,
                          validator: Validators.passwordValidator,
                        ),
                        const SizedBox(height: 16),
                        _isLoading
                            ? const ShadProgress()
                            : Hero(
                                tag: 'button',
                                child: ShadButton(
                                  onPressed: _signUp,
                                  child: const Text('Sign Up'),
                                ),
                              ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Already have an account? '),
                      ShadButton.ghost(
                        child: const Text('Sign In'),
                        onPressed: () {
                          Navigator.pushReplacementNamed(
                            context,
                            '/login',
                          );
                        },
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
