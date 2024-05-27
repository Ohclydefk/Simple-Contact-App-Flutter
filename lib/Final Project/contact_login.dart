import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_clyde/Final%20Project/contact_register.dart';
import 'package:firebase_clyde/Final%20Project/authenticator.dart';
import 'package:flutter/material.dart';

class ContactLogin extends StatefulWidget {
  const ContactLogin({super.key});

  @override
  State<ContactLogin> createState() => _ContactLoginState();
}

class _ContactLoginState extends State<ContactLogin> {
  TextEditingController usernamecontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();
  late String errormessage;
  late bool isError;

  @override
  void initState() {
    errormessage = "This is an error";
    isError = false;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Container inputTexfield(String label, IconData icon,
            TextEditingController controller, bool isPassword) =>
        Container(
          margin: const EdgeInsets.only(bottom: 10),
          child: TextField(
            obscureText: isPassword,
            controller: controller,
            decoration: InputDecoration(
              labelText: label,
              icon: Icon(icon),
            ),
            onChanged: (value) {},
          ),
        );

    TextStyle titleStyle(Color? color, String? fFam, {double? size = 30}) =>
        TextStyle(
          fontSize: size,
          fontWeight: FontWeight.bold,
          color: color,
          fontFamily: fFam,
        );

    setTitle() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Secret ',
            style: titleStyle(null, null),
          ),
          const SizedBox(width: 5.5),
          Text(
            'Heaven',
            style: titleStyle(Colors.blue, 'Cursive', size: 40),
          ),
        ],
      );
    }

    return Scaffold(
      body: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              setTitle(),
              const SizedBox(height: 20),
              inputTexfield(
                  'Enter Email', Icons.email, usernamecontroller, false),
              const SizedBox(height: 10),
              inputTexfield('Enter Password', Icons.remove_red_eye,
                  passwordcontroller, true),
              const SizedBox(height: 15),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  minimumSize: const Size.fromHeight(50),
                ),
                onPressed: () {
                  checkLogin(
                    usernamecontroller.text,
                    passwordcontroller.text,
                  );
                },
                child: const Text('LOGIN'),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  goToRegisterPage();
                },
                child: const Text(
                  'REGISTER HERE',
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }

  var errortxtstyle = const TextStyle(
    fontWeight: FontWeight.bold,
    color: Colors.red,
    letterSpacing: 1,
    fontSize: 18,
  );
  var txtstyle = const TextStyle(
    fontWeight: FontWeight.bold,
    letterSpacing: 2,
    fontSize: 22,
  );

  Future checkLogin(username, password) async {
    showDialog(
      useRootNavigator: false,
      barrierDismissible: false,
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: username,
        password: password,
      );
      setState(() {
        isError = false;
        errormessage = "";
        Navigator.of(context).pop();
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        isError = true;
        errormessage = e.message ?? "An error occurred";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(
              child: Text(
                errormessage,
                style: errortxtstyle,
              ),
            ),
            backgroundColor: Colors.white,
            elevation: 2,
          ),
        );
      });
    } finally {
      if (!isError) {
        setState(() {
          goToAuthenticator();
        });
      } else {
        setState(() {
          Navigator.of(context).pop();
        });
      }
    }
  }

  goToRegisterPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AccountRegister()),
    );
  }

  goToAuthenticator() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AccountAuthenticator(),
      ),
    );
  }
}
