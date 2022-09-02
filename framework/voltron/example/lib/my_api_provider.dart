//
// Tencent is pleased to support the open source community by making
// Hippy available.
//
// Copyright (C) 2019 THL A29 Limited, a Tencent company.
// All rights reserved.
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
//

import 'package:voltron_render/engine.dart';
import 'package:voltron_render_example/module/test_module.dart';
import 'package:voltron_renderer/voltron_renderer.dart';

class MyAPIProvider implements APIProvider {
  @override
  List<ModuleGenerator> get nativeModuleGeneratorList => [
        ModuleGenerator(
          TestModule.kModuleName,
          (context) => TestModule(context),
        ),
      ];

  @override
  List<JavaScriptModuleGenerator> get javaScriptModuleGeneratorList => [];

  @override
  List<ViewControllerGenerator> get controllerGeneratorList => [];
}