import 'package:flutter/material.dart';
import 'package:shuttlers/model/expense.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shuttlers/utils/math.dart';
import 'package:shuttlers/utils/pretty.dart';

class ExpenseCard extends StatefulWidget {
  final Ledger ledger;

  ExpenseCard(this.ledger);

  @override
  ExpenseCardState createState() => ExpenseCardState();
}

class ExpenseCardState extends State<ExpenseCard> {
  Widget build(BuildContext context) {
    bool _equip = false;
    if (widget.ledger.type == LedgerType.equipment) {
      _equip = true;
    }

    _showCost(String cost, String costPerMember) {
      Fluttertoast.showToast(
        msg: "$cost - $costPerMember each",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        fontSize: 16.0,
        webPosition: "center",
        webBgColor: "#808080",
      );
    }

    return Column(
      children: [
        ListTile(
          title: Row(
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    prettyDate(widget.ledger.date),
                    style: _equip == true
                        ? TextStyle(fontStyle: FontStyle.italic)
                        : null,
                  ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                  child: Text(
                    _equip == true
                        ? "Equipment - ${widget.ledger.membersString}"
                        : widget.ledger.membersString,
                    style: _equip == true
                        ? TextStyle(fontStyle: FontStyle.italic)
                        : null,
                  ),
                ),
              ),
              Text(prettyMoney(widget.ledger.cost))
            ],
          ),
          onTap: () {
            _showCost(
                prettyMoney(widget.ledger.cost),
                prettyMoney((roundCost(
                    widget.ledger.cost / widget.ledger.members.length))));
          },
        ),
        Divider(),
      ],
    );

    // return Card(
    //   color: _equip == true ? Colors.white70 : null,
    //   elevation: 2.0,
    //   shape: RoundedRectangleBorder(
    //     borderRadius: BorderRadius.circular(10.0),
    //   ),
    //   child: ListTile(
    //     title: Row(
    //       children: <Widget>[
    //         Column(
    //           crossAxisAlignment: CrossAxisAlignment.start,
    //           children: <Widget>[
    //             Text(
    //               prettyDate(widget.ledger.date),
    //               style: _equip == true
    //                   ? TextStyle(fontStyle: FontStyle.italic)
    //                   : null,
    //             ),
    //           ],
    //         ),
    //         Expanded(
    //           child: Padding(
    //             padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
    //             child: Column(
    //               crossAxisAlignment: CrossAxisAlignment.start,
    //               children: <Widget>[
    //                 Text(
    //                   widget.ledger.membersString,
    //                   style: _equip == true
    //                       ? TextStyle(fontStyle: FontStyle.italic)
    //                       : null,
    //                 ),
    //               ],
    //             ),
    //           ),
    //         ),
    //       ],
    //     ),
    //     onTap: () {
    //       _showCost(prettyMoney(widget.ledger.cost),
    //           prettyMoney((widget.ledger.cost / widget.ledger.members.length)));
    //     },
    //   ),
    // );
  }
}
