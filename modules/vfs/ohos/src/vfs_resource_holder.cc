/*
 * Tencent is pleased to support the open source community by making
 * Hippy available.
 *
 * Copyright (C) 2022 THL A29 Limited, a Tencent company.
 * All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
#include "vfs/vfs_resource_holder.h"
#include "footstone/check.h"
#include "oh_napi/ark_ts.h"
#include "oh_napi/oh_napi_object.h"
#include "oh_napi/oh_napi_object_builder.h"

namespace hippy {
  inline namespace vfs {

    std::shared_ptr<ResourceHolder> ResourceHolder::Create(napi_env ts_env, napi_ref ts_holder_ref) {
      return std::make_shared<ResourceHolder>(ts_env, ts_holder_ref);
    }

    ResourceHolder::~ResourceHolder() {
      if (ts_holder_ref_) {
        ArkTS arkTs(ts_env_);
        arkTs.DeleteReference(ts_holder_ref_);
        ts_holder_ref_ = 0;
        ts_env_ = 0;
      }
    }

    UriHandler::RetCode CovertToUriHandlerRetCode(int code) {
      return (code == 0) ? UriHandler::RetCode::Success : UriHandler::RetCode::Failed;
    }

    std::unordered_map<std::string, std::string> TsMapToUnorderedMap(napi_env env, napi_value ts_map) {
      if (!ts_map) {
        return {};
      }
      std::unordered_map<std::string, std::string> ret_map;
      ArkTS arkTs(env);
      auto props = arkTs.GetObjectProperties(ts_map);
      for (auto it = props.begin(); it != props.end(); it++) {
        auto ts_key = it->first;
        auto ts_value = it->second;
        if (!ts_key || !ts_value) {
          continue;
        }
        auto key = arkTs.GetString(ts_key);
        auto value = arkTs.GetString(ts_value);
        ret_map[key] = value;
      }
      return ret_map;
    }

    napi_value UnorderedMapToTsMap(napi_env env, const std::unordered_map<std::string, std::string> &map) {
      ArkTS arkTs(env);
      auto ts_headers_builder = arkTs.CreateObjectBuilder();
      for (auto [key, value] : map) {
        ts_headers_builder.AddProperty(key.c_str(), value.c_str());
      }
      return ts_headers_builder.Build();
    }

    uint32_t ResourceHolder::GetNativeId() {
      FOOTSTONE_DCHECK(ts_holder_ref_);
      ArkTS arkTs(ts_env_);
      auto holder = arkTs.GetObject(ts_holder_ref_);
      auto ts_native_id = holder.Call("nativeRequestId", 0, 0);
      auto native_id = static_cast<uint32_t>(arkTs.GetInteger(ts_native_id));
      return native_id;
    }

    string_view ResourceHolder::GetUri() {
      FOOTSTONE_DCHECK(ts_holder_ref_);
      ArkTS arkTs(ts_env_);
      auto holder = arkTs.GetObject(ts_holder_ref_);
      auto ts_uri = holder.Call("uri", 0, 0);
      auto uri = arkTs.GetString(ts_uri);
      return string_view(uri);
    }

    RetCode ResourceHolder::GetCode() {
      FOOTSTONE_DCHECK(ts_holder_ref_);
      ArkTS arkTs(ts_env_);
      auto holder = arkTs.GetObject(ts_holder_ref_);
      auto ts_ret_code = holder.Call("resultCode", 0, 0);
      auto ret_code = arkTs.GetInteger(ts_ret_code);
      return CovertToUriHandlerRetCode(ret_code);
    }

    void ResourceHolder::SetCode(RetCode code) {
      FOOTSTONE_DCHECK(ts_holder_ref_);
      ArkTS arkTs(ts_env_);
      auto holder = arkTs.GetObject(ts_holder_ref_);
      std::vector<napi_value> args = { arkTs.CreateInt(static_cast<int>(code)) };
      holder.Call("resultCode", args);
    }

    std::unordered_map<std::string, std::string> ResourceHolder::GetReqMeta() {
      FOOTSTONE_DCHECK(ts_holder_ref_);
      ArkTS arkTs(ts_env_);
      auto holder = arkTs.GetObject(ts_holder_ref_);
      auto ts_req_map = holder.Call("requestHeaders", 0, 0);
      return TsMapToUnorderedMap(ts_env_, ts_req_map);
    }

    std::unordered_map<std::string, std::string> ResourceHolder::GetRspMeta() {
      FOOTSTONE_DCHECK(ts_holder_ref_);
      ArkTS arkTs(ts_env_);
      auto holder = arkTs.GetObject(ts_holder_ref_);
      auto ts_rsp_map = holder.Call("responseHeaders", 0, 0);
      return TsMapToUnorderedMap(ts_env_, ts_rsp_map);
    }

    void ResourceHolder::SetRspMeta(std::unordered_map<std::string, std::string> rsp_meta) {
      FOOTSTONE_DCHECK(ts_holder_ref_);
      ArkTS arkTs(ts_env_);
      auto holder = arkTs.GetObject(ts_holder_ref_);
      std::vector<napi_value> args = { UnorderedMapToTsMap(ts_env_, rsp_meta) };
      holder.Call("responseHeaders", args);
    }

    byte_string ResourceHolder::GetContent() {
      FOOTSTONE_DCHECK(ts_holder_ref_);
      ArkTS arkTs(ts_env_);
      auto holder = arkTs.GetObject(ts_holder_ref_);
      auto ts_content = holder.Call("buffer", 0, 0);

      void *buffer_data = NULL;
      size_t byte_length = 0;
      if (arkTs.IsArrayBuffer(ts_content)) {
        arkTs.GetArrayBufferInfo(ts_content, &buffer_data, &byte_length);
      }
  
      byte_string content;
      if (buffer_data != nullptr && byte_length > 0) {
        content.assign((char *)buffer_data, byte_length);
      }
      return content;
    }

    void ResourceHolder::SetContent(byte_string content) {
      FOOTSTONE_DCHECK(ts_holder_ref_);
      ArkTS arkTs(ts_env_);
      auto holder = arkTs.GetObject(ts_holder_ref_);

      void *new_buffer = malloc(content.size());
      FOOTSTONE_DCHECK(new_buffer != nullptr);
      if (!new_buffer) {
        FOOTSTONE_LOG(ERROR) << "ResourceHolder::SetContent, malloc fail, size = " << content.size();
        return;
      }
      memcpy(new_buffer, content.data(), content.size());

      auto ts_content = arkTs.CreateExternalArrayBuffer(new_buffer, content.size());
      std::vector<napi_value> args = { ts_content };
      holder.Call("buffer", args);
    }

    void ResourceHolder::FetchComplete(napi_ref ts_obj_ref) {
      FOOTSTONE_DCHECK(ts_holder_ref_);
      ArkTS arkTs(ts_env_);
      auto ts_obj = arkTs.GetObject(ts_obj_ref);
      std::vector<napi_value> args = { arkTs.GetReferenceValue(ts_holder_ref_) };
      ts_obj.Call("onFetchCompleted", args);
    }
  } // namespace vfs
} // namespace hippy
