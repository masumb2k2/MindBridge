import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';

import 'auth/login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // Future<void> _fetchUserData() async {
  //   final User? user = _auth.currentUser;
  //   if (user != null) {
  //     final snapshot = await _database.child('Carowners').child(user.uid).get();
  //     if (snapshot.exists) {
  //       setState(() {
  //         _userData = Map<String, dynamic>.from(snapshot.value as Map);
  //         _isLoading = false;
  //       });
  //     } else {
  //       setState(() {
  //         _isLoading = false;
  //       });
  //     }
  //   }
  // }

  Future<void> _fetchUserData() async {
    final User? user = _auth.currentUser;
    if (user != null) {
      DataSnapshot snapshot = await _database.child('Patients').child(user.uid).get();

      if (!snapshot.exists) {
        snapshot = await _database.child('Doctors').child(user.uid).get();
      }

      if (snapshot.exists) {
        setState(() {
          _userData = Map<String, dynamic>.from(snapshot.value as Map);
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }



  void _logout() async {
    await _auth.signOut();
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginPage()),
            (Route<dynamic> route) => false);
  }
  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xff006AFA);
    final Color backgroundColor = const Color(0xfff0f5ff);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          'Profile',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600,color: Colors.white),
        ),

      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _userData == null
          ? const Center(child: Text('No user data found.'))
          : SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    image: const DecorationImage(
                      image: AssetImage('assets/images/profile.jpg'), // Replace with your cover image
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  child: CircleAvatar(
                    radius: 90,
                    backgroundColor: Colors.white,
                    backgroundImage: _userData!['profileImageUrl'] != null &&
                        _userData!['profileImageUrl'].toString().isNotEmpty
                        ? CachedNetworkImageProvider(_userData!['profileImageUrl'])
                        : const AssetImage('assets/images/profile.jpg') as ImageProvider,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 60),
            Text(
              '${_userData!['firstName']} ${_userData!['lastName']}',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 10),
            _buildInfoCard(Icons.email, _userData!['email']),
            _buildInfoCard(Icons.phone, _userData!['phoneNumber']),
            _buildInfoCard(Icons.location_city, _userData!['city']),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String value) {
    final Color primaryColor = const Color(0xff006AFA);
    final Color backgroundColor = const Color(0xfff0f5ff);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: backgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: primaryColor),
        title: Text(
          value,
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
