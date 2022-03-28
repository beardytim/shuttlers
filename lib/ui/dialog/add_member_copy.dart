import 'package:flutter/material.dart';
import 'package:shuttlers/utils/pretty.dart';
import 'package:shuttlers/utils/store.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:shuttlers/model/member.dart';

class AddMemberDialog extends StatefulWidget {
  AddMemberDialog();
  @override
  AddMemberDialogState createState() => AddMemberDialogState();
}

class AddMemberDialogState extends State<AddMemberDialog> {
  final myController = TextEditingController();
  Store store = Store();

  bool _showCostPicker = true;
  double _startingBalance = 10.0;

  @override
  void initState() {
    super.initState();
  }

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

              await store.addMember(Member(
                  id: '0', name: myController.text, bank: _startingBalance));

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
