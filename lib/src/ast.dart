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

import 'package:meta/meta.dart';

/// A vistor for the [AstNode] family.
abstract class AstNodeVisitor<R, C> {
  /// A const constructor to allow subclasses to be const.
  const AstNodeVisitor();

  /// Visit a [TextBlockNode].
  R visitTextBlockNode(TextBlockNode node, C context);

  /// Visit a [TextNode].
  R visitTextNode(TextNode node, C context);

  /// Visit an [DirectiveNode].
  R visitDirectiveNode(DirectiveNode node, C context);

  /// Visit an [ElementNode].
  R visitElementNode(ElementNode node, C context);

  /// Visit an [AttributeNode].
  R visitAttributeNode(AttributeNode node, C context);
}

/// The AST node for mango templates.
abstract class AstNode {
  /// A const constructor to allow subclasses to be const.
  const AstNode();
}

/// A block of one or more [TextNode] and [DirectiveNode].
class TextBlockNode extends AstNode {
  /// Creates a [TextBlockNode] from a list of children.
  ///
  /// Throws an [AssertionError] if `children` is null.
  const TextBlockNode(this.children) : assert(children != null);

  final List<AstNode> children;
}

/// A span of text within a [TextBlockNode].
class TextNode extends AstNode {
  /// Creates a new [TextNode] from a non-null String.
  ///
  /// Throws an [AssertionError] if `value` is null.
  const TextNode(this.value) : assert(value != null);

  /// The contents of the text node.
  final String value;

  @override
  int get hashCode => value.hashCode;

  @override
  bool operator ==(Object other) => other is TextNode && value == other.value;
}

enum DirectiveKind {
  ForLoop,
  EndFor,
  If,
  EndIf,
  Interpolation,
}

/// A directive expression.
class DirectiveNode extends AstNode {
  /// Creates a new [DirectiveNode] from a non-null idetifier.
  ///
  /// Throws an [AssertionError] if `kind` is null.
  const DirectiveNode({
    this.identifier,
    @required this.kind,
    this.local,
  })  : assert(kind != null);

  /// The Dart identifier bound to this node.
  ///
  /// This will be null on closing for and if directives.
  final String identifier;

  /// The name of the local created by a for loop.
  ///
  /// This will be null on if or interpolation kinds.
  final String local;

  /// The kind of directive this ast node corresponds to.
  final DirectiveKind kind;

  @override
  int get hashCode => identifier.hashCode ^ kind.hashCode ^ local.hashCode;

  @override
  bool operator ==(Object other) =>
      other is DirectiveNode &&
      identifier == other.identifier &&
      kind == other.kind &&
      local == other.local;
}

/// An html element.
class ElementNode extends AstNode {
  /// Creates a new [ElementNode] from a `tag`.
  ///
  /// Throws an [AssertionError] if `tag` is null.
  const ElementNode({
    @required this.tag,
    this.children = const <AstNode>[],
    this.attributes = const <AttributeNode>[],
  }) : assert(tag != null);

  /// The tag which defines this html element.
  ///
  /// For example, "div" or "span." This may also correspond to a custom
  /// element such as "my-checkbox" that is defined at runtime by the browser.
  final String tag;

  /// The child elements or text blocks.
  final List<AstNode> children;

  /// The attributes on this element.
  final List<AttributeNode> attributes;
}

/// An html attribute.
class AttributeNode extends AstNode {
  /// Creates a new [AttributeNode].
  ///
  /// Throws an [AssertionError] if `name` is null.
  const AttributeNode({@required this.name, this.value}) : assert(name != null);

  /// The name of the attribute, including any namespace.
  final String name;

  /// The value of the attribute.
  ///
  /// If null, this corresponds to an attribute with no value.
  final String value;

  @override
  int get hashCode => name.hashCode ^ value.hashCode;

  @override
  bool operator ==(Object other) =>
      other is AttributeNode && name == other.name && value == other.value;
}
