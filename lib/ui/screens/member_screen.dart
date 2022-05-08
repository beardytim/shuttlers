import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:shuttlers/model/member.dart';
import 'package:shuttlers/ui/dialog/add_member.dart';
import 'package:shuttlers/ui/widgets/member_card.dart';
import 'package:shuttlers/ui/widgets/member_card_admin.dart';
import 'package:shuttlers/utils/store.dart';

class MemberScreen extends StatefulWidget {
  const MemberScreen({Key? key}) : super(key: key);

  @override
  State<MemberScreen> createState() => _MemberScreenState();
}

class _MemberScreenState extends State<MemberScreen> {
  FirebaseAuth auth = FirebaseAuth.instance;
  User? user;

  @override
  void initState() {
    auth.authStateChanges().listen((usr) {
      setState(() {
        this.user = usr;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Members'),
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () => ZoomDrawer.of(context)!.toggle(),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: Store().membersStream(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData)
            return Center(
              child: CircularProgressIndicator(),
            );
          return ListView(
            children: snapshot.data!.docs.map((document) {
              Map<String, dynamic> data =
                  document.data()! as Map<String, dynamic>;
              return user != null
                  ? MemberCardAdmin(
                      Member.fromMap(data, document.id),
                    )
                  : MemberCard(Member.fromMap(data, document.id));
            }).toList(),
          );
        },
      ),
      floatingActionButton: user == null ? null : fab(),
    );
  }

  Widget fab() => FloatingActionButton(
        child: Icon(
          Icons.person_add,
          size: 20.0,
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddMemberDialog()),
          );
        },
      );
}
