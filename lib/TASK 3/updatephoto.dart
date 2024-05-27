import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_clyde/Final%20Project/contacts.dart';
import 'package:flutter/material.dart';

class UpdateData extends StatefulWidget {
  const UpdateData({
    Key? key,
    required this.contacts,
  }) : super(key: key);

  final Contacts contacts;

  @override
  State<UpdateData> createState() => _UpdateDataState();
}

class _UpdateDataState extends State<UpdateData> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  late String errorMessage;
  late bool isError;

  @override
  void initState() {
    errorMessage = "This is an error";
    isError = false;
    nameController.text = widget.contacts.name;
    emailController.text = widget.contacts.email;
    phoneController.text = widget.contacts.phone;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Future<void> updateContact(String id) async {
      final docContact = FirebaseFirestore.instance.collection('Contacts').doc(id);
      docContact.update({
        'name': nameController.text,
        'email': emailController.text,
        'phone': phoneController.text,
      });

      setState(() {
        nameController.clear();
        emailController.clear();
        phoneController.clear();
        Navigator.pop(context);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Data'),
        automaticallyImplyLeading: true,
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'UPDATE DATA',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  fontSize: 38,
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Enter name',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Enter Email Address',
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Enter Phone Number',
                  prefixIcon: Icon(Icons.phone),
                ),
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                onPressed: () {
                  updateContact(widget.contacts.id);
                },
                child: const Text('SAVE'),
              ),
              const SizedBox(height: 15),
              (isError)
                  ? Text(
                      errorMessage,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                        letterSpacing: 1,
                        fontSize: 18,
                      ),
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
