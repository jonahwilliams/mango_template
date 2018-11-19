import 'dart:html';

import 'package:examples/src/hello_world.dart';
import 'package:examples/src/hello_world.html.dart';

void main() {
  final helloWorld = HelloWorldComponent();
  helloWorld.mount(querySelector('#output'), template);
}
