import 'package:cloud_firestore/cloud_firestore.dart';

enum LedgerType {
  depost,
  reimbursement,
  game,
  equipment,
  starting,
}

enum IncomeType {
  deposit,
  reimbursement,
}

enum ExpenseType {
  game,
  equipment,
}

class Ledger implements Comparable<Ledger> {
  final DateTime date;
  final LedgerType type;
  final List<String> members;
  final double cost;
  final String membersString;

  const Ledger(
      {required this.date,
      required this.type,
      required this.members,
      required this.cost,
      required this.membersString});

  int compareTo(Ledger other) {
    int order = other.date.compareTo(date);
    return order;
  }

  Ledger.fromMap(Map<String, dynamic> data)
      : this(
          date: (data['date'] as Timestamp).toDate(),
          type: LedgerType.values[data['type']],
          members: List<String>.from(data['members']),
          cost: data['cost'].toDouble(),
          membersString: data['mString'].toString(),
        );
}
