import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_login_signup/widgets/loading.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final _formKey = GlobalKey<FormState>();

  bool isLoading = false;

  late String _email;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // appBar: AppBar(
        //   title: const Text('Reset Password'),
        // ),
        body: Stack(
      children: [
        Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const Text(
                      'Reset your password',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 40),
                    const Text(
                      'Please enter your email and we will send you a link to reset your password',
                      style: TextStyle(
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      validator: (value) {
                        if (!RegExp(
                                r"^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@((?:[a-zA-Z0-9-]+\.)+(?:[a-zA-Z]{2,}))$")
                            .hasMatch(value!.trim())) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                      onSaved: (value) => _email = value!.trim(),
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 35),
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          setState(() => isLoading = true);
                          try {
                            List<String> signInMethods =
                                await _auth.fetchSignInMethodsForEmail(_email);
                            if (signInMethods.contains('google.com') &&
                                !signInMethods.contains('password')) {
                              setState(() => isLoading = false);
                              Future.delayed(const Duration())
                                  .then((value) => showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return const SimpleDialog(
                                              insetPadding: EdgeInsets.all(17),
                                              titlePadding: EdgeInsets.all(17),
                                              titleTextStyle: TextStyle(
                                                  fontSize: 17,
                                                  color: Colors.deepPurple),
                                              title: Text(
                                                  'This email is associated with a Google sign in. Please sign in with Google and add a new password in your profile settings to link your account with an email and password login option.\n\nThis can also be caused if you have signed in with Google before verifying your email.',
                                                  textAlign: TextAlign.left));
                                        },
                                      ));
                              return;
                            }
                            await _auth
                                .sendPasswordResetEmail(email: _email)
                                .then((value) {
                              setState(() => isLoading = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Password reset email sent!'),
                                ),
                              );
                            });
                          } on FirebaseAuthException catch (e) {
                            setState(() => isLoading = false);
                            if (e.code == 'user-not-found') {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('No user found for this email.'),
                                ),
                              );
                            } else if (e.code == 'invalid-email') {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Invalid email.'),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Something went wrong!'),
                                ),
                              );
                            }
                            return;
                          } catch (e) {
                            setState(() => isLoading = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('An error occured!'),
                              ),
                            );
                            return;
                          }
                        }
                      },
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        minimumSize:
                            MaterialStateProperty.all(const Size(100, 50)),
                        shadowColor:
                            MaterialStateProperty.all(Colors.transparent),
                      ),
                      child: const Text('Send', style: TextStyle(fontSize: 16)),
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacementNamed('/login');
                      },
                      child: const Text('Back to Login',
                          style: TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (isLoading) const Loading(),
      ],
    ));
  }
}
