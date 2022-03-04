import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hbcbc/data.dart';
import 'package:hbcbc/model/member.dart';
import 'package:hbcbc/ui/dialog/add_funds.dart';
import 'package:hbcbc/ui/screens/member_history.dart';
import 'package:hbcbc/utils/pretty.dart';

class MemberCardAdmin extends StatelessWidget {
  final Member member;

  MemberCardAdmin(this.member);

  Future<void> _deleteConfirmation(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Warning'),
            content: Text(
                'You are about to delete ${member.name}. There final balance is ${prettyMoney(member.bank)}.'),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("CANCEL")),
              TextButton(
                child: Text('DELETE'),
                onPressed: () async {
                  await FirebaseFirestore.instance
                      .collection(memberRef)
                      .doc(member.id)
                      .delete();
                  double _bankBalance = await FirebaseFirestore.instance
                      .collection(overviewRef)
                      .doc("0")
                      .get()
                      .then((DocumentSnapshot data) {
                    Map<String, dynamic> temp =
                        data.data() as Map<String, dynamic>;

                    return temp['bank'];
                  });
                  await FirebaseFirestore.instance
                      .collection(overviewRef)
                      .doc("0")
                      .update({
                    'bank': _bankBalance - member.bank,
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  Widget build(BuildContext context) {
    _openAddFundsDialog() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddFundsDialog(member),
        ),
      );
    }

    _openMemberHistory() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UserHistoryScreen(member),
        ),
      );
    }

    bool _inTheRed = false;
    if (member.bank < 0.00) {
      _inTheRed = true;
    }

    return Card(
      elevation: 2.0,
      color: _inTheRed ? Colors.red.shade100 : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: _inTheRed
            ? BorderSide(color: Colors.red, width: 2.0)
            : BorderSide(color: Colors.white70),
      ),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(
            member.name[0],
          ),
        ),
        title: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(member.name),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(prettyMoney(member.bank)),
                ],
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                _deleteConfirmation(context);
              },
            ),
            IconButton(
              icon: Icon(Icons.history),
              onPressed: () {
                _openMemberHistory();
              },
            ),
            IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  _openAddFundsDialog();
                }),
          ],
        ),
      ),
    );
  }
}
