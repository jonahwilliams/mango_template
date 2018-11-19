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
  group(DirectiveNode, () {
    test('throws if constructed with null kind', () {
      expect(() => DirectiveNode(kind: null),
          throwsA(TypeMatcher<AssertionError>()));
    });

    test('is a value type', () {
      final left = DirectiveNode(identifier: 'hello', kind: DirectiveKind.If);
      final right = DirectiveNode(identifier: 'hello', kind: DirectiveKind.If);
      final foo = DirectiveNode(identifier: 'bar', kind: DirectiveKind.If);

      expect(left, equals(right));
      expect(right, equals(left));
      expect(left, isNot(equals(foo)));
      expect(left.hashCode, right.hashCode);
    });
  });

  group(TextNode, () {
    test('throws if constructed with null string', () {
      expect(() => TextNode(null), throwsA(TypeMatcher<AssertionError>()));
    });

    test('is a value type', () {
      final foo = TextNode('foo');
      final bar = TextNode('bar');
      final foo2 = TextNode('foo');

      expect(foo, equals(foo2));
      expect(foo2, equals(foo));
      expect(foo, isNot(equals(bar)));
      expect(foo.hashCode, foo2.hashCode);
    });
  });

  group(AttributeNode, () {
    test('throws if given a null name', () {
      expect(() => AttributeNode(name: null),
          throwsA(TypeMatcher<AssertionError>()));
    });

    test('is a value type', () {
      final foo = AttributeNode(name: 'foo', value: '3');
      final bar = AttributeNode(name: 'bar');
      final foo2 = AttributeNode(name: 'foo', value: '3');
      final foo3 = AttributeNode(name: 'foo', value: '5');

      expect(foo, equals(foo2));
      expect(foo2, equals(foo));
      expect(foo, isNot(equals(bar)));
      expect(foo, isNot(equals(foo3)));
      expect(foo.hashCode, equals(foo2.hashCode));
    });
  });
}
