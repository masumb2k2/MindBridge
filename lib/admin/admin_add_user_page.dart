import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class AdminAddUserPage extends StatefulWidget {
  const AdminAddUserPage({Key? key}) : super(key: key);

  @override
  _AdminAddUserPageState createState() => _AdminAddUserPageState();
}

class _AdminAddUserPageState extends State<AdminAddUserPage> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  String email = '';
  String password = '';
  String firstName = '';
  String lastName = '';
  String phoneNumber = '';
  String city = 'Natore';
  String userType = 'Patient';

  bool _isLoading = false;

  Future<void> _addUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Create user with email and password
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        User? newUser = userCredential.user;

        if (newUser != null) {
          String uid = newUser.uid;
          String userPath = userType == 'Doctor' ? 'Doctors' : 'Patients';

          // Prepare user data
          Map<String, dynamic> userData = {
            'uid': uid,
            'email': email,
            'firstName': firstName,
            'lastName': lastName,
            'phoneNumber': phoneNumber,
            'city': city,
            'userType': userType,
          };

          // Store user data in Realtime Database
          await _database.child(userPath).child(uid).set(userData);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('User added successfully')),
          );

          // Clear form fields
          _formKey.currentState!.reset();
        }
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.message}')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New User'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Email
              TextFormField(
                decoration: InputDecoration(labelText: 'Email'),
                onChanged: (value) => email = value,
                validator: (value) =>
                value!.isEmpty ? 'Please enter an email' : null,
              ),
              // Password
              TextFormField(
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                onChanged: (value) => password = value,
                validator: (value) => value!.length < 6
                    ? 'Password must be at least 6 characters'
                    : null,
              ),
              // First Name
              TextFormField(
                decoration: InputDecoration(labelText: 'First Name'),
                onChanged: (value) => firstName = value,
                validator: (value) =>
                value!.isEmpty ? 'Please enter first name' : null,
              ),
              // Last Name
              TextFormField(
                decoration: InputDecoration(labelText: 'Last Name'),
                onChanged: (value) => lastName = value,
                validator: (value) =>
                value!.isEmpty ? 'Please enter last name' : null,
              ),
              // Phone Number
              TextFormField(
                decoration: InputDecoration(labelText: 'Phone Number'),
                onChanged: (value) => phoneNumber = value,
                validator: (value) =>
                value!.isEmpty ? 'Please enter phone number' : null,
              ),
              // City
              DropdownButtonFormField<String>(
                value: city,
                items: ['Natore', 'Rajshahi', 'Dhaka']
                    .map((city) => DropdownMenuItem(
                  value: city,
                  child: Text(city),
                ))
                    .toList(),
                onChanged: (value) => setState(() {
                  city = value!;
                }),
                decoration: InputDecoration(labelText: 'City'),
              ),
              // User Type
              DropdownButtonFormField<String>(
                value: userType,
                items: ['Patient', 'Doctor']
                    .map((type) => DropdownMenuItem(
                  value: type,
                  child: Text(type),
                ))
                    .toList(),
                onChanged: (value) => setState(() {
                  userType = value!;
                }),
                decoration: InputDecoration(labelText: 'User Type'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addUser,
                child: Text('Add User'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
