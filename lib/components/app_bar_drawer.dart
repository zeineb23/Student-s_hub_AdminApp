import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_6/pages/admin_page.dart';
import 'package:flutter_application_6/pages/all_messages_page.dart';
import 'package:flutter_application_6/pages/home_page.dart';
import 'package:flutter_application_6/pages/profil_page.dart';
import 'package:flutter_application_6/pages/student_page.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final User? user;
  final Function()? signOut;

  const CustomAppBar({Key? key, this.user, this.signOut}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Container(
        height: 50, // Adjust the height as needed
        child: Center(
          child: Image.asset('assets/LogoISI.png'),
        ),
      ),
      actions: [
        IconButton(
          onPressed: signOut,
          icon: const Icon(Icons.logout),
        )
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class CustomDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.grey[700],
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Menu',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Profil'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.admin_panel_settings),
            title: Text('Administrateurs'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AdminPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Étudiants'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StudentPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.list), // Icon for Catégories
            title: Text('Catégories'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HomePage(),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.update), // Icon for Messages
            title: Text('Messages'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AllMessagesPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.chat), // Icon for Chat
            title: Text('Chat'),
            onTap: () {
              // Handle Chat press
            },
          ),
        ],
      ),
    );
  }
}
