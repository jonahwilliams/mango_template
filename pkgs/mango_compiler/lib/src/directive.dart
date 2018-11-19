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

import 'ast.dart';

/// A scanner-less parser for the limited subset of directive expressions.
///
/// These are all of the valid directive expressions:
///
/// {{identifier}}
/// {{#if identifier}}
/// {{/if}}
/// {{#for local in identifier}}
/// {{/for}}
///
/// `identifier` must correspond to a valid dart identifier. No expressions are
/// supported, even `.` expressions.
class DirectiveParser {
  DirectiveParser(this.source, this.start, this.end);

  final List<int> source;
  final int start;
  final int end;
  int _offset = 0;

  /// Produce a single directive node from a raw directive expression string.
  ///
  /// TODO(jonahwilliams): This is a mess...
  DirectiveNode parse() {
    // consume whitespace.
    while (_current == $space) {
      _offset += 1;
    }
    if (_current == $slash) {
      _offset += 1;
      if (_expect('if')) {
        return DirectiveNode(kind: DirectiveKind.EndIf);
      } else if (_expect('for')) {
        return DirectiveNode(kind: DirectiveKind.EndFor);
      } else {
        throw StateError('Unknown directive');
      }
    } else if (_current == $hash) {
      _offset += 1;
      if (_expect('if')) {
        while (_current == $space) {
          _offset += 1;
        }
        final int identifierStart = start + _offset;
        while (_offset + start < end && _current != $space) {
          _offset += 1;
        }
        final identifier = String.fromCharCodes(
            source.sublist(identifierStart, start + _offset));
        return DirectiveNode(identifier: identifier, kind: DirectiveKind.If);
      } else if (_expect('for')) {
        while (_current == $space) {
          _offset += 1;
        }
        final int localStart = start + _offset;
        while (_offset + start < end && _current != $space) {
          _offset += 1;
        }
        final local = String.fromCharCodes(
            source.sublist(localStart, start + _offset));
        while (_current == $space) {
          _offset += 1;
        }
        if (!_expect('in')) {
          throw StateError('Unknown directive');
        }
        while (_current == $space) {
          _offset += 1;
        }
        final identifierStart = start + _offset;
        while (_offset + start < end && _current != $space) {
          _offset += 1;
        }
        final identifier = String.fromCharCodes(
            source.sublist(identifierStart, start + _offset));
        return DirectiveNode(
          identifier: identifier,
          local: local,
          kind: DirectiveKind.ForLoop,
        );
      } else {
        throw StateError('Unknown directive');
      }
    } else {
      final int identifierStart = start + _offset;
      while (_offset + start < end && _current != $space) {
        _offset += 1;
      }
      final identifier = String.fromCharCodes(
          source.sublist(identifierStart, start + _offset));
      return DirectiveNode(
          identifier: identifier, kind: DirectiveKind.Interpolation);
    }
  }

  int get _current => source[_offset + start];

  bool _expect(String word) {
    int move = 0;
    for (int char in word.runes) {
      if (_offset < source.length && _current == char) {
        move += 1;
        _offset += 1;
      } else {
        _offset -= move;
        return false;
      }
    }
    return true;
  }
}
