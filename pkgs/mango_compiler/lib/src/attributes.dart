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

/// A scanner-less parser for the attribute grammar.
///
/// Supported attributes:
///   attr="value"
///   attr
///   attr="{{value}}"
///
class AttributeParser {
  /// Creates a new [AttributeParser] from a slice of source bytes.
  AttributeParser(this.source, this.start, this.end);

  /// The source string the attribute is parsed from.
  final List<int> source;

  /// The start of the attribute source.
  final int start;

  /// The end of the attribute source.
  final int end;

  int _offset = 0;

  /// Parse an attribute node.
  AttributeNode parse() {
    while (_offset + start < end && _current == $space) {
      _offset += 1;
    }
    int nameStart = start + _offset;
    while (_offset + start < end && _current != $equal) {
      _offset += 1;
    }
    final name = String.fromCharCodes(source, nameStart, start + _offset);
    if (_current != $equal) {
      return AttributeNode(name: name);
    }
    _offset += 1;
    if (_current != $double_quote) {
      throw StateError("");
    }
    _offset += 1;
    if (_current == $open_brace) {
      _offset += 1;
      if (_current != $open_brace) {
        throw StateError('');
      }
      _offset += 1;
      int valueStart = _offset + start;
      while (_offset + start < end && _current != $close_brace) {
        _offset += 1;
      }
      final value = String.fromCharCodes(source, valueStart, start + _offset);
      return AttributeNode(name: name, value: value, isInterpolated: true);
    } else {
      int valueStart = start + _offset;
      while (_offset + start < end && _current != $double_quote) {
        _offset += 1;
      }
      final value = String.fromCharCodes(source, valueStart, start + _offset);
      return AttributeNode(name: name, value: value);
    }
  }

  int get _current => source[start + _offset];
}
