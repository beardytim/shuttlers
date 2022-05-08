import 'package:flutter/material.dart';
import 'package:holding_gesture/holding_gesture.dart';
import 'package:shuttlers/model/member.dart';
import 'package:shuttlers/utils/pretty.dart';
import 'package:shuttlers/utils/store.dart';
import 'package:shuttlers/model/expense.dart';

class AddFundsDialog extends StatefulWidget {
  final Member member;
  AddFundsDialog(this.member);
  @override
  AddFundsDialogState createState() => AddFundsDialogState();
}

class AddFundsDialogState extends State<AddFundsDialog> {
  DateTime _date = DateTime.now();

  String typeString = 'Deposit';
  IncomeType _incType = IncomeType.deposit;

  Store store = Store();

  double _fundsToAdd = 10.0;
  int _currentStep = 0;

  stepTapped(int step) {
    setState(() => _currentStep = step);
  }

  stepContinued() {
    _currentStep < 2 ? setState(() => _currentStep += 1) : saveFunds();
  }

  stepCanceled() {
    _currentStep > 0 ? setState(() => _currentStep -= 1) : null;
  }

  _amountIncrease() => setState(() => _fundsToAdd += 0.01);

  _amountDecrease() => setState(() => _fundsToAdd -= 0.01);

  _datePicker() async {
    _date = (await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().add(Duration(days: -30)),
      lastDate: DateTime.now(),
    ))!;

    setState(() {});
  }

  saveFunds() async {
    try {
      await store.addFunds(
        data: widget.member,
        funds: double.parse(_fundsToAdd.toStringAsFixed(2)),
        type: _incType,
        date: _date,
      );
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              "Added ${prettyMoney(_fundsToAdd)} to ${widget.member.name}.")));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Something went wrong.")));
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Funds to ${widget.member.name}'),
      ),
      body: Stepper(
        type: StepperType.vertical,
        physics: ScrollPhysics(),
        currentStep: _currentStep,
        onStepTapped: (step) => stepTapped(step),
        onStepCancel: stepCanceled,
        onStepContinue: stepContinued,
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
                    "£${_fundsToAdd.toStringAsFixed(2)}",
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
              trailing: PopupMenuButton<IncomeType>(
                onSelected: (IncomeType value) {
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
            isActive: _currentStep >= 0,
            state: _currentStep >= 2 ? StepState.complete : StepState.disabled,
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
              : _currentStep <= 1
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
                  : _currentStep == 2
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
}
