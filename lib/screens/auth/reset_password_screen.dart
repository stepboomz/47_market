import 'package:brand_store_app/core/util/validators.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../services/auth_service.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<ShadFormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  void _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await AuthService().resetPassword(_emailController.text.trim());

        if (mounted) {
          // Show success dialog
          showDialog(
            context: context,
            builder: (context) {
              return ShadDialog(
                gap: 10,
                description: const Text(
                  'A password reset email has been sent to your email address.',
                ),
                title: const Text('Success'),
                actionsMainAxisSize: MainAxisSize.min,
                actions: [
                  ShadButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          ).then((_) {
            if (mounted) Navigator.pop(context); // Navigate back after dialog
          });
        }
      } catch (e) {
        if (mounted) {
          // Show error dialog
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          color: Colors.white,
          style: IconButton.styleFrom(
            side: const BorderSide(width: 2, color: Colors.white),
          ),
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
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
                    image: AssetImage(
                        "assets/images/auth-background.jpg"),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Center(
                  child: Text(
                    'Reset Password',
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
          Expanded(
            flex: 7,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ShadForm(
                key: _formKey,
                child: Column(
                  children: [
                    ShadInputFormField(
                      controller: _emailController,
                      placeholder: const Text('Enter your email'),
                      description: const Text(
                          'Enter your email to reset your password.'),
                      label: const Text('Email'),
                      validator: Validators.emailValidator,
                    ),
                    const SizedBox(height: 16),
                    _isLoading
                        ? const ShadProgress()
                        : Hero(
                            tag: 'button',
                            child: ShadButton(
                              onPressed: _resetPassword,
                              child: const Text('Send Reset Email'),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
