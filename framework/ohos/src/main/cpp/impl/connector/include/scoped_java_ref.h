/*
 *
 * Tencent is pleased to support the open source community by making
 * Hippy available.
 *
 * Copyright (C) 2019 THL A29 Limited, a Tencent company.
 * All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

#pragma once

#include <any>
#include <js_native_api_types.h>

namespace hippy {
inline namespace framework {
inline namespace jni {

//class _jobject {};
//typedef _jobject *jobject;

class JavaRef {
 public:
  JavaRef(napi_env env, std::any obj);
  ~JavaRef();
  JavaRef(const JavaRef &) = delete;
  JavaRef &operator=(const JavaRef &) = delete;

  std::any GetObj() { return obj_; }

 private:
  std::any obj_;
};

}
}
}