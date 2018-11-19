// Copyright 2018 Jonah Williams. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:mango_compiler/mango_compiler.dart';
import 'package:test/test.dart';

void main() {
  group(TemplateGenerator, () {
    test('can generate dart code from an AST', () {
      final source = r'''
<div>Hello, World</div>
{{#if inCalifornia}}
<p>Sorry about the smoke {{name}}</p>
{{/if}}
'''.runes.toList();
      final List<AstNode> nodes = Parser(Scanner(source)).parse();
      final String template = TemplateGenerator(nodes).build();

      expect(template,
r'''
import 'package:incremental_dom/incremental_dom.dart';
void template(dynamic scope) {
  dom.elementOpenStart('div');
  dom.elementOpenEnd();
  dom.text('Hello, World');
  dom.elementClose('div');
  if (scope.inCalifornia) {
    dom.elementOpenStart('p');
    dom.elementOpenEnd();
    dom.text('Sorry about the smoke ');
    dom.text(scope.name);
    dom.elementClose('p');
  }
}
''');
    });
  });
}
