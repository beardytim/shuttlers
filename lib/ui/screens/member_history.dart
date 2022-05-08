import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shuttlers/model/expense.dart';
import 'package:shuttlers/model/member.dart';
import 'package:shuttlers/ui/widgets/history_card.dart';
import 'package:shuttlers/utils/store.dart';

class UserHistoryScreen extends StatefulWidget {
  final Member member;
  UserHistoryScreen(this.member);
  @override
  State<StatefulWidget> createState() => UserHistoryScreenState();
}

class UserHistoryScreenState extends State<UserHistoryScreen> {
  Widget build(BuildContext context) {
    int x = 1;
    Column _buildIncomeHistory() {
      return Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder(
              stream: Store().historyStream(widget.member),
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
        title: Text('${widget.member.name} History'),
      ),
      body: _buildIncomeHistory(),
    );
  }
}
