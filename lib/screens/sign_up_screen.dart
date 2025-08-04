import '../screens/home_screen.dart';
import '../screens/sign_in_screen.dart';
import '../widgets/button.dart';
import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _termsAgreed = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // Set default values for name fields (for convenience)
    _firstNameController.text = 'John';
    _lastNameController.text = 'Doe';
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _navToSignInScreen(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const SignInScreen(),
      ),
    );
  }

  void _navToHomeScreen(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Taskio',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CREATE ACCOUNT',
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Name Fields
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'FIRST NAME',
                              style: TextStyle(
                                fontSize: 12.0,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4.0),
                            TextField(
                              controller: _firstNameController,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey[200],
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12.0, vertical: 14.0),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'LAST NAME',
                              style: TextStyle(
                                fontSize: 12.0,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4.0),
                            TextField(
                              controller: _lastNameController,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey[200],
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12.0, vertical: 14.0),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16.0),

                  // Email
                  const Text(
                    'EMAIL',
                    style: TextStyle(
                      fontSize: 12.0,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 14.0),
                    ),
                  ),

                  const SizedBox(height: 16.0),

                  // Password
                  const Text(
                    'PASSWORD',
                    style: TextStyle(
                      fontSize: 12.0,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 14.0),
                      suffixIcon: TextButton(
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                        child: const Text(
                          'SHOW',
                          style: TextStyle(
                            color: Color(0xFF6200EE),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16.0),

                  // Confirm Password
                  const Text(
                    'CONFIRM PASSWORD',
                    style: TextStyle(
                      fontSize: 12.0,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  TextField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 14.0),
                      suffixIcon: TextButton(
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                        child: const Text(
                          'SHOW',
                          style: TextStyle(
                            color: Color(0xFF6200EE),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16.0),

                  // Terms Checkbox
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Checkbox(
                        value: _termsAgreed,
                        activeColor: const Color(0xFF6200EE),
                        onChanged: (value) {
                          setState(() {
                            _termsAgreed = value ?? false;
                          });
                        },
                      ),
                      const Expanded(
                        child: Text.rich(
                          TextSpan(
                            text: 'I agree to the ',
                            children: [
                              TextSpan(
                                text: 'Terms of Service',
                                style: TextStyle(
                                  color: Color(0xFF6200EE),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(text: ' and '),
                              TextSpan(
                                text: 'Privacy Policy',
                                style: TextStyle(
                                  color: Color(0xFF6200EE),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24.0),

                  ActionButton(
                    label:
                        _isLoading ? 'CREATING ACCOUNT...' : 'CREATE ACCOUNT',
                    onPressed: _isLoading ? () {} : () {},
                  ),

                  const SizedBox(height: 16.0),

                  // Sign In Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Already have an account?'),
                      TextButton(
                        onPressed: _isLoading
                            ? null
                            : () => _navToSignInScreen(context),
                        child: const Text(
                          'Sign in',
                          style: TextStyle(
                            color: Color(0xFF6200EE),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
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
