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

import 'dart:html';

import 'package:meta/meta.dart';
import 'package:incremental_dom/incremental_dom.dart';

/// The type of all rendering functions.
typedef Renderer = void Function(dynamic scope);

/// A singleton that enqueues changing components
class ChangeDetector {
  /// The single instance of the [ChangeDetector].
  static final instance = ChangeDetector();

  // Components that are enqueued to be changed.
  final _queue = <Component>[];
  int _timer;

  void _queueForCheck(Component component) {
    _queue.add(component);
    if (_timer == null) {
      _timer = window.requestAnimationFrame(_detectChanges);
    }
  }

  void _detectChanges(num _) {
    for (Component component in _queue) {
      dom.patch(component._host, () => component._renderer(component));
      component._isDirty = false;
    }
    _queue.clear();
    _timer = null;
  }
}

/// The base class for all mango templates.
abstract class Component {
  /// Whether the renderer needs to be invoked.
  bool _isDirty = false;

  /// The element where this component is hosted in the dom.
  Element _host;

  /// The renderer function created for this component.
  Renderer _renderer;

  /// Mount the component as a child of `host` using `renderer` to produce
  /// the initial dom.
  ///
  /// May only be called once for a given instance.
  void mount(Element host, Renderer renderer) {
    assert(_renderer == null);
    _host = host;
    _renderer = renderer;
    _isDirty = true;
    ChangeDetector.instance._queueForCheck(this);
  }

  @protected
  void setState(void Function() callback) {
    final result = callback() as dynamic;
    assert(() {
      if (result is Future) {
        throw StateError('setState may not be async');
      }
      return true;
    }());
    if (_isDirty) {
      return;
    }
    _isDirty = true;
    ChangeDetector.instance._queueForCheck(this);
  }
}
