import 'package:incremental_dom/incremental_dom.dart';

void template(dynamic scope) {
  if (scope.isWorldWide) {
    dom.elementOpenStart('p');
    dom.elementOpenEnd();
    dom.text('Hello, World');
    dom.elementClose('p');
  }
  dom.elementOpenStart('button');
  dom.attr('onclick', scope.onClick);
  dom.elementOpenEnd();
  dom.text('Click Me');
  dom.elementClose('button');
}
