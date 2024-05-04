import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_6/components/app_bar_drawer.dart';
import 'package:flutter_application_6/pages/login_page.dart';

class ProfilPage extends StatefulWidget {
  @override
  _UserDetailsPageState createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<ProfilPage> {
  late User? _user;
  late String _username = '';
  late String _email = '';

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    _email = _user?.email ?? '';
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    // Query Firestore to get additional user details
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('admins')
          .doc(_email)
          .get();

      // Extract username from Firestore
      if (userSnapshot.exists) {
        setState(() {
          _username = userSnapshot.get('username') ?? '';
        });
      }
    } catch (e) {
      print('Error fetching user details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        user: FirebaseAuth.instance.currentUser,
        signOut: () {
          FirebaseAuth.instance.signOut();
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => LoginPage()));
        },
      ),
      drawer: CustomDrawer(),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 100,
              child: Center(
                child: Icon(
                  Icons.account_circle,
                  size: 65.0,
                ),
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'Email: $_email',
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(height: 16.0),
            Text(
              'Role: Administrateur',
              style: TextStyle(fontSize: 18.0),
            ),
          ],
        ),
      ),
    );
  }
}
