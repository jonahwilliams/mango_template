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
  group(DirectiveParser, () {
    test('can parse a closing if', () {
      expect(
          DirectiveParser('/if'.runes.toList(), 0, 3).parse(),
          DirectiveNode(
            identifier: null,
            local: null,
            kind: DirectiveKind.EndIf,
          ));
    });

    test('can parse a closing for', () {
      expect(
          DirectiveParser('/for'.runes.toList(), 0, 4).parse(),
          DirectiveNode(
            identifier: null,
            local: null,
            kind: DirectiveKind.EndFor,
          ));
    });

    test('can parse an identifier', () {
      expect(
          DirectiveParser('foo'.runes.toList(), 0, 3).parse(),
          DirectiveNode(
            identifier: 'foo',
            local: null,
            kind: DirectiveKind.Interpolation,
          ));
    });

    test('can parse an opening if', () {
      expect(
          DirectiveParser('#if bar'.runes.toList(), 0, 7).parse(),
          DirectiveNode(
            identifier: 'bar',
            local: null,
            kind: DirectiveKind.If,
          ));
    });

    test('can parse an opening for', () {
      expect(
          DirectiveParser('#for foo in foos'.runes.toList(), 0, 16).parse(),
          DirectiveNode(
            identifier: 'foos',
            local: 'foo',
            kind: DirectiveKind.ForLoop,
          ));
    });
  });
}
