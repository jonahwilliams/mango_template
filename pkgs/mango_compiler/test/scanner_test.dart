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
  group(Scanner, () {
    test('can scan a string', () {
      final scanner = Scanner('Hello World'.runes.toList());
      scanner.scanAll();
      verifyTokens(scanner.head, [
        Token(0, 11, TokenKind.Text),
      ]);
    });

    test('can scan a string with interpolation', () {
      final scanner = Scanner('Hello {{world}}'.runes.toList());
      scanner.scanAll();
      verifyTokens(scanner.head, [
        Token(0, 6, TokenKind.Text),
        Token(6, 2, TokenKind.BeginDirective),
        Token(8, 5, TokenKind.DirectiveContent),
        Token(13, 2, TokenKind.EndDirective),
      ]);
    });

    test('can scan a string with interpolation and back to string', () {
      final scanner = Scanner('Hello {{world}}, boo'.runes.toList());
      scanner.scanAll();
      verifyTokens(scanner.head, [
        Token(0, 6, TokenKind.Text),
        Token(6, 2, TokenKind.BeginDirective),
        Token(8, 5, TokenKind.DirectiveContent),
        Token(13, 2, TokenKind.EndDirective),
        Token(15, 5, TokenKind.Text),
      ]);
    });

    test('can scan a tag', () {
      final scanner = Scanner('<div>'.runes.toList());
      scanner.scanAll();
      verifyTokens(scanner.head, [
        Token(0, 1, TokenKind.OpenTag),
        Token(1, 3, TokenKind.TagName),
        Token(4, 1, TokenKind.CloseTag),
      ]);
    });

    test('can scan a tag with closing', () {
      final scanner = Scanner('<div></div>'.runes.toList());
      scanner.scanAll();
      verifyTokens(scanner.head, [
        Token(0, 1, TokenKind.OpenTag),
        Token(1, 3, TokenKind.TagName),
        Token(4, 1, TokenKind.CloseTag),
        Token(5, 2, TokenKind.OpenCloseTag),
        Token(7, 3, TokenKind.TagName),
        Token(10, 1, TokenKind.CloseTag),
      ]);
    });

    test('can scan a tag with content', () {
      final scanner = Scanner('<div>Hello</div>'.runes.toList());
      scanner.scanAll();
      verifyTokens(scanner.head, [
        Token(0, 1, TokenKind.OpenTag),
        Token(1, 3, TokenKind.TagName),
        Token(4, 1, TokenKind.CloseTag),
        Token(5, 5, TokenKind.Text),
        Token(10, 2, TokenKind.OpenCloseTag),
        Token(12, 3, TokenKind.TagName),
        Token(15, 1, TokenKind.CloseTag),
      ]);
    });

    test('can scan a void token', () {
      final scanner = Scanner('<br/>'.runes.toList());
      scanner.scanAll();
      verifyTokens(scanner.head, [
        Token(0, 1, TokenKind.OpenTag),
        Token(1, 2, TokenKind.TagName),
        Token(3, 2, TokenKind.CloseVoidTag),
      ]);
    });

    test('can scan a node with attributes', () {
      final scanner = Scanner('<div attr1="foo" attr2="{{bar}}">'.runes.toList());
      scanner.scanAll();
      verifyTokens(scanner.head, [
        Token(0, 1, TokenKind.OpenTag),
        Token(1, 3, TokenKind.TagName),
        Token(5, 11, TokenKind.AttributeContent),
        Token(17, 15, TokenKind.AttributeContent),
        Token(32, 1, TokenKind.CloseTag),
      ]);
    });
  });
}

void verifyTokens(Token first, List<Token> tokens) {
  // Skip beginning.
  Token current = first.next;
  for (Token token in tokens) {
    expect(token, equalsToken(current));
    current = current.next;
  }
  expect(current, isNull);
}

Matcher equalsToken(Token token) {
  return _TokenMatcher(token);
}

class _TokenMatcher extends Matcher {
  _TokenMatcher(this.token);

  final Token token;

  @override
  Description describe(Description description) {
    return description.add(token.toString());
  }

  @override
  bool matches(covariant Token item, Map matchState) {
    if (token.kind != item.kind) {
      matchState['error'] = 'Expected ${token.kind}, found ${item.kind}';
      return false;
    }
    if (token.offset != item.offset) {
      matchState['error'] = 'Expected ${token.offset}, found ${item.offset}';
      return false;
    }
    if (token.length != item.length) {
      matchState['error'] = 'Expected ${token.length}, found ${item.length}';
      return false;
    }
    return true;
  }

  @override
  Description describeMismatch(
      item, Description mismatchDescription, Map matchState, bool verbose) {
    return mismatchDescription.add(matchState['error']);
  }
}
