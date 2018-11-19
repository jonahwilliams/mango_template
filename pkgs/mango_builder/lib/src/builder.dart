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

import 'dart:async';

import 'package:build/build.dart';
import 'package:mango_compiler/mango_compiler.dart';

/// The mango builder creates a Dart template file from an HTML template and
/// Dart controller pair.
class MangoTemplateBuilder implements Builder {
  @override
  Future<void> build(BuildStep buildStep) async {
    final bytes = await buildStep.readAsBytes(buildStep.inputId);
    final scanner = Scanner(bytes);
    final parser = Parser(scanner);
    final nodes = parser.parse();
    final generator = TemplateGenerator(nodes);
    final dest = buildStep.inputId.addExtension('.dart');
    await buildStep.writeAsString(dest, generator.build());
  }

  @override
  final buildExtensions = const {
    '.html': ['.html.dart']
  };
}
