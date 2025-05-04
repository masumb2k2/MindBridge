import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';

import '../doctor/doctor_home_page.dart';
import '../patient/patient_home_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  final _formKey = GlobalKey<FormState>();
  String userType = 'Patient';
  String email = '';
  String password = '';
  String phoneNumber = '';
  String firstName = '';
  String lastName = '';
  String city = 'Natore';
  String profileImageUrl = '';
  String category = 'Clinical Psychologist';
  String qualification = '';
  String yearsOfExperience = '';
  double latitude = 0.0;
  double longitude = 0.0;

  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;

  final Location _location = Location();
  bool _isLoading = false;
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffffffff),
      appBar: AppBar(
        title: Text('Register', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w500),),
      ),
      body: _isLoading
          ? CircularProgressIndicator()
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _pickImage, // Trigger image picker when tapped
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100), // Make it a circle
                          child: _imageFile != null
                              ? Image.file(
                            File(_imageFile!.path),
                            width: 100, // Adjust size as needed
                            height: 100,
                            fit: BoxFit.cover,
                          )
                              : Container(
                            color: Color(0xfff0f5ff), // Background color for the placeholder
                            width: 100, // Adjust size as needed
                            height: 100,
                            child: Center(
                              child: Icon(
                                Icons.add_a_photo,
                                color: Color(0xff005FEE),
                                size: 30, // Adjust size as needed
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Select User Type', style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),),
                            Wrap(
                              spacing: 8.0, // Spacing between chips
                              children: ['Patient', 'Doctor'].map((String type) {
                                final isSelected = userType == type;
                                return ChoiceChip(
                                  checkmarkColor: Colors.white,
                                  label: Text(type),
                                  selected: isSelected,
                                  selectedColor: Color(0xff006AFA), // Background color when selected
                                  backgroundColor: Color(0xfff0f5ff), // Background color when not selected
                                  labelStyle: GoogleFonts.poppins(
                                    color: isSelected ? Color(0xfff0f5ff) : Color(0xff006AFA), // Text color
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0), // Rounded corners
                                    side: BorderSide(
                                      color: isSelected ? Color(0xfff0f5ff) : Color(0xfff0f5ff), // Border color
                                      width: 2.0, // Border width
                                    ),
                                  ),
                                  onSelected: (bool selected) {
                                    setState(() {
                                      userType = (selected ? type : null)!;
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16,),
                      SizedBox(
                        height: 44,
                        child: TextFormField(
                          style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Color(0xfff0f5ff),
                            contentPadding: EdgeInsets.only(left: 10, right: 10),
                            labelText: 'Email',
                            labelStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.black54),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0), // Rounded corners
                              borderSide: BorderSide(
                                color: Color(0xfff0f5ff), // Blue border color
                                width: 1.0, // Border width
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(
                                color: Color(0xff006AFA), // Blue border color when focused
                                width: 1.0, // Border width
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(
                                color: Color(0xfff0f5ff), // Blue border color when not focused
                                width: 1.0, // Border width
                              ),
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          onChanged: (val) => email = val,
                          validator: (val) => val!.isEmpty ? 'Enter an email' : null,
                        ),
                      ),
                      SizedBox(height: 10,),
                      SizedBox(
                        height: 44,
                        child: TextFormField(
                          style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Color(0xfff0f5ff),
                            contentPadding: EdgeInsets.symmetric(horizontal: 10),
                            labelText: 'Password',
                            labelStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.black54),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(
                                color: Color(0xfff0f5ff),
                                width: 1.0,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(
                                color: Color(0xff006AFA),
                                width: 1.0,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(
                                color: Color(0xfff0f5ff),
                                width: 1.0,
                              ),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureText ? Icons.visibility_off : Icons.visibility,
                                color: Color(0xff006AFA),
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureText = !_obscureText;
                                });
                              },
                            ),
                          ),
                          obscureText: _obscureText,
                          keyboardType: TextInputType.text,
                          onChanged: (val) => password = val,
                          validator: (val) => val!.length < 6
                              ? 'Password must be at least 6 characters'
                              : null,
                        ),
                      ),
                      SizedBox(height: 10,),
                      SizedBox(
                        height: 44,
                        child: TextFormField(
                          style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Color(0xfff0f5ff),
                            contentPadding: EdgeInsets.symmetric(horizontal: 10),
                            labelText: 'Phone Number',
                            labelStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.black54),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(
                                color: Color(0xfff0f5ff),
                                width: 1.0,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(
                                color: Color(0xff006AFA),
                                width: 1.0,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(
                                color: Color(0xfff0f5ff),
                                width: 1.0,
                              ),
                            ),
                          ),
                          keyboardType: TextInputType.phone,
                          onChanged: (val) => phoneNumber = val,
                          validator: (val) => val!.isEmpty ? 'Please enter a phone number' : null,
                        ),
                      ),
                      SizedBox(height: 10,),
                      SizedBox(
                        height: 44,
                        child: TextFormField(
                          style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Color(0xfff0f5ff),
                            contentPadding: EdgeInsets.symmetric(horizontal: 10),
                            labelText: 'First Name',
                            labelStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.black54),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(
                                color: Color(0xfff0f5ff),
                                width: 1.0,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(
                                color: Color(0xff006AFA),
                                width: 1.0,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(
                                color: Color(0xfff0f5ff),
                                width: 1.0,
                              ),
                            ),
                          ),
                          keyboardType: TextInputType.text,
                          onChanged: (val) => firstName = val,
                          validator: (val) => val!.isEmpty ? 'Please enter a first name' : null,
                        ),
                      ),
                      SizedBox(height: 10,),
                      SizedBox(
                        height: 44,
                        child: TextFormField(
                          style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Color(0xfff0f5ff),
                            contentPadding: EdgeInsets.symmetric(horizontal: 10),
                            labelText: 'Last Name',
                            labelStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.black54),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(
                                color: Color(0xfff0f5ff),
                                width: 1.0,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(
                                color: Color(0xff006AFA),
                                width: 1.0,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(
                                color: Color(0xfff0f5ff),
                                width: 1.0,
                              ),
                            ),
                          ),
                          keyboardType: TextInputType.text,
                          onChanged: (val) => lastName = val,
                          validator: (val) => val!.isEmpty ? 'Please enter a last name' : null,
                        ),
                      ),
                      SizedBox(height: 16,),
                      SizedBox(
                        height: 44,
                        child: DropdownButtonFormField<String>(
                          value: city,
                          items: [
                            'Qadirabad',
                            'Natore',
                            'Rajshahi',
                            'Jhenaidah'
                          ].map((String city) {
                            return DropdownMenuItem(
                              value: city,
                              child: Text(
                                city,
                                style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              city = val!;
                            });
                          },
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Color(0xfff0f5ff),
                            contentPadding: EdgeInsets.symmetric(horizontal: 10),
                            labelText: 'City',
                            labelStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.black87),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(
                                color: Color(0xfff0f5ff),
                                width: 1.0,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(
                                color: Color(0xfff0f5ff),
                                width: 1.0,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(
                                color: Color(0xfff0f5ff),
                                width: 1.0,
                              ),
                            ),
                          ),
                          validator: (val) => val == null ? 'Select a city' : null,
                        ),
                      ),
                      SizedBox(height: 10,),

                      if (userType == 'Doctor') ...[
                        SizedBox(
                          height: 44,
                          child: TextFormField(
                            style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Color(0xfff0f5ff),
                              contentPadding: EdgeInsets.symmetric(horizontal: 10),
                              labelText: 'Qualification',
                              labelStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.black54),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide(
                                  color: Color(0xfff0f5ff),
                                  width: 1.0,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide(
                                  color: Color(0xff006AFA),
                                  width: 1.0,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide(
                                  color: Color(0xfff0f5ff),
                                  width: 1.0,
                                ),
                              ),
                            ),
                            onChanged: (val) => qualification = val,
                            validator: (val) => val!.isEmpty ? 'Please enter a qualification' : null,
                          ),
                        ),
                        SizedBox(height: 10,),
                        SizedBox(
                          height: 44,
                          child: DropdownButtonFormField<String>(
                            value: category,
                            items: [
                              'Clinical Psychologist',
                              'Relationship Therapist',
                              'Addiction Counselor',
                              'Child Psychologist',
                              'Neuropsychologist'
                            ].map((String category) {
                              return DropdownMenuItem(
                                value: category,
                                child: Text(
                                  category,
                                  style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500),
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              setState(() {
                                category = val!;
                              });
                            },
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Color(0xfff0f5ff),
                              contentPadding: EdgeInsets.symmetric(horizontal: 10),
                              labelText: 'Category',
                              labelStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.black87),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide(
                                  color: Color(0xfff0f5ff),
                                  width: 1.0,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide(
                                  color: Color(0xfff0f5ff),
                                  width: 1.0,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide(
                                  color: Color(0xfff0f5ff),
                                  width: 1.0,
                                ),
                              ),
                            ),
                            validator: (val) => val == null ? 'Select a category' : null,
                          ),
                        ),
                        SizedBox(height: 10,),
                        SizedBox(
                          height: 44,
                          child: TextFormField(
                            style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Color(0xfff0f5ff),
                              contentPadding: EdgeInsets.symmetric(horizontal: 10),
                              labelText: 'Year of Experience',
                              labelStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.black54),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide(
                                  color: Color(0xfff0f5ff),
                                  width: 1.0,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide(
                                  color: Color(0xff006AFA),
                                  width: 1.0,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide(
                                  color: Color(0xfff0f5ff),
                                  width: 1.0,
                                ),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (val) => yearsOfExperience = val,
                            validator: (val) => val!.isEmpty ? 'Please enter year of experience' : null,
                          ),
                        ),
                      ],
                      SizedBox(height: 10,),
                      SizedBox(
                        width: double.infinity, // Adjust width as needed
                        child: ElevatedButton(
                          onPressed: _getLocation,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xfff0f5ff), // Background color (blue)
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(35.0), // Rounded corners
                            ),
                            padding: EdgeInsets.symmetric(vertical: 14), // Vertical padding
                          ),
                          child: Text(
                            'Click to Get Current Location',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Color(0xff006AFA), // Text color
                            ),
                          ),
                        ),
                      ),
                      if (latitude != 0.0 && longitude != 0.0)
                        Text('Location: ($latitude, $longitude)'),
                      SizedBox(height: 10,),
                      SizedBox(
                        width: double.infinity, // Adjust width as needed
                        child: ElevatedButton(
                          onPressed: _register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xff006AFA), // Background color (blue)
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(35.0), // Rounded corners
                            ),
                            padding: EdgeInsets.symmetric(vertical: 14), // Vertical padding
                          ),
                          child: Text(
                            'Register',
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Colors.white, // Text color
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 20),
                    ],
                  ),
                ),
              )),
    );
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _imageFile = pickedFile;
    });
  }

  Future<void> _getLocation() async {
    final locationData = await _location.getLocation();
    setState(() {
      latitude = locationData.latitude!;
      longitude = locationData.longitude!;
    });
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        User? user = userCredential.user;

        if (user != null) {
          String userTypePath = userType == 'Doctor' ? 'Doctors' : 'Patients';
          Map<String, dynamic> userData = {
            'uid': user.uid,
            'email': email,
            'phoneNumber': phoneNumber,
            'firstName': firstName,
            'lastName': lastName,
            'city': city,
            'profileImageUrl': profileImageUrl,
            'latitude': latitude,
            'longitude': longitude,
          };

          if (userType == 'Doctor') {
            userData['qualification'] = qualification;
            userData['category'] = category;
            userData['yearsOfExperience'] = yearsOfExperience;
            userData['totalReviews'] = 0;
            userData['averageRating'] = 0.0;
            userData['numberOfReviews'] = 0;
          }

          await _database.child(userTypePath).child(user.uid).set(userData);

          if (_imageFile != null) {
            Reference storageReference = FirebaseStorage.instance
                .ref()
                .child('$userTypePath/${user.uid}/profile.jpg');
            UploadTask uploadTask =
                storageReference.putFile(File(_imageFile!.path));
            TaskSnapshot taskSnapshot = await uploadTask;

            String downloadUrl = await taskSnapshot.ref.getDownloadURL();
            await _database.child(userTypePath).child(user.uid).update({
              'profileImageUrl': downloadUrl,
            });
          }

          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) =>
                  userType == 'Doctor' ? DoctorHomePage() : PatientHomePage(),
            ),
          );
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

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
