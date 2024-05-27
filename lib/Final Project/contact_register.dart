import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'authenticator.dart';
import 'package:http/http.dart' as http;

Future<void> sendEmailVerification(String userEmail) async {
  const baseUrl = "https://rgvzg1.api.infobip.com";
  const apiKey =
      "adaee73495520cd93eb3b826b165fc58-47de7d22-e4c5-4ce4-ae0e-2702a7defbce";

  const sender = "ggwp46676285@gmail.com";
  final recipient = userEmail;
  const subject = "Registration Successful!";
  const body = "Thank you for registering to SECRET HEAVEN. Enjoy!";

  final url = Uri.parse('$baseUrl/email/2/send');

  final headers = {
    'Authorization': 'App $apiKey',
  };

  final request = http.MultipartRequest('POST', url)
    ..headers.addAll(headers)
    ..fields.addAll({
      'from': sender,
      'to': recipient,
      'subject': subject,
      'text': body,
    });

  try {
    final response = await http.Response.fromStream(await request.send());

    print('Email verification HTTP code: ${response.statusCode}');
    print('Email verification Response body: ${response.body}');
  } catch (e) {
    print('Email verification Error: $e');
  }
}

Future<void> sendVerification(String userEmail) async {
  await sendEmailVerification(userEmail);
}

class AccountRegister extends StatefulWidget {
  const AccountRegister({super.key});

  @override
  State<AccountRegister> createState() => _AccountRegisterState();
}

class _AccountRegisterState extends State<AccountRegister> {
  TextEditingController namecontroller = TextEditingController();
  TextEditingController emailcontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();
  TextEditingController cpasswordcontroller = TextEditingController();

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
    TextStyle titleStyle(Color? color, String? fFam, double? size) => TextStyle(
          fontSize: (size) == null ? 30 : size,
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
            style: titleStyle(null, null, null),
          ),
          const SizedBox(width: 5.5),
          Text(
            'Heaven',
            style: titleStyle(Colors.blue, 'Cursive', 40),
          ),
        ],
      );
    }

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

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          onPressed: () => {Navigator.pop(context)},
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 25),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                setTitle(),
                const SizedBox(height: 20),
                inputTexfield(
                    'Enter Email', Icons.email, emailcontroller, false),
                const SizedBox(height: 15),
                inputTexfield('Enter Password', Icons.remove_red_eye,
                    passwordcontroller, true),
                const SizedBox(height: 15),
                inputTexfield('Enter Confirm Password', Icons.remove_red_eye,
                    cpasswordcontroller, true),
                const SizedBox(height: 15),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    minimumSize: const Size.fromHeight(50),
                  ),
                  onPressed: () {
                    registerUser();
                  },
                  child: const Text('REGISTER'),
                ),
                const SizedBox(height: 15),
                TextButton(
                  onPressed: () {
                    goToLoginPage();
                  },
                  child: const Text(
                    'Already have an account?',
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
    fontSize: 38,
  );

  showError() {
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
  }

  sendEmail() async {
    // Send registration confirmation email
    final userEmail = emailcontroller.text.trim();
    await sendVerification(userEmail);
  }

  Future<void> registerUser() async {
    if (passwordcontroller.text != cpasswordcontroller.text) {
      setState(() {
        isError = true;
        errormessage = "Password and Confirm Password do not match.";
        showError();
      });
      return;
    }

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailcontroller.text.trim(),
        password: passwordcontroller.text.trim(),
      );

      setState(() {
        isError = false;
        errormessage = "";
      });
      sendEmail();
      goToAuthenticator();
    } on FirebaseAuthException catch (e) {
      setState(() {
        isError = true;
        errormessage = e.message.toString();
        showError();
      });
    }
  }

  goToAuthenticator() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AccountAuthenticator(),
      ),
    );
  }

  goToLoginPage() {
    Navigator.pop(context);
  }
}
