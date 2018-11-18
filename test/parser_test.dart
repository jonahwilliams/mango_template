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

import 'package:mango_template/mango_template.dart';
import 'package:test/test.dart';

void main() {
  group(Parser, () {
    test('can parse a simple template', () {
      const template = r'''
<div>Hello, World</div>
{{#if inCalifornia}}
<p>Sorry about the smoke {{name}}</p>
{{/if}}
''';
      final parser = Parser(Scanner(template.runes.toList()));
      parser.parse();

      expect(parser.result, [
        matchesElement('div', [equals(TextNode('Hello, World'))]),
        DirectiveNode(identifier: 'inCalifornia', kind: DirectiveKind.If),
        matchesElement('p', [
          equals(TextNode('Sorry about the smoke ')),
          equals(DirectiveNode(
              identifier: 'name', kind: DirectiveKind.Interpolation)),
        ]),
        DirectiveNode(kind: DirectiveKind.EndIf),
      ]);
    });
  });
}

Matcher matchesElement(String tag, List<Matcher> children) {
  return _ElementMatcher(tag, children);
}

class _ElementMatcher extends Matcher {
  _ElementMatcher(this.tag, this.children);

  final String tag;
  final List<Matcher> children;

  @override
  Description describe(Description description) => description;

  @override
  bool matches(covariant ElementNode item, Map matchState) {
    if (item.tag != tag) {
      matchState['error'] = 'Expected ${tag}, found ${item.tag}';
      return false;
    }
    if (item.children.length != children.length) {
      matchState['error'] =
          'Expected ${children.length} children, found ${item.children.length}';
      return false;
    }
    for (int i = 0; i < children.length; i++) {
      if (!children[i].matches(item.children[i], matchState)) {
        return false;
      }
    }
    return true;
  }

  @override
  Description describeMismatch(
      item, Description mismatchDescription, Map matchState, bool verbose) {
    return mismatchDescription.add(matchState['error']);
  }
}
