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

import 'ast.dart';
import 'directive.dart';
import 'scanner.dart';

class Parser {
  Parser(this.scanner);

  final Scanner scanner;
  final List<AstNode> result = <AstNode>[];
  final List<ElementNode> _elementStack = <ElementNode>[];
  Token _current;

  void parse() {
    scanner.scanAll();
    _current = scanner.head.next;
    while (_current != null) {
      switch (_current.kind) {
        case TokenKind.Error:
          return;
        case TokenKind.Text:
          _parseText();
          break;
        case TokenKind.BeginDirective:
          _parseDirective();
          break;
        case TokenKind.OpenCloseTag:
          _parseTag(true);
          break;
        case TokenKind.OpenTag:
          _parseTag(false);
          break;
        default:
          _fatal();
          return;
      }
    }
  }

  void _parseText() {
    final value = scanner.getSubstring(
        _current.offset, _current.offset + _current.length);
    // Trim newlines and empty space.
    if (value.isNotEmpty && value.trim().isNotEmpty) {
      result.add(TextNode(value));
    }
    _moveNext();
  }

  void _parseDirective() {
    _moveNext();
    if (_current.kind != TokenKind.DirectiveContent) {
      return _fatal();
    }
    final directiveParser = DirectiveParser(
      scanner.source,
      _current.offset,
      _current.offset + _current.length,
    );
    result.add(directiveParser.parse());
    _moveNext();
    if (_current.kind != TokenKind.EndDirective) {
      return _fatal();
    }
    _moveNext();
  }

  void _parseTag(bool isClosing) {
    _moveNext();
    if (_current.kind != TokenKind.TagName) {
      return _fatal();
    }
    final tagName = scanner.getSubstring(
        _current.offset, _current.offset + _current.length);
    _moveNext();
    if (_current.kind == TokenKind.CloseVoidTag) {
      result.add(ElementNode(tag: tagName));
      _moveNext();
    } else if (_current.kind == TokenKind.CloseTag) {
      if (!isClosing) {
        final element = ElementNode(tag: tagName);
        result.add(element);
        _elementStack.add(element);
      } else {
        final needle = _elementStack.removeLast();
        if (needle.tag != tagName) {
          return _fatal();
        }
        AstNode current = result.last;
        while (current != needle) {
          needle.children.insert(0, result.removeLast());
          current = result.last;
        }
      }
      _moveNext();
    } else {
      _fatal();
    }
  }

  void _moveNext() {
    _current = _current.next;
  }

  void _fatal() {
    _current = null;
    return;
  }
}
