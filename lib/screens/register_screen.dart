import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:smart_campus/providers/auth_provider.dart';
import 'package:smart_campus/widgets/loading_overlay.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _studentIdController = TextEditingController();
  String _selectedDepartment = 'Computer Science';
  bool _obscurePassword = true;

  final List<String> _departments = [
    'Computer Science',
    'Textile Technology',
    'Electrical Engineering',
    'Mechanical Engineering',
    'Civil Engineering',
    'Polymer Engineering',
    'Business Administration',
    'Arts & Design',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _studentIdController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final success = await auth.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      studentId: _studentIdController.text.trim(),
      department: _selectedDepartment,
    );

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error ?? 'Registration failed'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = context.watch<AuthProvider>();

    return LoadingOverlay(
      isLoading: auth.isLoading,
      message: 'Creating account...',
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Create Account'),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  Text('Join Smart Campus', style: GoogleFonts.lexend(fontSize: 24, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text('Fill in your details to get started', style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 32),

                  // Name
                  TextFormField(
                    controller: _nameController,
                    validator: AuthProvider.validateName,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Email
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: AuthProvider.validateEmail,
                    decoration: const InputDecoration(
                      labelText: 'Email Address',
                      hintText: 'student@ntu.edu.pk',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Student ID
                  TextFormField(
                    controller: _studentIdController,
                    validator: AuthProvider.validateStudentId,
                    decoration: const InputDecoration(
                      labelText: 'Student ID',
                      hintText: '19-NTU-CS-1122',
                      prefixIcon: Icon(Icons.badge_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Department dropdown
                  DropdownButtonFormField<String>(
                    initialValue: _selectedDepartment,
                    decoration: const InputDecoration(
                      labelText: 'Department',
                      prefixIcon: Icon(Icons.school_outlined),
                    ),
                    items: _departments.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                    onChanged: (val) => setState(() => _selectedDepartment = val!),
                  ),
                  const SizedBox(height: 16),

                  // Password
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    validator: AuthProvider.validatePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Confirm Password
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please confirm your password';
                      if (value != _passwordController.text) return 'Passwords do not match';
                      return null;
                    },
                    decoration: const InputDecoration(
                      labelText: 'Confirm Password',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Register button
                  ElevatedButton(
                    onPressed: _handleRegister,
                    child: const Text('Create Account'),
                  ),
                  const SizedBox(height: 20),

                  // OR divider
                  Row(
                    children: [
                      Expanded(child: Divider(color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3))),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text('OR', style: theme.textTheme.labelSmall),
                      ),
                      Expanded(child: Divider(color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3))),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Google Sign-Up button
                  OutlinedButton.icon(
                    onPressed: () async {
                      final auth = context.read<AuthProvider>();
                      final success = await auth.signInWithGoogle();
                      if (!mounted) return;
                      if (success) {
                        Navigator.pushReplacementNamed(context, '/dashboard');
                      } else if (auth.error != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(auth.error!),
                            backgroundColor: theme.colorScheme.error,
                          ),
                        );
                      }
                    },
                    icon: Image.network(
                      'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
                      height: 20,
                      width: 20,
                      errorBuilder: (_, _, _) => const Icon(Icons.g_mobiledata, size: 24),
                    ),
                    label: const Text('Sign up with Google'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      side: BorderSide(color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3)),
                      foregroundColor: theme.colorScheme.onSurface,
                      textStyle: GoogleFonts.lexend(fontSize: 15, fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Already have account
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: RichText(
                        text: TextSpan(
                          text: 'Already have an account? ',
                          style: theme.textTheme.bodyMedium,
                          children: [
                            TextSpan(
                              text: 'Sign In',
                              style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
