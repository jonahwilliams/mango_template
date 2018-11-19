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
  group(Parser, () {
    test('can parse a simple template', () {
      const template = r'''
<div>Hello, World</div>
{{#if inCalifornia}}
<p>Sorry about the smoke {{name}}</p>
{{/if}}
''';
      final parser = Parser(Scanner(template.runes.toList()));
      expect(parser.parse(), [
        matchesElement('div', children: [equals(TextNode('Hello, World'))]),
        DirectiveNode(identifier: 'inCalifornia', kind: DirectiveKind.If),
        matchesElement('p', children: [
          equals(TextNode('Sorry about the smoke ')),
          equals(DirectiveNode(
              identifier: 'name', kind: DirectiveKind.Interpolation)),
        ]),
        DirectiveNode(kind: DirectiveKind.EndIf),
      ]);
    });

    test('can parse attributes', () {
      final source = r'''
<div attr1="bar" attr2="{{fiz}}"></div>
'''
          .runes
          .toList();
      final parser = Parser(Scanner(source));
      expect(parser.parse(), [
        matchesElement('div', attributes: [
          equals(AttributeNode(name: 'attr1', value: 'bar')),
          equals(AttributeNode(
            name: 'attr2',
            value: 'fiz',
            isInterpolated: true,
          )),
        ])
      ]);
    });
  });
}

Matcher matchesElement(
  String tag, {
  List<Matcher> attributes = const [],
  List<Matcher> children = const [],
}) {
  return _ElementMatcher(tag, children, attributes);
}

class _ElementMatcher extends Matcher {
  _ElementMatcher(this.tag, this.children, this.attributes);

  final String tag;
  final List<Matcher> children;
  final List<Matcher> attributes;

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
    if (item.attributes.length != attributes.length) {
      matchState['error'] =
          'Expected ${attributes.length} children, found ${item.attributes.length}';
      return false;
    }
    for (int i = 0; i < attributes.length; i++) {
      if (!attributes[i].matches(item.attributes[i], matchState)) {
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
