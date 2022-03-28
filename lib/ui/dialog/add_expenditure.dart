import 'package:flutter/material.dart';
import 'package:shuttlers/model/expense.dart';
import 'package:shuttlers/model/member.dart';
import 'package:shuttlers/utils/pretty.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:shuttlers/utils/store.dart';

class AddExpenditureDialog extends StatefulWidget {
  AddExpenditureDialog();
  @override
  AddExpenditureDialogState createState() => AddExpenditureDialogState();
}

// enum ExpenseType {
//   game,
//   equipment,
// }

class AddExpenditureDialogState extends State<AddExpenditureDialog> {
  DateTime _date = DateTime.now();
  double _cost = 14.7;

  Store store = Store();

  List<Member> members = [];
  List<Member> selectedMembers = [];

  // DocumentReference overviewCollection =
  //     FirebaseFirestore.instance.collection(overviewRef).doc('0');

  // CollectionReference membersCollection =
  //     FirebaseFirestore.instance.collection(memberRef);
  // CollectionReference ledgerCollecction =
  //     FirebaseFirestore.instance.collection(ledgerRef);

  bool _showCostPicker = false;

  bool _showMemberPicker = false;

  String typeString = 'Game';
  ExpenseType _expType = ExpenseType.game;

  @override
  void initState() {
    loadMembers();
    super.initState();
  }

  void loadMembers() async {
    await store.member.get().then((value) => value.docs.forEach((element) {
          members.add(Member.fromMap(
              element.data() as Map<String, dynamic>, element.id));
        }));
    setState(() {
      members.sort();
      _showMemberPicker = true;
    });
  }

  String _selectedMembersText = "";

  String _buildSelectedMembersText() {
    if (selectedMembers.isNotEmpty) {
      List<String> _names = [];
      selectedMembers.forEach((element) {
        _names.add(element.name);
      });
      _names.sort();
      _selectedMembersText = _names.join(", ");
      return "$_selectedMembersText.";
    }
    return "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Expenditure'),
        actions: [
          TextButton(
            child: Text(
              'SAVE',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () async {
              if (selectedMembers.length == 1) {
                _showDialog(
                    "${selectedMembers[0].name} can't play on their own!");
                return null;
              } else if (selectedMembers.isEmpty) {
                _showDialog("Noone selected.");
                return null;
              }
              //double _costPerMember = _cost / selectedMembers.length;
              // selectedMembers.forEach((member) async {
              //   double _balance = await membersCollection
              //       .doc(member.id)
              //       .get()
              //       .then((DocumentSnapshot data) {
              //     Map<String, dynamic> temp =
              //         data.data() as Map<String, dynamic>;

              //     return temp['bank'];
              //   });
              //   membersCollection
              //       .doc(member.id)
              //       .update({'bank': _balance - _costPerMember});
              // });
              // List<String> memberIds = [];
              // selectedMembers.reversed.forEach((element) {
              //   memberIds.add(element.id);
              // });
              // double _bankBalance =
              //     await overviewCollection.get().then((DocumentSnapshot data) {
              //   Map<String, dynamic> temp = data.data() as Map<String, dynamic>;

              //   return temp['bank'];
              // });
              // overviewCollection.update({
              //   'bank': _bankBalance - _cost,
              // });

              // ledgerCollecction.doc().set({
              //   'date': Timestamp.fromDate(_date),
              //   'members': memberIds,
              //   'cost': _cost,
              //   'type': _expType.index + 2,
              //   'category': 1,
              //   'mString': _selectedMembersText,
              // });
              await store.addExpenditure(
                date: _date,
                members: selectedMembers,
                cost: _cost,
                type: _expType,
                catergory: 1,
              );
              Navigator.of(context).pop();
            },
          )
        ],
      ),
      body: Column(
        children: [
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
          // _showDatePicker
          //     ? ListTile(
          //         title: Column(
          //           mainAxisAlignment: MainAxisAlignment.center,
          //           children: <Widget>[
          //             DatePicker(
          //               DateTime.now().add(Duration(days: -15)),
          //               initialSelectedDate: _date,
          //               selectionColor: Colors.black,
          //               selectedTextColor: Colors.white,
          //               daysCount: 16,
          //               onDateChange: (date) {
          //                 setState(() {
          //                   _date = date;
          //                 });
          //               },
          //             )
          //           ],
          //         ),
          //       )
          //     : Container(),
          ListTile(
            leading: CircleAvatar(
              child: Text(
                '£',
                style: TextStyle(
                  fontSize: 20.0,
                ),
              ),
            ),
            title: Text('${prettyMoney(_cost)}'),
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
                      value: _cost,
                      minValue: 0,
                      maxValue: 25,
                      decimalPlaces: 2,
                      onChanged: (value) =>
                          setState(() => _cost = value.toDouble())),
                )
              : Container(),
          ListTile(
            leading: CircleAvatar(
              child: Icon(Icons.arrow_forward),
            ),
            title: Text(typeString),
            trailing: PopupMenuButton<ExpenseType>(
              onSelected: (ExpenseType value) {
                setState(() {
                  if (value == ExpenseType.game) {
                    _expType = ExpenseType.game;
                    typeString = 'Game';
                    selectedMembers = [];
                    _selectedMembersText = "";
                  } else if (value == ExpenseType.equipment) {
                    _expType = ExpenseType.equipment;
                    typeString = 'Equipment';
                    selectedMembers = [];
                    members.forEach((element) {
                      selectedMembers.add(element);
                    });
                    _selectedMembersText = "Everyone!";
                  }
                });
              },
              itemBuilder: (BuildContext context) =>
                  <PopupMenuEntry<ExpenseType>>[
                PopupMenuItem<ExpenseType>(
                  value: ExpenseType.game,
                  child: Text('Game'),
                ),
                PopupMenuItem<ExpenseType>(
                  value: ExpenseType.equipment,
                  child: Text('Equipment'),
                ),
              ],
            ),
          ),
          ListTile(
            leading: CircleAvatar(child: Icon(Icons.people)),
            title: Text("$_selectedMembersText"),
            trailing: !_showMemberPicker
                ? IconButton(
                    icon: Icon(Icons.arrow_drop_down),
                    onPressed: () {
                      setState(() {
                        _showMemberPicker = true;
                      });
                    },
                  )
                : IconButton(
                    icon: Icon(Icons.arrow_drop_up),
                    onPressed: () {
                      setState(() {
                        _showMemberPicker = false;
                      });
                    },
                  ),
          ),
          _showMemberPicker
              ? Expanded(
                  child: ListView.builder(
                    itemCount: members.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
                        child: CheckboxListTile(
                          title: Text(members[index].name),
                          secondary: CircleAvatar(
                            backgroundColor: Colors.blue.shade500,
                            child: Icon(Icons.person, color: Colors.white),
                          ),
                          value: selectedMembers.contains(members[index]),
                          onChanged: (bool? value) {
                            setState(() {
                              if (selectedMembers.contains(members[index])) {
                                selectedMembers.remove(members[index]);
                              } else {
                                selectedMembers.add(members[index]);
                                _buildSelectedMembersText();
                              }
                              _selectedMembersText =
                                  _buildSelectedMembersText();
                            });
                          },
                        ),
                      );
                    },
                  ),
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
