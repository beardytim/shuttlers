import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:shuttlers/model/expense.dart';
import 'package:shuttlers/ui/dialog/add_expenditure.dart';
import 'package:shuttlers/ui/widgets/expense_card.dart';

import 'package:shuttlers/utils/store.dart';

class LedgerScreen extends StatefulWidget {
  const LedgerScreen({Key? key}) : super(key: key);

  @override
  State<LedgerScreen> createState() => _LedgerScreenState();
}

class _LedgerScreenState extends State<LedgerScreen> {
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
        title: Text('LedgerScreen'),
        //leading: MenuWidget(),
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () => ZoomDrawer.of(context)!.toggle(),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: Store().ledgerStream(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return ListView(
            children: snapshot.data!.docs.map((document) {
              Map<String, dynamic> data =
                  document.data()! as Map<String, dynamic>;
              return ExpenseCard(
                Ledger.fromMap(data),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: user == null ? null : fab(),
    );
  }

  Widget fab() => FloatingActionButton(
        child: Icon(
          Icons.add,
          size: 20.0,
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddExpenditureDialog()),
          );
        },
      );
}
