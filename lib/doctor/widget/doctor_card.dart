import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:practice/doctor/model/doctor.dart';

class DoctorCard extends StatelessWidget {
  final Doctor doctor;

  const DoctorCard({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(0),
      margin: EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: Color(0xfff0f5ff),
        border: Border.all(color: Color(0xff005FEE)),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Card(
        color: Color(0xfff0f5ff),
        elevation: 0.0,
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 0),
        child: ListTile(
          leading: Container(
            width: 55,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(60),
              border: Border.all(color: Color(0xff006AFA)),
            ),
            child: CircleAvatar(
              backgroundImage:AssetImage('assets/images/profile.jpg'),
            ),
          ),
          title: Text(
            '${doctor.firstName} ${doctor.lastName}',
            style: GoogleFonts.poppins(
              fontSize: 16, fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 4),
              Row(children: [
                Text('${doctor.category} - ${doctor.city}',
                style: GoogleFonts.poppins(
                  fontSize: 14
                ),)
              ],),
              Text(
                'Experience: ${doctor.yearsOfExperience} years',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                  color: Color(0xff005FEE),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
