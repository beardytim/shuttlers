import 'package:flutter/material.dart';
import 'package:shuttlers/model/member.dart';
import 'package:shuttlers/ui/screens/member_history.dart';
import 'package:shuttlers/utils/pretty.dart';

class MemberCard extends StatelessWidget {
  //final currentUser = FirebaseAuth.instance.currentUser;

  final Member member;

  MemberCard(this.member);

  Widget build(BuildContext context) {
    // print(currentUser);
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
              icon: Icon(Icons.history),
              onPressed: () => _openMemberHistory(),
            ),
          ],
        ),
      ),
    );
  }
}
