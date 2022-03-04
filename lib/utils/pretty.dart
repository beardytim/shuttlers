String prettyMoney(double ammount) {
  //Want negative ammounts to show -£1.00 rather than £-1.00
  if (ammount < 0) {
    return ['-£', ammount.toStringAsFixed(2).substring(1)].join();
  } else {
    return ['£', ammount.toStringAsFixed(2)].join();
  }
}

String prettyDate(DateTime date) {
  //displays date as DD/MM/YY
  return [
    date.day.toString().padLeft(2, '0'),
    '/',
    date.month.toString().padLeft(2, '0'),
    '/',
    // date.year.toString().substring(2)
    date.year.toString().substring(2)
  ].join();
}

String prettyShare(String name, double balance) {
  name = name.padRight(9, ' ');
  String bank = prettyMoney(balance).padLeft(7, ' ');
  return '| ' + name + '|' + bank + ' |';
}

String prettyDateNoYear(DateTime date) {
  return [
    date.day.toString().padLeft(2, '0'),
    '/',
    date.month.toString().padLeft(2, '0'),
  ].join();
}
