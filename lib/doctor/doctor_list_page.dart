import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:MindBridge/doctor/doctor_details_page.dart';
import 'package:MindBridge/doctor/model/doctor.dart';
import 'package:MindBridge/doctor/widget/doctor_card.dart';

class DoctorListPage extends StatefulWidget {
  const DoctorListPage({super.key});

  @override
  State<DoctorListPage> createState() => _DoctorListPageState();
}

class _DoctorListPageState extends State<DoctorListPage> {
  final DatabaseReference _database =
      FirebaseDatabase.instance.ref().child('Doctors');
  List<Doctor> _doctors = [];
  List<Doctor> _filtereddoctors = [];
  bool _isLoading = true;

  // Track the selected category
  String? _selectedCategory;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchDoctors();
  }

  Future<void> _fetchDoctors() async {
    await _database.once().then((DatabaseEvent event) {
      DataSnapshot snapshot = event.snapshot;
      List<Doctor> tmpDoctors = [];
      if (snapshot.value != null) {
        Map<dynamic, dynamic> values = snapshot.value as Map<dynamic, dynamic>;
        values.forEach((key, value) {
          Doctor doctor = Doctor.fromMap(value, key);
          tmpDoctors.add(doctor);
        });
      }
      setState(() {
        _doctors = tmpDoctors;
        _isLoading = false;
        _filtereddoctors = tmpDoctors;
      });
    });
  }

  // Filter lawyers based on the selected category
  void _filterdoctorsByCategory(String? category) {
    setState(() {
      _selectedCategory = category;
      if (category == null || category.isEmpty) {
        _filtereddoctors = _doctors; // Show all lawyers
      } else {
        // Manually filter lawyers by specific categories
        if (category == 'Clinical Psychologist') {
          _filtereddoctors =
              _doctors.where((doctor) => doctor.category == 'Clinical Psychologist').toList();
        } else if (category == 'Relationship Therapist') {
          _filtereddoctors =
              _doctors.where((doctor) => doctor.category == 'Relationship Therapist').toList();
        } else if (category == 'Addiction Counselor') {
          _filtereddoctors =
              _doctors.where((doctor) => doctor.category == 'Addiction Counselor').toList();
        } else if (category == 'Child Psychologist') {
          _filtereddoctors =
              _doctors.where((doctor) => doctor.category == 'Child Psychologist').toList();
        } else if (category == 'Neuropsychologist') {
          _filtereddoctors =
              _doctors.where((doctor) => doctor.category == 'Neuropsychologist').toList();
        } else {
          _filtereddoctors = _doctors; // Default to showing all lawyers
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffffffff),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 30.0,
                  ),
                  Text(
                    'Find your Psychologist &\nBook an Appointment',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      color: Color(0xff006AFA),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Text(
                    'Find Doctor by Category',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(
                    height: 16.0,
                  ),
                  // Adjusted to fit three cards in one row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildCategoryCard(context, 'Clinical\nPsychologist',
                          'assets/images/Clinical.jpg', 'Clinical Psychologist'),
                      _buildCategoryCard(context, 'Relationship\nPsychologist',
                          'assets/images/relationship.jpg', 'Relationship Therapist'),
                      _buildCategoryCard(context, 'Addiction\nPsychologist',
                          'assets/images/Addiction.jpg', 'Addiction Counselor'),
                    ],
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildCategoryCard(context, 'Child\nPsychologist',
                          'assets/images/Child.jpg', 'Child Psychologist'),
                      _buildCategoryCard(context, 'Neuropsy-\nchologist',
                          'assets/images/Neuropsychologist.jpeg', 'Neuropsychologist'),
                      _buildCategoryCard(context, 'See All\nCategory',
                          'assets/images/grid.png', ''),
                    ],
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Top Psychologist',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        'VIEW ALL',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xff006AFA),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: _filtereddoctors.isEmpty
                        ? Center(
                      child: Text(
                        'No Psychologist found for this category.',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    )
                        : ListView.builder(
                      itemCount: _filtereddoctors.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DoctorDetailPage(
                                    doctor: _filtereddoctors[index]),
                              ),
                            );
                          },
                          child: DoctorCard(
                              doctor: _filtereddoctors[index]),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
  Widget _buildCategoryCard(BuildContext context, String title, String icon,
      String category) {
    bool isSelected = _selectedCategory == category;

    return GestureDetector(
      onTap: () {
        _filterdoctorsByCategory(category.isEmpty ? null : category);
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.28,
        decoration: BoxDecoration(
          color: isSelected ? Color(0xff006AFA) : Color(0xffFFFFFF),
          borderRadius: BorderRadius.circular(15),
          border: isSelected
              ? null
              : Border.all(color: Color(0xff006AFA), width: 2),
        ),
        child: Card(
          color: isSelected ? Color(0xff006AFA) : Color(0xfff0f5ff),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      icon,
                      width: 80,
                      height: 80,
                      fit: BoxFit.fill,
                      // color: isSelected ? Colors.white : Color(0xff006AFA),
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : Color(0xff006AFA),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

