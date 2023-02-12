import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_login_signup/widgets/loading.dart';
import 'package:google_sign_in/google_sign_in.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _username = '';

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    setState(() => isLoading = true);
    try {
      _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .get()
          .then((value) {
        setState(() {
          _username = value['username'];
          isLoading = false;
        });
      });
    } catch (e) {
      setState(() => isLoading = false);
      _username = '(username could not be retrieved)';
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // appBar: AppBar(
        //   title: const Text('Home'),
        // ),
        body: Stack(
      children: [
        Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child: Column(
                children: [
                  Text(
                      "Welcome $_username!${_auth.currentUser != null ? "\n\nYou're email is ${_auth.currentUser!.emailVerified ? 'verified' : 'not verified'}" : ''}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 35),
                  if (_auth.currentUser != null &&
                      !_auth.currentUser!.emailVerified)
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () async {
                                setState(() => isLoading = true);
                                try {
                                  await _auth.currentUser!
                                      .sendEmailVerification()
                                      .then((value) {
                                    setState(() => isLoading = false);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content:
                                            Text('Verification email sent!'),
                                      ),
                                    );
                                  });
                                } catch (e) {
                                  setState(() => isLoading = false);
                                  if (e is FirebaseAuthException &&
                                      e.code == 'too-many-requests') {
                                    setState(() => isLoading = false);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'Too many requests. Please try again later.')));
                                    return;
                                  }
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('An error occured!')));
                                  return;
                                }
                              },
                              style: ButtonStyle(
                                shape: MaterialStateProperty.all(
                                  const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(25),
                                        bottomLeft: Radius.circular(25)),
                                  ),
                                ),
                                minimumSize: MaterialStateProperty.all(
                                    const Size(100, 50)),
                                shadowColor: MaterialStateProperty.all(
                                    Colors.transparent),
                              ),
                              child: const Text('Resend verification email',
                                  style: TextStyle(fontSize: 16)),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                setState(() => isLoading = true);
                                try {
                                  await _auth.currentUser!.reload().then(
                                      (value) =>
                                          setState(() => isLoading = false));
                                } catch (e) {
                                  setState(() => isLoading = false);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('An error occured!')));
                                  return;
                                }
                              },
                              style: ButtonStyle(
                                shape: MaterialStateProperty.all(
                                  const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(25),
                                          bottomRight: Radius.circular(25))),
                                ),
                                minimumSize: MaterialStateProperty.all(
                                    const Size(100, 50)),
                                shadowColor: MaterialStateProperty.all(
                                    Colors.transparent),
                              ),
                              child: const Text('Refresh',
                                  style: TextStyle(fontSize: 16)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 35),
                      ],
                    ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context)
                        .pushReplacementNamed('/profile-settings'),
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
                    child: const Text('Profile settings',
                        style: TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(height: 35),
                  ElevatedButton(
                    onPressed: () async {
                      setState(() => isLoading = true);
                      try {
                        await GoogleSignIn().signOut();
                        await _auth.signOut().then((value) =>
                            Navigator.of(context)
                                .pushReplacementNamed('/login'));
                      } catch (e) {
                        setState(() => isLoading = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('An error occured')));
                        return;
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
                    child: const Text('Logout', style: TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/users'),
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
                    child: const Text('Users', style: TextStyle(fontSize: 16)),
                  )
                ],
              ),
            ),
          ),
        ),
        if (isLoading) const Loading(),
      ],
    ));
  }
}
