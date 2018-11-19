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

@JS()
library incremental_dom;

import 'dart:html';
import 'package:js/js.dart';

@JS('IncrementalDOM')
abstract class dom {
  /// Write `content` as HTML text.
  external static void text(String content);

  /// Opens the head of a new element `tagName`
  external static void elementOpenStart(String tagName);

  /// Closes the head of the last element opened with [elementOpenStart].
  external static void elementOpenEnd();

  /// Closes the last element named `tagName`.
  external static void elementClose(String tagName);

  /// Writes an attribute `name` with `value` in the currently open element
  /// head.
  external static void attr(String name, Object value);

  /// Update the DOM hosted on `host` with the `renderer`.
  external static void patch(Node host, Function renderer);
}
