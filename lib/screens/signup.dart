// imports
import 'package:e178117_simple_weather_news_app/login.dart';
import 'package:flutter/material.dart';
import 'database_handler.dart';
import 'user.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  _SignupPageState createState() => _SignupPageState();
}

// sign up page class
class _SignupPageState extends State<SignupPage> {
  // assign a unique identifier to the form
  final _formKey = GlobalKey<FormState>();
  // text controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false; // var to store psw visibility
  late DatabaseHandler handler; // db handler obj

  // method to signup
  void _signup() async {
    // this verifies the controls are all filled out
    if (_formKey.currentState!.validate()) {
      print('Signed up');
      // CODE TO CREATE USER ACCOUNT
      handler = DatabaseHandler(); // initiate 'handler'
      // create a new 'User' using text controllers
      User user = User(
        name: _emailController.text,
        pass: _passwordController.text,
      );
      // add user to db, show result
      final result = await handler.addUser([user]);
      print("Number of users added: $result");
      // show news page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  // build signup page
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 32),
                  Center(
                    // display banner text
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(color: Colors.blueAccent, fontSize: 50),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Email Input
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      // check if user has input data
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16), // spacing
                  // Password Input
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        // btn to change psw visibity
                        icon: Icon(
                          // icon is changed according to psw visibility
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          // change psw visibility state
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    obscureText: !_isPasswordVisible,
                    validator: (value) {
                      // check if user has input data
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16), // spacing
                  // Sign Up Button
                  ElevatedButton(
                    onPressed: _signup, // call method to signup
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(fontSize: 16),
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

  @override
  void dispose() {
    // Clean up controllers
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
