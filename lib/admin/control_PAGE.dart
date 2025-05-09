import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({Key? key}) : super(key: key);

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Management'),
      ),
      body: StreamBuilder(
        stream: _database.onValue,
        builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
          if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
            final data = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
            final patients = data['Patients'] as Map<dynamic, dynamic>? ?? {};
            final doctors = data['Doctors'] as Map<dynamic, dynamic>? ?? {};

            final allUsers = [
              ...patients.entries.map((e) => {'type': 'Patient', 'uid': e.key, ...e.value}),
              ...doctors.entries.map((e) => {'type': 'Doctor', 'uid': e.key, ...e.value}),
            ];

            return ListView.builder(
              itemCount: allUsers.length,
              itemBuilder: (context, index) {
                final user = allUsers[index];
                return ListTile(
                  title: Text('${user['firstName']} ${user['lastName']}'),
                  subtitle: Text('${user['email']} (${user['type']})'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          _showEditUserDialog(user);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          _deleteUser(user['uid'], user['type']);
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _showAddUserDialog,
      //   child: Icon(Icons.add),
      // ),
    );
  }

  void _showAddUserDialog() {
    // Implement the dialog to add a new user
  }

  void _showEditUserDialog(Map user) {
    final _formKey = GlobalKey<FormState>();
    String firstName = user['firstName'];
    String lastName = user['lastName'];
    String email = user['email'];
    String phoneNumber = user['phoneNumber'];
    String city = user['city'];
    String qualification = user['qualification'] ?? '';
    String category = user['category'] ?? '';
    String yearsOfExperience = user['yearsOfExperience'] ?? '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit User'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    initialValue: firstName,
                    decoration: InputDecoration(labelText: 'First Name'),
                    onChanged: (value) => firstName = value,
                  ),
                  TextFormField(
                    initialValue: lastName,
                    decoration: InputDecoration(labelText: 'Last Name'),
                    onChanged: (value) => lastName = value,
                  ),
                  TextFormField(
                    initialValue: email,
                    decoration: InputDecoration(labelText: 'Email'),
                    onChanged: (value) => email = value,
                  ),
                  TextFormField(
                    initialValue: phoneNumber,
                    decoration: InputDecoration(labelText: 'Phone Number'),
                    onChanged: (value) => phoneNumber = value,
                  ),
                  TextFormField(
                    initialValue: city,
                    decoration: InputDecoration(labelText: 'City'),
                    onChanged: (value) => city = value,
                  ),
                  if (user['type'] == 'Doctor') ...[
                    TextFormField(
                      initialValue: qualification,
                      decoration: InputDecoration(labelText: 'Qualification'),
                      onChanged: (value) => qualification = value,
                    ),
                    TextFormField(
                      initialValue: category,
                      decoration: InputDecoration(labelText: 'Category'),
                      onChanged: (value) => category = value,
                    ),
                    TextFormField(
                      initialValue: yearsOfExperience,
                      decoration: InputDecoration(labelText: 'Years of Experience'),
                      onChanged: (value) => yearsOfExperience = value,
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final userTypePath = user['type'] == 'Doctor' ? 'Doctors' : 'Patients';
                final updatedUser = {
                  'firstName': firstName,
                  'lastName': lastName,
                  'email': email,
                  'phoneNumber': phoneNumber,
                  'city': city,
                };
                if (user['type'] == 'Doctor') {
                  updatedUser['qualification'] = qualification;
                  updatedUser['category'] = category;
                  updatedUser['yearsOfExperience'] = yearsOfExperience;
                }
                await FirebaseDatabase.instance
                    .ref()
                    .child('$userTypePath/${user['uid']}')
                    .update(updatedUser);
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _deleteUser(String uid, String userType) async {
    final userTypePath = userType == 'Doctor' ? 'Doctors' : 'Patients';
    await _database.child('$userTypePath/$uid').remove();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('User deleted successfully')),
    );
  }
}
