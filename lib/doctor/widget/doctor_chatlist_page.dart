import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:MindBridge/chat_screen.dart';

import '../model/patient.dart' show Patient;



class PatientsChatlistPage extends StatefulWidget {
  const PatientsChatlistPage({super.key});

  @override
  State<PatientsChatlistPage> createState() => _PatientsChatlistPageState();
}

class _PatientsChatlistPageState extends State<PatientsChatlistPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _chatListDatabase = FirebaseDatabase.instance.ref().child('ChatList');
  final DatabaseReference _patientsDatabase = FirebaseDatabase.instance.ref().child('Patients');
  List<Patient> _chatList = [];
  bool _isLoading =  true;
  late String doctorId;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    doctorId = _auth.currentUser?.uid ?? '';
    _fetchChatList();
  }


  Future<void> _fetchChatList() async {
    if(doctorId.isNotEmpty){
      try{
        final DatabaseEvent event = await _chatListDatabase.child(doctorId).once();
        DataSnapshot snapshot = event.snapshot;
        List<Patient> tempChatList = [];

        if(snapshot.value != null){
          Map<dynamic, dynamic> values = snapshot.value as Map<dynamic, dynamic>;

          for( var userId in values.keys){
            final DatabaseEvent carownerEvent = await _patientsDatabase.child(userId).once();
            DataSnapshot carownerSnapshot = carownerEvent.snapshot;
            if(carownerSnapshot.value != null){
              Map<dynamic, dynamic> carownerMap = carownerSnapshot.value as Map<dynamic, dynamic>;
              tempChatList.add(Patient.fromMap(Map<String, dynamic>.from(carownerMap)));
            }
          }
        }
        setState(() {
          _chatList = tempChatList;
          _isLoading = false;
        });

      }catch (error) {
        // error message
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat with'),),
      body: _isLoading ? Center(child: CircularProgressIndicator())
          : _chatList.isEmpty
          ? Center(child: Text('No chats available'))
          : ListView.builder(
          itemCount: _chatList.length,
          itemBuilder: (context, index){
            final carowner = _chatList[index];
            return Card(
              elevation: 2.0,
              margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: ListTile(
                title: Text('Chat with ${carowner.firstName} ${carowner.lastName}'),
                onTap: (){
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        doctorId:  doctorId,
                        patientId: carowner.uid,
                        patientName: '${carowner.firstName} ${carowner.lastName}',
                      )
                    )
                  );
                },
              ),
            );
          }),
    );
  }
}
