import 'package:flutter/material.dart';
import 'package:shuttlers/model/member.dart';
import 'package:shuttlers/utils/pretty.dart';
import 'package:shuttlers/utils/store.dart';
import 'package:numberpicker/numberpicker.dart';

import '../../model/expense.dart';

class AddFundsDialog extends StatefulWidget {
  final Member member;
  AddFundsDialog(this.member);
  @override
  AddFundsDialogState createState() => AddFundsDialogState();
}

// enum IncomeType { deposit, reimbursement }

class AddFundsDialogState extends State<AddFundsDialog> {
  DateTime _date = DateTime.now();
  double _fundsToAdd = 10.0;
  bool _showCostPicker = true;

  String typeString = 'Deposit';
  IncomeType _incType = IncomeType.deposit;

  Store store = Store();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Funds to ${widget.member.name}'),
        actions: <Widget>[
          TextButton(
            onPressed: () async {
              // double _bankBalance =
              //     await overviewCollection.get().then((DocumentSnapshot data) {
              //   Map<String, dynamic> temp = data.data() as Map<String, dynamic>;

              //   return temp['bank'];
              // });
              // overviewCollection.update({
              //   'bank': _bankBalance + _fundsToAdd,
              // });

              // membersCollection.doc(widget.member.id).update({
              //   'bank': widget.member.bank + _fundsToAdd,
              // });
              // ledgerCollecction.doc().set({
              //   'date': Timestamp.fromDate(_date),
              //   'members': [widget.member.id],
              //   'cost': _fundsToAdd,
              //   'type': _incType.index,
              //   'category': 0,
              // });

              await store.addFunds(
                data: widget.member,
                funds: _fundsToAdd,
                type: _incType,
                date: _date,
              );
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
            trailing: PopupMenuButton<IncomeType>(
              onSelected: (IncomeType value) {
                print(_incType.index);
                setState(() {
                  if (value == IncomeType.deposit) {
                    _incType = IncomeType.deposit;
                    typeString = 'Deposit';
                  } else if (value == IncomeType.reimbursement) {
                    _incType = IncomeType.reimbursement;
                    typeString = 'Reimbusement';
                  }
                });
              },
              itemBuilder: (BuildContext context) =>
                  <PopupMenuEntry<IncomeType>>[
                PopupMenuItem<IncomeType>(
                  value: IncomeType.deposit,
                  child: Text('Deposit'),
                ),
                PopupMenuItem<IncomeType>(
                  value: IncomeType.reimbursement,
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
