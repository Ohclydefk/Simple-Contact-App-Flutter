import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_clyde/Final%20Project/contact_list.dart';
import 'package:firebase_clyde/Final%20Project/contact_login.dart';
import 'package:flutter/material.dart';

class AccountAuthenticator extends StatefulWidget {
  const AccountAuthenticator({super.key});

  @override
  State<AccountAuthenticator> createState() => _AccountAuthenticatorState();
}

class _AccountAuthenticatorState extends State<AccountAuthenticator> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Something went wrong',
                style: TextStyle(color: Colors.red),
              ),
            );
          } else if (snapshot.hasData) {
            var email = snapshot.data!.email;
            return AllContactsData(loggedInEmail: email.toString());
          } else {
            return const ContactLogin();
          }
        },
      ),
    );
  }
}
