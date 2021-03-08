import 'dart:html';

import 'scripts/Fractal.dart';

void main() {
  new Fractal()..attach(querySelector('#output'));
}


