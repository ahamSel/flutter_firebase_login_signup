import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_login_signup/widgets/loading.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder(
      stream: _firestore.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(
              child: Text('Error!\n\nTry reloading the app.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red, fontSize: 20)),
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Loading(),
          );
        }
        return SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(20),
            alignment: Alignment.topCenter,
            child: Wrap(
              spacing: 20,
              runSpacing: 20,
              children: snapshot.data!.docs.map((document) {
                Map data = document.data();
                return GestureDetector(
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text(data['username'],
                                style: const TextStyle(fontSize: 20)),
                            content: Text(data['email'],
                                style: const TextStyle(fontSize: 16)),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Close',
                                      style: TextStyle(fontSize: 17)))
                            ],
                          );
                        });
                  },
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 50,
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: 100,
                        child: Text(data['username'],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                overflow: TextOverflow.ellipsis,
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: 100,
                        child: Text(data['email'],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                overflow: TextOverflow.ellipsis,
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.normal)),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    ));
  }
}
