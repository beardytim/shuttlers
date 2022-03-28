import 'package:flutter/material.dart';
import 'package:holding_gesture/holding_gesture.dart';
import 'package:shuttlers/utils/pretty.dart';
import 'package:shuttlers/utils/store.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:shuttlers/model/member.dart';

class AddMemberDialog extends StatefulWidget {
  AddMemberDialog();
  @override
  AddMemberDialogState createState() => AddMemberDialogState();
}

//TODO
//https://stackoverflow.com/questions/66228627/how-can-i-change-the-labels-of-the-continue-cancel-buttons-in-flutter-stepper
// check answer below first anwer to change last step to save and not continue (Y)

class AddMemberDialogState extends State<AddMemberDialog> {
  final nameInput = TextEditingController();
  Store store = Store();
  int _currentStep = 0;

  double _sB = 0.0;
  double _startingBalance = 10.0;

  stepTapped(int step) {
    setState(() => _currentStep = step);
  }

  stepContinued() {
    _currentStep < 1 ? setState(() => _currentStep += 1) : saveMember();
  }

  stepCanceled() {
    _currentStep > 0 ? setState(() => _currentStep -= 1) : null;
  }

  _amountIncrease() => setState(() => _startingBalance += 0.01);

  _amountDecrease() => setState(() => _startingBalance -= 0.01);

  saveMember() async {
    if (nameInput.text == "") {
      _showDialog("Please enter a name.");
      return null;
    }
    await store.addMember(
      Member(
          id: '0',
          name: nameInput.text,
          bank: double.parse(_startingBalance.toStringAsFixed(2))),
    );
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    nameInput.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Member'),
      ),
      body: Stepper(
        type: StepperType.vertical, //try horz too
        physics: ScrollPhysics(),
        currentStep: _currentStep,
        onStepTapped: (step) => stepTapped(step),
        onStepCancel: stepCanceled,
        onStepContinue: stepContinued,
        controlsBuilder: controlsBuilder,
        steps: <Step>[
          Step(
            title: Text('Name'),
            content: TextFormField(
              controller: nameInput,
              textCapitalization: TextCapitalization.words,
              maxLines: 1,
              decoration: InputDecoration(
                labelText: 'Name',
              ),
            ),
            isActive: _currentStep >= 0,
            state: _currentStep >= 0 ? StepState.complete : StepState.disabled,
          ),
          Step(
            //REBUILD INPUT HERE...
            title: Text('Amount'),
            // content: DecimalNumberPicker(
            //   value: _startingBalance,
            //   minValue: 0,
            //   maxValue: 50,
            //   decimalPlaces: 2,
            //   onChanged: (value) =>
            //       setState(() => _startingBalance = value.toDouble()),
            // ),
            isActive: _currentStep >= 0,
            state: _currentStep >= 1 ? StepState.complete : StepState.disabled,
            // content: Column(
            //   children: [
            //     Row(
            //       children: [
            //         moneyInput(1),
            //         moneyInput(2),
            //         moneyInput(3),
            //       ],
            //     ),
            //     Row(
            //       children: [
            //         moneyInput(4),
            //         moneyInput(5),
            //         moneyInput(6),
            //       ],
            //     ),
            //     Row(
            //       children: [
            //         moneyInput(7),
            //         moneyInput(8),
            //         moneyInput(9),
            //       ],
            //     ),
            //     Row(
            //       children: [
            //         moneyInput(10.17),
            //         moneyInput(0),
            //         moneyInput("C"),
            //       ],
            //     ),
            //  ],
            //),
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
                    "£${_startingBalance.toStringAsFixed(2)}",
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
        ],
      ),
    );
  }

  Widget moneyInput(var i) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: TextButton(
        onPressed: () => print(i),
        child: SizedBox(
          height: 50,
          width: 50,
          child: Center(
            child: Text(
              i.toString(),
              //style: TextStyle(color: Theme.of(context).primaryColor),
            ),
          ),
        ),
        style: ButtonStyle(
            // shape: MaterialStateProperty.all(RoundedRectangleBorder(
            //     borderRadius: BorderRadius.circular(30.0))),
            backgroundColor:
                MaterialStateProperty.all(Theme.of(context).backgroundColor)),
      ),
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
              // : _currentStep == 1
              //     ? Container(
              //         child: Row(
              //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //           children: [
              //             TextButton(
              //               onPressed: stepContinued,
              //               child: const Text('NEXT'),
              //             ),
              //             TextButton(
              //               onPressed: stepCanceled,
              //               child: const Text('BACK'),
              //             ),
              //           ],
              //         ),
              //       )
              : _currentStep >= 1
                  ? Container(
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
                  : TextButton(
                      onPressed: stepCanceled,
                      child: const Text('BACK'),
                    ),
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
