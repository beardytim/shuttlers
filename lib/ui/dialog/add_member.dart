import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hbcbc/data.dart';
import 'package:hbcbc/utils/pretty.dart';
import 'package:numberpicker/numberpicker.dart';

class AddMemberDialog extends StatefulWidget {
  AddMemberDialog();
  @override
  AddMemberDialogState createState() => AddMemberDialogState();
}

class AddMemberDialogState extends State<AddMemberDialog> {
  final myController = TextEditingController();

  DocumentReference overviewCollection =
      FirebaseFirestore.instance.collection(overviewRef).doc('0');
  CollectionReference membersCollection =
      FirebaseFirestore.instance.collection(memberRef);
  CollectionReference ledgerCollecction =
      FirebaseFirestore.instance.collection(ledgerRef);

  bool _showCostPicker = true;
  double _startingBalance = 10.0;

  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Member'),
        actions: <Widget>[
          TextButton(
            onPressed: () async {
              //need to put in error handling - is there a name entered? also is that name already taken?!
              if (myController.text == "") {
                _showDialog("Please enter a name.");
                return null;
              }
              double _bankBalance =
                  await overviewCollection.get().then((DocumentSnapshot data) {
                Map<String, dynamic> temp = data.data() as Map<String, dynamic>;

                return temp['bank'];
              });
              overviewCollection.update({
                'bank': _bankBalance + _startingBalance,
              });
              DocumentReference documentReference = membersCollection.doc();
              documentReference.set({
                'name': myController.text,
                'bank': _startingBalance,
              });
              ledgerCollecction.doc().set({
                'date': Timestamp.now(),
                'members': [documentReference.id],
                'cost': _startingBalance,
                'type': 0,
                'category': 0,
              });

              Navigator.pop(context);
            },
            child: Text(
              'SAVE',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              child: Icon(Icons.person_outline),
            ),
            title: TextField(
              controller: myController,
              textCapitalization: TextCapitalization.words,
              maxLines: 1,
              decoration: InputDecoration(
                labelText: 'Name',
              ),
            ),
          ),
          ListTile(
            leading: CircleAvatar(
              child: Text(
                '£',
                style: TextStyle(
                  fontSize: 20.0,
                ),
              ),
            ),
            title: Text('${prettyMoney(_startingBalance)}'),
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
                      value: _startingBalance,
                      minValue: 0,
                      maxValue: 25,
                      decimalPlaces: 2,
                      onChanged: (value) =>
                          setState(() => _startingBalance = value.toDouble())),
                )
              : Container(),
        ],
      ),
    );
  }

  void _showDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Error"),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: new Text("Okay"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
