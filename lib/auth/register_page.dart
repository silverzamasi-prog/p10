import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:p10/page/home_page.dart';
import 'package:fluttertoast/fluttertoast.dart';

class RegisterPage extends StatefulWidget {
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();

  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;
  bool _obscureText = true;
  bool _obscureConfirmText = true;

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        UserCredential userCredential = await _auth
            .createUserWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
            );

        if (userCredential.user != null) {
          await userCredential.user!.updateDisplayName(
            _nameController.text.trim(),
          );

          await userCredential.user!.reload();

          Fluttertoast.showToast(
            msg: 'Registration Success',
            backgroundColor: Colors.green,
            textColor: Colors.white,
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        }
      } on FirebaseAuthException catch (e) {
        String message = '';

        if (e.code == 'email-already-in-use') {
          message = 'This email is already registered';
        } else if (e.code == 'weak-password') {
          message = 'Password too weak';
        } else if (e.code == 'invalid-email') {
          message = 'Invalid email format';
        } else {
          message = 'Registration failed';
        }

        Fluttertoast.showToast(
          msg: message,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          toastLength: Toast.LENGTH_LONG,
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),

      body: Padding(
        padding: EdgeInsets.all(20),

        child: SingleChildScrollView(
          child: Form(
            key: _formKey,

            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_add, size: 80, color: Colors.blue),

                SizedBox(height: 20),

                Text(
                  'Create Account',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),

                SizedBox(height: 20),

                // FULL NAME
                TextFormField(
                  controller: _nameController,

                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }

                    if (value.length < 3) {
                      return 'Name must be at least 3 character';
                    }

                    return null;
                  },
                ),

                SizedBox(height: 20),

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

                    if (!value.contains('@') || !value.contains('.')) {
                      return 'Please enter valid email';
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
                        _obscureText ? Icons.visibility : Icons.visibility_off,
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
                      return 'Password minimal 6 character';
                    }

                    return null;
                  },
                ),

                SizedBox(height: 20),

                // CONFIRM PASSWORD
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmText,

                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    prefixIcon: Icon(Icons.lock_outline),

                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscureConfirmText = !_obscureConfirmText;
                        });
                      },

                      icon: Icon(
                        _obscureConfirmText
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
                      return 'Please confirm your password';
                    }

                    if (value != _passwordController.text) {
                      return 'Password do not match';
                    }

                    return null;
                  },
                ),

                SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 50,

                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _register,

                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),

                    child: _isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'Register',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }
}
