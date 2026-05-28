import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:p10/page/home_page.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final _formkey = GlobalKey<FormState>();

  final TextEditingController _emailController =
      TextEditingController();

  final TextEditingController _passwordController =
      TextEditingController();

  bool _isLoading = false;
  bool _obscureText = true;

  Future<void> _login() async {

    if (_formkey.currentState!.validate()) {

      setState(() {
        _isLoading = true;
      });

      try {

        UserCredential userCredential =
            await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        if (userCredential.user != null) {

          Fluttertoast.showToast(
            msg: 'Login Successful!',
            backgroundColor: Colors.green,
            textColor: Colors.white,
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(),
            ),
          );
        }

      } on FirebaseAuthException catch (e) {

        String message = '';

        if (e.code == 'user-not-found') {

          message = 'No user found with this email';

        } else if (e.code == 'wrong-password') {

          message = 'Wrong password provided';

        } else if (e.code == 'invalid-email') {

          message = 'Invalid email format';

        } else {

          message = 'Login failed: ${e.message}';
        }

        Fluttertoast.showToast(
          msg: message,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          toastLength: Toast.LENGTH_LONG,
        );

      } finally {

        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: EdgeInsets.all(24),

      child: Form(
        key: _formkey,

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [

            Icon(
              Icons.lock_outline,
              size: 80,
              color: Colors.blue,
            ),

            SizedBox(height: 20),

            Text(
              'Welcome Back',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 30),

            // EMAIL
            TextFormField(
              controller: _emailController,

              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              validator: (value) {

                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }

                if (!value.contains('@') ||
                    !value.contains('.')) {

                  return 'Please enter a valid email';
                }

                return null;
              },

              keyboardType: TextInputType.emailAddress,
            ),

            SizedBox(height: 20),

            // PASSWORD
            TextFormField(
              controller: _passwordController,
              obscureText: _obscureText,

              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock),

                suffixIcon: IconButton(
                  onPressed: () {

                    setState(() {
                      _obscureText = !_obscureText;
                    });

                  },

                  icon: Icon(
                    _obscureText
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                ),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              validator: (value) {

                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }

                if (value.length < 6) {
                  return 'Password must be at least 6 character';
                }

                return null;
              },
            ),

            SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,

              child: ElevatedButton(

                onPressed: _isLoading ? null : _login,

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                child: _isLoading

                    ? CircularProgressIndicator(
                        color: Colors.white,
                      )

                    : Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {

    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }
}