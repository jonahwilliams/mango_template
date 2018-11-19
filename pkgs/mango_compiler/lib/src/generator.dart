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

/// The template generator consumes [AstNode]s and produces an incremental dom
/// template.
class TemplateGenerator extends AstNodeVisitor<void, void> {
  /// Creates a new [TemplateGenerator].
  TemplateGenerator(this.nodes);

  /// Build the template.
  ///
  /// This method is safe to call multiple times.
  String build() {
    _buffer
      ..clear()
      ..writeln(_imports)
      ..writeln('void template(dynamic scope) {');
    _indentLevel += 1;
    for (AstNode node in nodes) {
      node.accept(this, null);
    }
    _buffer.writeln('}');
    return _buffer.toString();
  }

  /// The [AstNode]s used to produce the template.
  final List<AstNode> nodes;

  static const _imports = "import 'package:incremental_dom/incremental_dom.dart';";

  final _buffer = StringBuffer();
  final _locals = <String>[];
  int _indentLevel = 0;

  @override
  void visitElementNode(ElementNode node, context) {
    _buffer.writeln('${_indent}dom.elementOpenStart(\'${node.tag}\');');
    for (AttributeNode attributeNode in node.attributes) {
      attributeNode.accept(this, null);
    }
    _buffer.writeln('${_indent}dom.elementOpenEnd();');
    for (AstNode child in node.children) {
      child.accept(this, null);
    }
    _buffer.writeln('${_indent}dom.elementClose(\'${node.tag}\');');
  }

  @override
  void visitAttributeNode(AttributeNode node, context) {
    _buffer.write('${_indent}dom.attr(\'${node.name}\', ');
    if (node.isInterpolated) {
      _buffer.writeln(_locals.contains(node.value) ? '${node.value});' : 'scope.${node.value});');
    } else {
      _buffer.writeln(node.value != null ? '\'${node.value}\'' : 'null');
    }
  }

  @override
  void visitDirectiveNode(DirectiveNode node, context) {
    switch (node.kind) {
      case DirectiveKind.EndFor:
        _locals.removeLast();
        continue next;
      next: case DirectiveKind.EndIf:
        _indentLevel -= 1;
        _buffer.writeln('${_indent}}');
        break;
      case DirectiveKind.ForLoop:
        _locals.add(node.local);
        _buffer.writeln('${_indent}for (var ${node.local} of scope.${node.identifier}) {');
        _indentLevel += 1;
        break;
      case DirectiveKind.If:
        _buffer.writeln('${_indent}if (scope.${node.identifier}) {');
        _indentLevel += 1;
        break;
      case DirectiveKind.Interpolation:
        _buffer.writeln('${_indent}dom.text(scope.${node.identifier});');
    }
  }

  @override
  void visitTextNode(TextNode node, context) {
    _buffer.writeln('${_indent}dom.text(\'${node.value}\');');
  }

  String get _indent => ' ' * (_indentLevel * 2);
}
