import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_clyde/Final%20Project/contacts.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class UpdateContactData extends StatefulWidget {
  const UpdateContactData({
    Key? key,
    required this.contacts,
  }) : super(key: key);

  final Contacts contacts;

  @override
  State<UpdateContactData> createState() => _UpdateContactDataState();
}

class _UpdateContactDataState extends State<UpdateContactData> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  late String errorMessage;
  late bool isError;
  late bool isUpdating;
  late double uploadProgress;

  // Image Upload
  PlatformFile? pickedFile;
  UploadTask? uploadTask;

  @override
  void initState() {
    errorMessage = "";
    isError = false;
    isUpdating = false;
    uploadProgress = 0.0;
    nameController.text = widget.contacts.name;
    emailController.text = widget.contacts.email;
    phoneController.text = widget.contacts.phone;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> updateContact(String id) async {
    setState(() {
      isUpdating = true;
    });

    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        phoneController.text.isEmpty) {
      setError("All fields must be filled.");
      setState(() {
        isUpdating = false;
      });
      return;
    }

    if (!isValidEmail(emailController.text)) {
      setError("Invalid email format.");
      setState(() {
        isUpdating = false;
      });
      return;
    }

    if (!isValidPhoneNumber(phoneController.text)) {
      setError("Invalid phone number format.");
      setState(() {
        isUpdating = false;
      });
      return;
    }

    String urlDownload = await uploadImage();

    if (urlDownload.isEmpty) {
      urlDownload = widget.contacts.image.toString();
    }

    final docContact =
        FirebaseFirestore.instance.collection('Contacts').doc(id);
    docContact.update({
      'name': nameController.text,
      'email': emailController.text,
      'phone': phoneController.text,
      'image': urlDownload,
    }).then((_) {
      setState(() {
        isUpdating = false;
        clearFields();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            content: Text(
              "Contact Updated Successfuly",
              style: TextStyle(
                color: Colors.green,
              ),
            ),
          ),
        );
        Navigator.pop(context);
      });
    }).catchError((error) {
      setState(() {
        isUpdating = false;
        setError("Error updating contact: $error");
      });
    });
  }

  Future<String> uploadImage() async {
    if (pickedFile == null) {
      return ''; // No image selected
    }

    final path = 'images/${'${generateRandomString(5)}-${pickedFile!.name}'}';
    final file = File(pickedFile!.path!);
    final ref = FirebaseStorage.instance.ref().child(path);

    uploadTask = ref.putFile(file);
    uploadTask!.snapshotEvents.listen((TaskSnapshot snapshot) {
      setState(() {
        uploadProgress = snapshot.bytesTransferred / snapshot.totalBytes;
      });
    });

    await uploadTask!.whenComplete(() {});

    final urlDownload = await ref.getDownloadURL();
    return urlDownload;
  }

  String generateRandomString(int len) {
    var random = Random();
    const chars =
        'AaBbCcDdEeFfGgHhIiJjKkL1MmNn00PpQqRrSsTtUuVvWwXxYyZz1234567890';

    return List.generate(len, (index) => chars[random.nextInt(chars.length)])
        .join();
  }

  void setError(String message) {
    setState(() {
      errorMessage = message;
      isError = true;
    });

    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        errorMessage = "";
        isError = false;
      });
    });
  }

  bool isValidEmail(String email) {
    return email.contains('@');
  }

  bool isValidPhoneNumber(String phoneNumber) {
    return RegExp(r'^[0-9]+$').hasMatch(phoneNumber);
  }

  void clearFields() {
    emailController.clear();
    nameController.clear();
    phoneController.clear();
    setError("");
  }

  TextStyle titleStyle(Color? color, String? fFam, double? size) => TextStyle(
        fontSize: (size) == null ? 30 : size,
        fontWeight: FontWeight.bold,
        color: color,
        fontFamily: fFam,
      );

  setTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          'Secret ',
          style: titleStyle(Colors.black, null, 17),
        ),
        const SizedBox(width: 5),
        Text(
          'Heaven',
          style: titleStyle(Colors.blue, 'Cursive', 20),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: setTitle(),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 15),
                checkImage(),
                TextButton.icon(
                  onPressed: () {
                    selectFile();
                  },
                  icon: const Icon(Icons.add_a_photo),
                  label: const Text('Select a photo'),
                ),
                const SizedBox(height: 15),
                roundedTextField(
                  'Enter Name',
                  Icons.person,
                  nameController,
                  false,
                ),
                const SizedBox(height: 15),
                roundedTextField(
                  'Enter Email',
                  Icons.email,
                  emailController,
                  false,
                ),
                const SizedBox(height: 15),
                roundedTextField(
                  'Enter Phone',
                  Icons.phone,
                  phoneController,
                  false,
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    minimumSize: const Size.fromHeight(50),
                  ),
                  onPressed: () {
                    updateContact(widget.contacts.id);
                  },
                  child: isUpdating
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('UPDATING'),
                            SizedBox(width: 10),
                            CircularProgressIndicator(
                              strokeWidth: 3.0,
                              color: Colors.white70,
                              backgroundColor: Colors.white54,
                            ),
                          ],
                        )
                      : const Text('SAVE'),
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
      ),
    );
  }

  TextField roundedTextField(
    String labelTxt,
    IconData iconData,
    TextEditingController controller,
    bool isPassword,
  ) {
    return TextField(
      obscureText: isPassword,
      controller: controller,
      decoration: InputDecoration(
        border: const UnderlineInputBorder(),
        labelText: labelTxt,
        prefixIcon: Icon(iconData),
      ),
    );
  }

  Future selectFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return;

    setState(() {
      pickedFile = result.files.first;
    });
  }

  Widget checkImage() {
    return (pickedFile != null)
        ? CircleAvatar(
            radius: 65,
            backgroundImage: FileImage(File(pickedFile!.path!)),
          )
        : (widget.contacts.image.isNotEmpty)
            ? CircleAvatar(
                radius: 65,
                backgroundImage: NetworkImage(widget.contacts.image),
              )
            : const CircleAvatar(
                radius: 65,
                backgroundImage: AssetImage('images/no-image.png'),
              );
  }
}
