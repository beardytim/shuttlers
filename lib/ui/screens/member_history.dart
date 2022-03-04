import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hbcbc/data.dart';
import 'package:hbcbc/model/expense.dart';
import 'package:hbcbc/model/member.dart';
import 'package:hbcbc/ui/widgets/history_card.dart';
import 'package:hbcbc/utils/pretty.dart';

class UserHistoryScreen extends StatefulWidget {
  final Member member;
  UserHistoryScreen(this.member);
  @override
  State<StatefulWidget> createState() => UserHistoryScreenState();
}

class UserHistoryScreenState extends State<UserHistoryScreen> {
  Widget build(BuildContext context) {
    int x = 1;
    final Member member = widget.member;
    CollectionReference collectionReference =
        FirebaseFirestore.instance.collection(ledgerRef);
    Stream<QuerySnapshot> ledgerStream = collectionReference
        .orderBy('date', descending: true)
        .where('members', arrayContains: member.id)
        .snapshots();
    Column _buildIncomeHistory() {
      return Column(
        children: <Widget>[
          // Card(
          //   child: ListTile(
          //     title: Text("Current balance is ${prettyMoney(member.bank)}"),
          //   ),
          // ),
          Expanded(
            child: StreamBuilder(
              stream: ledgerStream,
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text("Something went wrong"));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                return ListView(
                  children:
                      snapshot.data!.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data =
                        document.data()! as Map<String, dynamic>;

                    x++;
                    return HistoryCard(Ledger.fromMap(data), x);
                  }).toList(),
                );
              },
            ),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${member.name} History'),
      ),
      body: _buildIncomeHistory(),
    );
  }
}
