import '../screens/home_screen.dart';
import '../screens/sign_up_screen.dart';
import '../widgets/button.dart';
import 'package:flutter/material.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool _obscurePassword = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _navToSignUpScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SignUpScreen(),
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
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back!',
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            // Email Field
            const Text(
              'EMAIL',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
              child: TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: 'example@email.com',
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: InputBorder.none,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Password Field
            const Text(
              'PASSWORD',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
              child: TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: '••••••••',
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: InputBorder.none,
                  suffixIcon: TextButton(
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    child: const Text(
                      'SHOW',
                      style: TextStyle(
                        color: Color(0xFF8000FF),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Forgot Password Link
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _isLoading ? null : () {},
                style: TextButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: EdgeInsets.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(
                    color: Color(0xFF8000FF),
                    fontSize: 12,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Sign In Button
            ActionButton(
              label: _isLoading ? 'SIGNING IN...' : 'SIGN IN',
              onPressed: _isLoading ? () {} : () {},
            ),

            const SizedBox(height: 24),

            // OR divider
            Row(
              children: [
                Expanded(child: Divider(color: Colors.grey[300])),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'OR',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ),
                Expanded(child: Divider(color: Colors.grey[300])),
              ],
            ),

            const SizedBox(height: 24),

            // Create Account Link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'New user?',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                TextButton(
                  onPressed:
                      _isLoading ? null : () => _navToSignUpScreen(context),
                  style: TextButton.styleFrom(
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.only(left: 8),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Create an account',
                    style: TextStyle(
                      color: Color(0xFF8000FF),
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
