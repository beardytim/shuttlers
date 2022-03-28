import 'dart:math';

//rounds up to 2 dec places.
double roundCost(double value) {
  var mod = pow(10.0, 2); //2 dec palces
  return ((value * mod).ceilToDouble() / mod);
}
