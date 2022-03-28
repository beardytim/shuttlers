import 'package:flutter/material.dart';
import 'package:shuttlers/model/expense.dart';
import 'package:shuttlers/utils/math.dart';
import 'package:shuttlers/utils/pretty.dart';

class HistoryCard extends StatelessWidget {
  final Ledger income;
  final int x;
  HistoryCard(this.income, this.x);

  Widget build(BuildContext context) {
    String _bodyText;
    String _trailingText;

    if (income.type == LedgerType.reimbursement ||
        income.type == LedgerType.depost) {
      _trailingText =
          '+${prettyMoney(roundCost(income.cost / income.members.length))}';
    } else if (income.type == LedgerType.starting) {
      _trailingText =
          '${prettyMoney(roundCost(income.cost / income.members.length))}';
    } else {
      _trailingText =
          '-${prettyMoney(roundCost(income.cost / income.members.length))}';
    }

    switch (income.type) {
      case LedgerType.depost:
        _bodyText = 'Deposit';
        break;
      case LedgerType.reimbursement:
        _bodyText = 'Reimbursement';
        break;
      case LedgerType.game:
        _bodyText = 'Game';
        break;
      case LedgerType.equipment:
        _bodyText = 'Equipment';
        break;
      case LedgerType.starting:
        _bodyText = 'Starting Balance';
        break;
    }

    return Column(
      children: [
        ListTile(
          tileColor: x.isEven ? Colors.grey[200] : null,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                prettyDate(income.date),
                textAlign: TextAlign.start,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                  child: Text(
                    _bodyText,
                  ),
                ),
              ),
              Text(
                _trailingText,
                textAlign: TextAlign.right,
              ),
            ],
          ),
        ),
        //Divider(),
      ],
    );
  }
}
