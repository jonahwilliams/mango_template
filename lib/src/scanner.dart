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

import 'package:charcode/charcode.dart';

// Work on phrasing a bit here, perhaps capture the template.
const String errorMessage =
    'Unfortunately you found a bug in the mango template compiler'
    'Please file an issue on Github with information on how to reproduce this error';

/// A token that was scanned from input.
class Token {
  Token(this.offset, this.length, this.kind);

  /// The offset from the beginning of the file,
  final int offset;

  /// The length of the token.
  final int length;

  /// The kind of token.
  final TokenKind kind;

  /// The next token in the token stream, or null if EOF.
  Token next;

  /// The previous token in the token stream, or null of beginning of file.
  Token previous;

  @override
  String toString() => 'Token{$offset, $length, $kind}';
}

/// The type of token.
enum TokenKind {
  /// Beinning of token stream placeholder.
  Beginning,

  /// `<`
  OpenTag,

  /// `</`
  OpenCloseTag,

  /// `{{`
  BeginDirective,

  /// `}}`
  EndDirective,

  /// `/>`
  CloseVoidTag,

  /// `>`,
  CloseTag,

  /// Something went wrong while parsing.
  Error,

  /// A chunk of text,
  Text,

  /// Directive content,
  DirectiveContent,

  /// An THML tag name.
  TagName,

  /// Attribute content.
  AttributeContent,
}

/// The current state of the scanner.
enum ScannerState {
  /// Normal scanner state.
  Outside,

  /// In an directive expression.
  Directive,

  /// Expecting a tag name.
  ExpectingTagName,

  /// Expecting either attributes or closing.
  TagBody,
}

/// A scanner generates a token stream from a source string.
class Scanner {
  Scanner(this._source) {
    _head = _current;
  }

  final List<int> _source;

  Token _current = Token(-1, 0, TokenKind.Beginning);
  Token _head;
  int _offset = 0;
  int _bufferedOffset = -1;
  ScannerState _state = ScannerState.Outside;

  /// The beginning of the token stream.
  ///
  /// This is always a token with kind [TokenKind.Beginning].
  Token get head => _head;

  /// The current tail of the token stream.
  Token get current => _current;

  /// Scan all tokens.
  ///
  /// This is useful for most consumers of the token stream.
  void scanAll() {
    while (scanNext()) {}
  }

  /// Scan a single token at a time.
  ///
  /// This is useful when the state of the scanner needs to be mutated
  /// depending on how tokens are scanned.
  bool scanNext() {
    if (_offset >= _source.length) {
      _addBufferedToken();
      assert(_bufferedOffset == -1);
      return false;
    }
    int char = _source[_offset];
    switch (_state) {
      // Parsing outside of a directive or tag.
      case ScannerState.Outside:
        {
          switch (char) {
            // We've identified the beginning of an HTML tag.
            case $lt:
              _addBufferedToken();
              if (_peek() == $slash) {
                _addToken(Token(_offset, 2, TokenKind.OpenCloseTag));
                _offset += 2;
              } else {
                _addToken(Token(_offset, 1, TokenKind.OpenTag));
                _offset += 1;
              }
              _state = ScannerState.ExpectingTagName;
              return true;
            // We might have identified the beginning of a directive.
            case $open_brace:
              if (_peek() == $open_brace) {
                _addBufferedToken();
                _addToken(Token(_offset, 2, TokenKind.BeginDirective));
                _state = ScannerState.Directive;
                _offset += 2;
                return true;
              }
              continue next;

            /// Otherwise, we're just dealing with text.
            next:
            default:
              if (_bufferedOffset == -1) {
                _bufferedOffset = _offset;
              }
              _offset += 1;
              return true;
          }
          break;
        }
      case ScannerState.Directive:
        switch (char) {
          case $close_brace:
            if (_peek() == $close_brace) {
              _addBufferedToken();
              _addToken(Token(_offset, 2, TokenKind.EndDirective));
              _offset += 2;
              _state = ScannerState.Outside;
              return true;
            }
            continue next;
          next:
          default:
            if (_bufferedOffset == -1) {
              _bufferedOffset = _offset;
            }
            _offset += 1;
            return true;
        }
        break;
      case ScannerState.ExpectingTagName:
        switch (char) {
          // We've hit the end of the tag name.
          case $space:
            {
              _addBufferedToken();
              _offset += 1;
              _state = ScannerState.TagBody;
              return true;
            }
          // We've hit the end of tag itself. instead of switching right
          // to the end of tag, switch to TagBody state and don't increment
          // the offset.
          case $greater_than:
          case $slash:
            {
              _addBufferedToken();
              _state = ScannerState.TagBody;
              continue body;
            }
          default:
            if (_bufferedOffset == -1) {
              _bufferedOffset = _offset;
            }
            _offset += 1;
            return true;
        }
        break;
      body:
      case ScannerState.TagBody:
        {
          switch (char) {
            // End of the token.
            case $slash:
              if (_peek() != $greater_than) {
                _fatal();
                return false;
              }
              _addToken(Token(_offset, 2, TokenKind.CloseVoidTag));
              _offset += 2;
              _state = ScannerState.Outside;
              return true;
            case $greater_than:
              _addToken(Token(_offset, 1, TokenKind.CloseTag));
              _offset += 1;
              _state = ScannerState.Outside;
              return true;
            default:
              // TODO(jonahwilliams): support attributes.
              _offset += 1;
              return true;
          }
        }
    }
    return true;
  }

  /// Take any pending text content and emit a token for it.
  ///
  /// Returns true if a token was emitted, false otherwis.e
  bool _addBufferedToken() {
    if (_bufferedOffset == -1) {
      return false;
    }
    TokenKind kind;
    switch (_state) {
      case ScannerState.Outside:
        kind = TokenKind.Text;
        break;
      case ScannerState.Directive:
        kind = TokenKind.DirectiveContent;
        break;
      case ScannerState.ExpectingTagName:
        kind = TokenKind.TagName;
        break;
      default:
        throw StateError(errorMessage);
    }
    _addToken(Token(_bufferedOffset, _offset - _bufferedOffset, kind));
    _bufferedOffset = -1;
    return true;
  }

  void _addToken(Token nextToken) {
    _current.next = nextToken;
    nextToken.previous = _current;
    _current = nextToken;
  }

  int _peek() {
    if (_offset + 1 < _source.length) {
      return _source[_offset + 1];
    }
    return null;
  }

  /// End scanning with a fatal error.
  void _fatal() {
    _addToken(Token(-1, -1, TokenKind.Error));
    _offset = _source.length;
  }
}
