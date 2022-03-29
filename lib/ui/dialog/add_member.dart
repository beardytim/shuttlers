import 'package:flutter/material.dart';
import 'package:holding_gesture/holding_gesture.dart';
import 'package:shuttlers/utils/store.dart';
import 'package:shuttlers/model/member.dart';

class AddMemberDialog extends StatefulWidget {
  AddMemberDialog();
  @override
  AddMemberDialogState createState() => AddMemberDialogState();
}

class AddMemberDialogState extends State<AddMemberDialog> {
  final nameInput = TextEditingController();
  Store store = Store();

  double _startingBalance = 10.0;
  int _currentStep = 0;

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
    try {
      await store.addMember(
        Member(
            id: '0',
            name: nameInput.text,
            bank: double.parse(_startingBalance.toStringAsFixed(2))),
      );
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Added ${nameInput.text}.")));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Something went wrong.")));
    }

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
        type: StepperType.vertical,
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
            title: Text('Amount'),
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
