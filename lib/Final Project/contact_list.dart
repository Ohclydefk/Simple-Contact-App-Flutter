import 'package:firebase_clyde/Final%20Project/add_contact.dart';
import 'package:firebase_clyde/Final%20Project/contact_login.dart';
import 'package:firebase_clyde/Final%20Project/contacts.dart';
import 'package:firebase_clyde/Final%20Project/update_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AllContactsData extends StatefulWidget {
  const AllContactsData({
    Key? key,
    required this.loggedInEmail,
  }) : super(key: key);

  final String loggedInEmail;

  @override
  State<AllContactsData> createState() => _AllContactsDataState();
}

class _AllContactsDataState extends State<AllContactsData> {
  late TextEditingController searchController;

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
  }

  Stream<List<Contacts>> readUsers() {
    return FirebaseFirestore.instance
        .collection('Contacts')
        .where('user', isEqualTo: widget.loggedInEmail.toString())
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Contacts.fromJson(doc.data()))
              .toList(),
        );
  }

  Widget buildList(Contacts contact) {
    return InkWell(
      onLongPress: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UpdateContactData(contacts: contact),
          ),
        );
      },
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.red,
          radius: 30,
          child: CircleAvatar(
            backgroundImage: NetworkImage(contact.image),
            radius: 25,
          ),
        ),
        title: Text(contact.name),
        subtitle: Text(contact.phone),
        dense: true,
        onTap: () {},
        trailing: PopupMenuButton<String>(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Text('Edit'),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Text('Delete'),
            ),
          ],
          onSelected: (value) {
            switch (value) {
              case 'edit':
                {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          UpdateContactData(contacts: contact),
                    ),
                  );
                }

              case 'delete':
                {
                  deleteUser(contact.id, contact.name);
                }
            }
          },
        ),
      ),
    );
  }

  Future performDeleteUser(String id) async {
    final docUser = FirebaseFirestore.instance.collection('Contacts').doc(id);
    docUser.delete();
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
        title: setTitle(),
        iconTheme: const IconThemeData(color: Colors.black),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * .9,
              child: TextFormField(
                controller: searchController,
                onChanged: (value) {
                  setState(() {});
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  label: Text("Search"),
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
          ),
        ),
        backgroundColor:
            Colors.transparent, // Set background color to transparent
        elevation: 0,
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    maxRadius: 32,
                    child: Text(widget.loggedInEmail.isNotEmpty
                        ? widget.loggedInEmail[0].toUpperCase()
                        : ''),
                  ),
                  const SizedBox(height: 10),
                  Text(widget.loggedInEmail.toString()),
                ],
              ),
            ),
            ListTile(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Logged Out")),
                );
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const ContactLogin(),
                  ),
                );
              },
              leading: const Icon(Icons.logout_outlined),
              title: const Text("Logout"),
            ),
          ],
        ),
      ),
      body: StreamBuilder<List<Contacts>>(
        builder: ((context, snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong! ${snapshot.error}');
          } else if (snapshot.hasData) {
            final contacts = snapshot.data!;
            if (contacts.isEmpty) {
              // Display message when there are no contacts
              return Center(
                child: Text('No contacts for ${widget.loggedInEmail}'),
              );
            } else {
              // Apply search filter to contacts
              final filteredContacts = contacts
                  .where((contact) => contact.name
                      .toLowerCase()
                      .contains(searchController.text.toLowerCase()))
                  .toList();

              if (filteredContacts.isEmpty &&
                  searchController.text.isNotEmpty) {
                // Display message when no matching contacts found
                return const Center(
                  child: Text('No matching contacts found'),
                );
              }

              return ListView(
                children: filteredContacts.map((buildList)).toList(),
              );
            }
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        }),
        stream: readUsers(),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () {
          goToAddContacts();
        },
        child: const Icon(Icons.person_add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Future<void> deleteUser(String id, String contactName) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          clipBehavior: Clip.hardEdge,
          title: const Text('Remove User'),
          content: Text('Are you sure you want to delete $contactName'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                performDeleteUser(id);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  goToAddContacts() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            AddContactData(loggedInEmail: widget.loggedInEmail),
      ),
    );
  }
}
