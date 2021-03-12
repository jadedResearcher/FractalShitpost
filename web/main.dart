import 'dart:async';
import 'dart:html';

import 'scripts/Fractal.dart';

void main() {
  popup("Click and Drag. Press keys. There's sound.");
  new Fractal()..attach(querySelector('#output'));
}

void popup(String text) {
  final DivElement div = new DivElement()..setInnerHtml(text)..classes.add("popup");
  querySelector("body").append(div);
  StreamSubscription listener;
  listener= div.onMouseDown.listen((Event e) {
    div.remove();
    listener.cancel();
  });
}


