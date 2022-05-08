import 'package:flutter/material.dart';
import 'package:holding_gesture/holding_gesture.dart';
import 'package:shuttlers/model/expense.dart';
import 'package:shuttlers/model/member.dart';
import 'package:shuttlers/utils/pretty.dart';
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
  double _cost = 10.17;

  Store store = Store();

  late final Future<List<Member>> members;

  List<Member> selectedMembers = [];
  List<String> selectedMembersIDs = [];

  String typeString = 'Game';
  ExpenseType _expType = ExpenseType.game;

  int _currentStep = 0;

  stepTapped(int step) {
    setState(() => _currentStep = step);
  }

  stepContinued() {
    _currentStep < 3 ? setState(() => _currentStep += 1) : saveExpenditure();
  }

  stepCanceled() {
    _currentStep > 0 ? setState(() => _currentStep -= 1) : null;
  }

  _amountIncrease() => setState(() => _cost += 0.01);

  _amountDecrease() => setState(() => _cost -= 0.01);

  _datePicker() async {
    _date = (await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().add(Duration(days: -30)),
      lastDate: DateTime.now(),
    ))!;

    setState(() {});
  }

  saveExpenditure() async {
    if (selectedMembers.length == 1) {
      _showDialog("${selectedMembers[0].name} can't play on their own!");
      return null;
    } else if (selectedMembers.isEmpty) {
      _showDialog("Noone selected.");
      return null;
    }
    try {
      await store.addExpenditure(
        date: _date,
        members: selectedMembers,
        cost: _cost,
        type: _expType,
        catergory: 1,
      );

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Added expenditure.")));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Something went wrong.")));
    }

    Navigator.pop(context);
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

  Future<List<Member>> loadMembers() async {
    print('real future is here');
    List<Member> temp = [];
    Store().member.get().then((value) {
      value.docs.forEach((element) {
        Map<String, dynamic> data = element.data() as Map<String, dynamic>;
        temp.add(Member.fromMap(data, element.id));
      });
    });
    return temp;
  }

  @override
  void initState() {
    super.initState();
    // futureMembers = loadMembers();
    // _memoizer = AsyncMemoizer();
    members = loadMembers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Expenditure'),
      ),
      body: Stepper(
        type: StepperType.vertical,
        physics: ScrollPhysics(),
        onStepTapped: (step) => stepTapped(step),
        currentStep: _currentStep,
        controlsBuilder: controlsBuilder,
        steps: [
          Step(
            title: Text('Date'),
            content: Row(
              children: [
                Spacer(),
                Container(
                  height: 50,
                  width: 100,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).primaryColor,
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                    ),
                  ),
                  child: Center(
                      child: Text(
                    "${prettyDate(_date)}",
                    style: Theme.of(context).textTheme.headline6,
                  )),
                ),
                GestureDetector(
                  onTap: _datePicker,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      ),
                      border: Border.all(
                        color: Theme.of(context).primaryColor,
                      ),
                      color: Theme.of(context).primaryColor,
                    ),
                    height: 50,
                    width: 50,
                    child: Center(
                      child: Icon(
                        Icons.calendar_today,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Spacer(),
              ],
            ),
            isActive: _currentStep >= 0,
            state: _currentStep >= 0 ? StepState.complete : StepState.disabled,
          ),
          Step(
            title: Text('Cost'),
            isActive: _currentStep >= 0,
            state: _currentStep >= 1 ? StepState.complete : StepState.disabled,
            content: Row(
              children: [
                Spacer(),
                HoldDetector(
                  onHold: _amountDecrease,
                  onTap: _amountDecrease,
                  holdTimeout: Duration(milliseconds: 50),
                  enableHapticFeedback: true,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        bottomLeft: Radius.circular(10),
                      ),
                      border: Border.all(
                        color: Theme.of(context).primaryColor,
                      ),
                      color: Theme.of(context).primaryColor,
                    ),
                    height: 50,
                    width: 50,
                    child: Center(
                      child: Icon(
                        Icons.remove,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 50,
                  width: 100,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  child: Center(
                      child: Text(
                    "£${_cost.toStringAsFixed(2)}",
                    style: Theme.of(context).textTheme.headline6,
                  )),
                ),
                HoldDetector(
                  onHold: _amountIncrease,
                  onTap: _amountIncrease,
                  holdTimeout: Duration(milliseconds: 50),
                  enableHapticFeedback: true,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      ),
                      border: Border.all(
                        color: Theme.of(context).primaryColor,
                      ),
                      color: Theme.of(context).primaryColor,
                    ),
                    height: 50,
                    width: 50,
                    child: Center(
                      child: Icon(
                        Icons.add,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Spacer(),
              ],
            ),
          ),
          Step(
            title: Text('Type'),
            content: ListTile(
              title: Text(typeString),
              trailing: PopupMenuButton<ExpenseType>(
                onSelected: (ExpenseType value) {
                  setState(() {
                    if (value == ExpenseType.game) {
                      _expType = ExpenseType.game;
                      typeString = 'Game';
                    } else if (value == ExpenseType.equipment) {
                      _expType = ExpenseType.equipment;
                      typeString = 'Equipment';
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
            isActive: _currentStep >= 0,
            state: _currentStep >= 2 ? StepState.complete : StepState.disabled,
          ),
          Step(
            title: Text('Players'),
            content: ListTile(
              title: selectedMembers.isEmpty
                  ? Text('Click to add members')
                  : Text(_selectedMembersText),
              onTap: () => _displayMemberInputDialog(context),
            ),
            isActive: _currentStep >= 0,
            state: _currentStep >= 3 ? StepState.complete : StepState.disabled,
          ),
        ],
      ),
    );
  }

  void _displayMemberInputDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: SizedBox(
              width: 300,
              //height: 100,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FutureBuilder(
                      future: members,
                      builder: (BuildContext context,
                          AsyncSnapshot<List<Member>> snapshot) {
                        if (!snapshot.hasData)
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount: snapshot.data!.length,
                          itemBuilder: (BuildContext context, int index) {
                            Member temp = snapshot.data![index];
                            return StatefulBuilder(builder:
                                (BuildContext context, StateSetter _setState) {
                              return CheckboxListTile(
                                title: Text(temp.name),
                                value: selectedMembers.contains(temp),
                                onChanged: (bool? value) {
                                  _setState((() {
                                    setState(() {
                                      if (selectedMembers.contains(temp)) {
                                        selectedMembers.remove(temp);
                                      } else {
                                        selectedMembers.add(temp);
                                      }
                                      _selectedMembersText =
                                          _buildSelectedMembersText();
                                    });
                                  }));
                                },
                              );
                            });
                          },
                        );
                      }),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: const Text('DONE'),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
            ],
          );
        });
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

  Widget controlsBuilder(BuildContext context, ControlsDetails details) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
      child: Row(
        children: [
          _currentStep == 0
              ? TextButton(
                  onPressed: stepContinued,
                  child: const Text(
                    'CONTINUE',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                          Theme.of(context).primaryColor)),
                )
              : _currentStep <= 2
                  ? Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: stepContinued,
                            child: const Text(
                              'CONTINUE',
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    Theme.of(context).primaryColor)),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          TextButton(
                            onPressed: stepCanceled,
                            child: const Text('BACK'),
                          ),
                        ],
                      ),
                    )
                  : Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: stepContinued,
                            child: const Text(
                              'SAVE',
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    Theme.of(context).primaryColor)),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          TextButton(
                            onPressed: stepCanceled,
                            child: const Text('BACK'),
                          ),
                        ],
                      ),
                    )
        ],
      ),
    );
  }
}
