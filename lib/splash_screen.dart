import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:MindBridge/auth/login_page.dart';
import 'package:MindBridge/doctor/doctor_home_page.dart';
import 'package:MindBridge/patient/patient_home_page.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    User? user = _auth.currentUser;

    if (user == null) {
      await Future.delayed(Duration(seconds: 2));
      _navigateToLogin();
    } else {
      DatabaseReference userRef = _database.child('Doctors').child(user.uid);
      DataSnapshot snapshot = await userRef.get();

      if (snapshot.exists) {
        await Future.delayed(Duration(seconds: 2));
        _navigateToDoctorHome();
      } else {
        userRef = _database.child('Patients').child(user.uid);
        snapshot = await userRef.get();
        if (snapshot.exists) {
          await Future.delayed(Duration(seconds: 2));
          _navigateToPatientHome();
        } else {
          await Future.delayed(Duration(seconds: 2));
          _navigateToLogin();
        }
      }
    }
  }

  void _navigateToLogin() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => LoginPage()));
  }

  void _navigateToDoctorHome() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => DoctorHomePage()));
  }

  void _navigateToPatientHome() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => PatientHomePage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xffffffff),
        body:  Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/splash.jpg', width: MediaQuery.of(context).size.width,),
              SizedBox(height: 20,),
              Text('MindBridge', style: GoogleFonts.poppins(fontSize: 35, fontWeight: FontWeight.bold,color: Color(0xff005FEE)),),

            ],
          ),
        )
    );
  }

}
