import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_login_signup/widgets/loading.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late final bool _isGoogleUserOnly;

  final _formKey = GlobalKey<FormState>();

  bool isLoading = false;

  final Map<String, dynamic> _userData = {};

  late String _newUsername,
      _phoneNumber,
      _currentPassword = '',
      _newPassword = '';

  final List<String> _address = List.generate(6, (_) => '');

  late bool _somethingChanged;

  @override
  void initState() {
    super.initState();
    _somethingChanged = false;
    _isGoogleUserOnly = _auth.currentUser!.providerData.length == 1 &&
        _auth.currentUser!.providerData[0].providerId == 'google.com';
    setState(() => isLoading = true);
    try {
      _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .get()
          .then((value) {
        setState(() {
          _userData['username'] = value['username'];
          _userData['address'] = value['address'];
          _userData['phoneNumber'] = value['phoneNumber'];
          isLoading = false;
        });
      });
    } catch (e) {
      setState(() => isLoading = false);
      _userData['username'] = '(username could not be retrieved)';
      _userData['address'] = '(address could not be retrieved)';
      _userData['phoneNumber'] = '(phone number could not be retrieved)';
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        body: Stack(
          children: [
            Center(
                child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                child: Form(
                  key: _formKey,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(50),
                              ),
                            ),
                            const SizedBox(width: 60),
                            Expanded(
                              child: Text(
                                '''${_userData['username'] ?? ''}\n${_auth.currentUser!.email}${RegExp(r"[a-zA-Z0-9]").hasMatch(_userData['address'].toString()) ? "\n${_userData['address']}" : ''}${_userData['phoneNumber'] != '' ? "\n${_userData['phoneNumber']}" : ''}
                          ''',
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 35),
                        const Text("Address", style: TextStyle(fontSize: 17)),
                        const SizedBox(height: 14),
                        TextFormField(
                          onChanged: (value) => _address[0] = value.trim(),
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Apt / Suite / Other (optional)',
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          validator: (value) {
                            if (value!.trim().isNotEmpty) {
                              if (!RegExp(r"^[a-zA-Z0-9 .'-]*$")
                                  .hasMatch(value)) {
                                return 'Invalid street name';
                              }
                            } else if (_address
                                .any((element) => element.isNotEmpty)) {
                              return 'Street name is required';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Street',
                          ),
                          onSaved: (value) {
                            if (_address[1].isNotEmpty) {
                              _somethingChanged = true;
                            }
                          },
                          onChanged: (value) => _address[1] = value.trim(),
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          validator: (value) {
                            if (value!.trim().isNotEmpty) {
                              if (!RegExp(r"^[a-zA-Z .'-]*$").hasMatch(value)) {
                                return 'Invalid city name';
                              }
                            } else if (_address
                                .any((element) => element.isNotEmpty)) {
                              return 'City name is required';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'City',
                          ),
                          onChanged: (value) => _address[2] = value.trim(),
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'ZIP / Postal code (optional)',
                          ),
                          onChanged: (value) => _address[3] = value.trim(),
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'State / Province (optional)',
                          ),
                          onChanged: (value) => _address[4] = value.trim(),
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          validator: (value) {
                            if (value!.trim().isNotEmpty) {
                              if (!RegExp(r"^[a-zA-Z\s]+$").hasMatch(value)) {
                                return 'Invalid country name';
                              }
                            } else if (_address
                                .any((element) => element.isNotEmpty)) {
                              return 'Country name is required';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Country',
                          ),
                          onChanged: (value) => _address[5] = value.trim(),
                        ),
                        const SizedBox(height: 35),
                        const Text("Change your username",
                            style: TextStyle(fontSize: 17)),
                        const SizedBox(height: 14),
                        TextFormField(
                          validator: (value) {
                            if (value!.trim().isNotEmpty) {
                              if (value.length < 3 || value.length > 12) {
                                return 'Username must be between 3 and 12 characters';
                              } else if (value.contains(' ')) {
                                return 'Username cannot contain spaces';
                              }
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _newUsername = value!;
                            if (_newUsername.isNotEmpty) {
                              _somethingChanged = true;
                            }
                          },
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'New username',
                          ),
                        ),
                        const SizedBox(height: 35),
                        const Text("Add or change your phone number",
                            style: TextStyle(fontSize: 17)),
                        const SizedBox(height: 14),
                        TextFormField(
                          validator: (value) {
                            if (value!.trim().isNotEmpty &&
                                !RegExp(r'^\+(?:[0-9] ?){6,14}[0-9]$')
                                    .hasMatch(value)) {
                              return 'Please enter a valid phone number (e.g. +1 123 456 7890)';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _phoneNumber = value!.trim();
                            if (_phoneNumber.isNotEmpty) {
                              _somethingChanged = true;
                            }
                          },
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'New phone number',
                          ),
                        ),
                        const SizedBox(height: 35),
                        if (_isGoogleUserOnly)
                          Column(
                            children: [
                              const Text(
                                  "Add a new password to be able to login with email and password",
                                  style: TextStyle(fontSize: 17)),
                              const SizedBox(height: 7),
                              const Text(
                                  "You also need to do this if you've signed in with Google before verifying your email",
                                  style: TextStyle(fontSize: 13)),
                              const SizedBox(height: 14),
                              TextFormField(
                                obscureText: true,
                                validator: (value) {
                                  if (value!.isNotEmpty) {
                                    if (value.contains(' ')) {
                                      return 'Password cannot contain spaces';
                                    } else if (value.length < 6) {
                                      return 'Password must be at least 6 characters';
                                    }
                                  }
                                  return null;
                                },
                                onSaved: ((value) {
                                  _newPassword = value!;
                                  if (_newPassword.isNotEmpty) {
                                    _somethingChanged = true;
                                  }
                                }),
                                onChanged: (value) => _newPassword = value,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'New password',
                                ),
                              ),
                              const SizedBox(height: 14),
                              TextFormField(
                                obscureText: true,
                                validator: (value) {
                                  if (value != _newPassword) {
                                    return 'Passwords do not match';
                                  }
                                  return null;
                                },
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Confirm new password',
                                ),
                              ),
                              const SizedBox(height: 35)
                            ],
                          )
                        else
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Change your login details",
                                  style: TextStyle(fontSize: 17)),
                              const SizedBox(height: 14),
                              TextFormField(
                                validator: (value) {
                                  if (_newPassword.isNotEmpty) {
                                    if (value!.isEmpty) {
                                      return 'Current password is required';
                                    }
                                  }
                                  return null;
                                },
                                onChanged: (value) => _currentPassword = value,
                                obscureText: true,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Current password',
                                ),
                              ),
                              const SizedBox(height: 14),
                              TextFormField(
                                obscureText: true,
                                validator: (value) {
                                  if (value!.isNotEmpty) {
                                    if (value.contains(' ')) {
                                      return 'Password cannot contain spaces';
                                    } else if (value.length < 6) {
                                      return 'Password must be at least 6 characters';
                                    }
                                  }
                                  return null;
                                },
                                onSaved: ((value) {
                                  _newPassword = value!;
                                  if (_newPassword.isNotEmpty) {
                                    _somethingChanged = true;
                                  }
                                }),
                                onChanged: (value) => _newPassword = value,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'New password',
                                ),
                              ),
                              const SizedBox(height: 14),
                              TextFormField(
                                obscureText: true,
                                validator: (value) {
                                  if (value != _newPassword) {
                                    return 'Passwords do not match';
                                  }
                                  return null;
                                },
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Confirm new password',
                                ),
                              ),
                              const SizedBox(height: 35)
                            ],
                          ),
                        Center(
                          child: ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                _formKey.currentState!.save();
                                if (!_somethingChanged) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('No changes were made.'),
                                    ),
                                  );
                                  return;
                                }
                                setState(() => isLoading = true);
                                try {
                                  if (_newPassword.isNotEmpty) {
                                    try {
                                      if (_isGoogleUserOnly) {
                                        final GoogleSignInAccount?
                                            currentGoogleUser =
                                            await GoogleSignIn().signIn();
                                        final GoogleSignInAuthentication?
                                            googleAuth = await currentGoogleUser
                                                ?.authentication;
                                        await _auth.currentUser!
                                            .reauthenticateWithCredential(
                                                GoogleAuthProvider.credential(
                                              idToken: googleAuth?.idToken,
                                              accessToken:
                                                  googleAuth?.accessToken,
                                            ))
                                            .then((value) => _auth.currentUser!
                                                .linkWithCredential(
                                                    EmailAuthProvider
                                                        .credential(
                                                            email: _auth
                                                                .currentUser!
                                                                .email!,
                                                            password:
                                                                _newPassword)));
                                      } else {
                                        await _auth.currentUser!
                                            .reauthenticateWithCredential(
                                                EmailAuthProvider.credential(
                                                    email: _auth
                                                        .currentUser!.email!,
                                                    password: _currentPassword))
                                            .then((value) async => await _auth
                                                .currentUser!
                                                .updatePassword(_newPassword));
                                      }
                                    } on FirebaseAuthException catch (e) {
                                      setState(() => isLoading = false);
                                      if (e.code == 'wrong-password') {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                                content: Text(
                                                    'Wrong current password provided.')));
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                                content: Text(
                                                    'Something went wrong!')));
                                      }
                                      return;
                                    } catch (e) {
                                      setState(() => isLoading = false);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              content:
                                                  Text('An error occurred!')));
                                      return;
                                    }
                                  }
                                  if (_newUsername.isNotEmpty &&
                                      _newUsername != _userData['username']) {
                                    await _firestore
                                        .collection('users')
                                        .doc(_auth.currentUser!.uid)
                                        .update({'username': _newUsername});
                                  }
                                  if (_phoneNumber.isNotEmpty) {
                                    await _firestore
                                        .collection('users')
                                        .doc(_auth.currentUser!.uid)
                                        .update({'phoneNumber': _phoneNumber});
                                  }
                                  if (_address.isNotEmpty) {
                                    await _firestore
                                        .collection('users')
                                        .doc(_auth.currentUser!.uid)
                                        .update({
                                      'address':
                                          '${_address[0] != '' ? '${_address[0]}, ' : ''}${_address[1]}, ${_address[2]}, ${_address[3] != '' ? '${_address[3]}, ' : ''}${_address[4] != '' ? '${_address[4]}, ' : ''}${_address[5]}'
                                    });
                                  }
                                  setState(() => isLoading = false);
                                  Future.delayed(const Duration())
                                      .then((value) => showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return const SimpleDialog(
                                                insetPadding:
                                                    EdgeInsets.all(100),
                                                titlePadding:
                                                    EdgeInsets.all(20),
                                                titleTextStyle: TextStyle(
                                                    fontSize: 18,
                                                    color: Colors.deepPurple),
                                                title: Text('Profile Updated!',
                                                    textAlign:
                                                        TextAlign.center),
                                              );
                                            },
                                          ))
                                      .then((value) =>
                                          Navigator.pushReplacementNamed(
                                              context, '/profile-settings'));
                                } catch (e) {
                                  setState(() => isLoading = false);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('An error occurred!')));
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
                              minimumSize: MaterialStateProperty.all(
                                  const Size(100, 50)),
                              shadowColor:
                                  MaterialStateProperty.all(Colors.transparent),
                            ),
                            child: const Text("Save changes",
                                style: TextStyle(fontSize: 16)),
                          ),
                        ),
                        const SizedBox(height: 30),
                        Center(
                          child: ElevatedButton(
                            onPressed: () async {
                              setState(() => isLoading = true);
                              try {
                                await GoogleSignIn().signOut();
                                await _auth.signOut().then((value) =>
                                    Navigator.pushReplacementNamed(
                                        context, '/login'));
                              } catch (e) {
                                setState(() => isLoading = false);
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('An error occurred!')));
                                return;
                              }
                            },
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                              minimumSize: MaterialStateProperty.all(
                                  const Size(100, 50)),
                              shadowColor:
                                  MaterialStateProperty.all(Colors.transparent),
                            ),
                            child: const Text("Sign out",
                                style: TextStyle(fontSize: 16)),
                          ),
                        ),
                        const SizedBox(height: 30),
                        Center(
                          child: ElevatedButton(
                            onPressed: () async {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Delete account?'),
                                    content: const Text(
                                        'Are you sure you want to delete your account?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () async {
                                          setState(() => isLoading = true);
                                          Navigator.pop(context);
                                          try {
                                            if (_isGoogleUserOnly) {
                                              final GoogleSignInAccount?
                                                  googleUser =
                                                  await GoogleSignIn().signIn();
                                              final GoogleSignInAuthentication
                                                  googleAuth = await googleUser!
                                                      .authentication;
                                              await _auth.currentUser!
                                                  .reauthenticateWithCredential(
                                                      GoogleAuthProvider
                                                          .credential(
                                                accessToken:
                                                    googleAuth.accessToken,
                                                idToken: googleAuth.idToken,
                                              ));
                                            } else if (_currentPassword
                                                .isNotEmpty) {
                                              await _auth.currentUser!
                                                  .reauthenticateWithCredential(
                                                      EmailAuthProvider.credential(
                                                          email: _auth
                                                              .currentUser!
                                                              .email!,
                                                          password:
                                                              _currentPassword));
                                            }
                                            await _firestore
                                                .collection('users')
                                                .doc(_auth.currentUser!.uid)
                                                .delete();
                                            await GoogleSignIn().signOut();
                                            await _auth.currentUser!
                                                .delete()
                                                .then((value) => Navigator
                                                    .pushReplacementNamed(
                                                        _scaffoldKey
                                                            .currentContext!,
                                                        '/login'));
                                          } on FirebaseAuthException catch (e) {
                                            setState(() => isLoading = false);
                                            if (e.code == 'wrong-password') {
                                              ScaffoldMessenger.of(_scaffoldKey
                                                      .currentContext!)
                                                  .showSnackBar(const SnackBar(
                                                      content: Text(
                                                          'Wrong password provided.')));
                                            } else {
                                              ScaffoldMessenger.of(_scaffoldKey
                                                      .currentContext!)
                                                  .showSnackBar(const SnackBar(
                                                      content: Text(
                                                          'Something went wrong!')));
                                            }
                                            return;
                                          } catch (e) {
                                            setState(() => isLoading = false);
                                            ScaffoldMessenger.of(_scaffoldKey
                                                    .currentContext!)
                                                .showSnackBar(const SnackBar(
                                                    content: Text(
                                                        'An error occurred!')));
                                            return;
                                          }
                                        },
                                        child: const Text('Yes',
                                            style: TextStyle(fontSize: 17)),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('No',
                                            style: TextStyle(fontSize: 17)),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                              minimumSize: MaterialStateProperty.all(
                                  const Size(100, 50)),
                              shadowColor:
                                  MaterialStateProperty.all(Colors.transparent),
                            ),
                            child: const Text("Delete account",
                                style: TextStyle(fontSize: 16)),
                          ),
                        ),
                      ]),
                ),
              ),
            )),
            if (isLoading) const Loading(),
          ],
        ));
  }
}
