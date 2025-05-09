import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:MindBridge/auth/signup_screen.dart';
import 'package:MindBridge/doctor/doctor_home_page.dart';
import 'package:MindBridge/patient/patient_home_page.dart';
import '../admin/admin_home_page.dart';
import '../dev_phase.dart'; // Make sure this file exists

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  bool _isLoading = false;
  bool _isNavigation = false;
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Color(0xffffffff),
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 48),
                    CircleAvatar(
                      radius: 100,
                      backgroundImage: AssetImage('assets/images/profile.jpg'),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Welcome to MindBridge!',
                      style: GoogleFonts.poppins(
                        fontSize: 25,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff005FEE),
                      ),
                    ),
                    Text(
                      'Login First',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 60),
                    SizedBox(
                      height: 44,
                      child: TextFormField(
                        style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500),
                        decoration: _inputDecoration('Email', Icons.email_outlined),
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (val) => email = val,
                        validator: (val) => val!.isEmpty ? 'Enter an email' : null,
                      ),
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      height: 44,
                      child: TextFormField(
                        style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500),
                        decoration: _inputDecoration(
                          'Password',
                          Icons.lock_outline,
                          isPassword: true,
                        ),
                        obscureText: _obscureText,
                        keyboardType: TextInputType.text,
                        onChanged: (val) => password = val,
                        validator: (val) => val!.length < 6
                            ? 'Password must be at least 6 characters'
                            : null,
                      ),
                    ),
                    SizedBox(height: 20),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xff006AFA),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(35.0),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: Text(
                          'Login',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => RegisterPage()));
                        },
                        child: Text(
                          'Don’t have an account? Register',
                          style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Developed by masumb2k2',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 16,
                color: Color(0xff005FEE),
                fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon, {bool isPassword = false}) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: Color(0xff005FEE)),
      filled: true,
      fillColor: Color(0xfff0f5ff),
      contentPadding: EdgeInsets.symmetric(horizontal: 10),
      labelText: label,
      labelStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.black54),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(color: Color(0xfff0f5ff), width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(color: Color(0xff005FEE), width: 1.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(color: Color(0xfff0f5ff), width: 1.0),
      ),
      suffixIcon: isPassword
          ? IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_off : Icons.visibility,
          color: Color(0xff005FEE),
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      )
          : null,
    );
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        User? user = userCredential.user;

        if (user != null) {
          if (email == 'admin@gmail.com' && password == '654321') {
            _navigateToDevelopmentPhase();
            return;
          }

          DatabaseReference userRef = _database.child('Doctors').child(user.uid);
          DataSnapshot snapshot = await userRef.get();

          if (snapshot.exists) {
            _navigateToDoctorHome();
          } else {
            userRef = _database.child('Patients').child(user.uid);
            snapshot = await userRef.get();
            if (snapshot.exists) {
              _navigateToPatientHome();
            } else {
              _showErrorDialog('User not found');
            }
          }
        }
      } catch (e) {
        _showErrorDialog(e.toString());
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToDevelopmentPhase() {
    if (!_isNavigation) {
      _isNavigation = true;
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => AdminHomePage(),
      ));
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToDoctorHome() {
    if (!_isNavigation) {
      _isNavigation = true;
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => DoctorHomePage(),
      ));
    }
  }

  void _navigateToPatientHome() {
    if (!_isNavigation) {
      _isNavigation = true;
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => PatientHomePage(),
      ));
    }
  }
}
