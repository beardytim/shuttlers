import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hbcbc/data.dart';
import 'package:hbcbc/model/member.dart';

import 'package:hbcbc/utils/pretty.dart';
import 'package:numberpicker/numberpicker.dart';

class AddFundsDialog extends StatefulWidget {
  final Member member;
  AddFundsDialog(this.member);
  @override
  AddFundsDialogState createState() => AddFundsDialogState();
}

enum _incomeType { deposit, reimbursement }

class AddFundsDialogState extends State<AddFundsDialog> {
  DateTime _date = DateTime.now();
  double _fundsToAdd = 10.0;
  bool _showCostPicker = true;
  bool _showDatePicker = false;

  String typeString = 'Deposit';
  _incomeType _incType = _incomeType.deposit;

  DocumentReference overviewCollection =
      FirebaseFirestore.instance.collection(overviewRef).doc('0');
  CollectionReference membersCollection =
      FirebaseFirestore.instance.collection(memberRef);
  CollectionReference ledgerCollecction =
      FirebaseFirestore.instance.collection(ledgerRef);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Funds to ${widget.member.name}'),
        actions: <Widget>[
          TextButton(
            onPressed: () async {
              double _bankBalance =
                  await overviewCollection.get().then((DocumentSnapshot data) {
                Map<String, dynamic> temp = data.data() as Map<String, dynamic>;

                return temp['bank'];
              });
              overviewCollection.update({
                'bank': _bankBalance + _fundsToAdd,
              });

              membersCollection.doc(widget.member.id).update({
                'bank': widget.member.bank + _fundsToAdd,
              });
              ledgerCollecction.doc().set({
                'date': Timestamp.fromDate(_date),
                'members': [widget.member.id],
                'cost': _fundsToAdd,
                'type': _incType.index,
                'category': 0,
              });
              Navigator.of(context).pop();
            },
            child: Text(
              'SAVE',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          ListTile(
              leading: CircleAvatar(
                child: Icon(Icons.calendar_today),
              ),
              title: Text(prettyDate(_date)),
              trailing: IconButton(
                icon: Icon(Icons.arrow_drop_down),
                onPressed: () async {
                  _date = (await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now().add(Duration(days: -30)),
                    lastDate: DateTime.now(),
                  ))!;

                  setState(() {});
                },
              )),
          ListTile(
            leading: CircleAvatar(
              child: Text(
                '£',
                style: TextStyle(
                  fontSize: 20.0,
                ),
              ),
            ),
            title: Text('${prettyMoney(_fundsToAdd)}'),
            trailing: !_showCostPicker
                ? IconButton(
                    icon: Icon(Icons.arrow_drop_down),
                    onPressed: () {
                      setState(() {
                        _showCostPicker = true;
                      });
                    },
                  )
                : IconButton(
                    icon: Icon(Icons.arrow_drop_up),
                    onPressed: () {
                      setState(() {
                        _showCostPicker = false;
                      });
                    },
                  ),
          ),
          _showCostPicker
              ? ListTile(
                  title: DecimalNumberPicker(
                      value: _fundsToAdd,
                      minValue: 0,
                      maxValue: 25,
                      decimalPlaces: 2,
                      onChanged: (value) =>
                          setState(() => _fundsToAdd = value.toDouble())),
                  //title: Text("NEED TO FIX NUMBER PICKER!"),
                )
              : Container(),
          ListTile(
            leading: CircleAvatar(
              child: Icon(Icons.arrow_forward),
            ),
            title: Text(typeString),
            trailing: PopupMenuButton<_incomeType>(
              onSelected: (_incomeType value) {
                setState(() {
                  if (value == _incomeType.deposit) {
                    _incType = _incomeType.deposit;
                    typeString = 'Deposit';
                  } else if (value == _incomeType.reimbursement) {
                    _incType = _incomeType.reimbursement;
                    typeString = 'Reimbusement';
                  }
                });
              },
              itemBuilder: (BuildContext context) =>
                  <PopupMenuEntry<_incomeType>>[
                PopupMenuItem<_incomeType>(
                  value: _incomeType.deposit,
                  child: Text('Deposit'),
                ),
                PopupMenuItem<_incomeType>(
                  value: _incomeType.reimbursement,
                  child: Text('Reimbusement'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
