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

#include <sys/types.h>
#include <unistd.h>

#include <fstream>
#include <memory>
#include <string>
#include <vector>

#include "driver/base/common.h"
#include "footstone/logging.h"
#include "footstone/unicode_string_view.h"
#include "footstone/check.h"
#include "footstone/string_view_utils.h"

namespace hippy {
inline namespace driver {
inline namespace base {

class HippyFile {
 public:
  using unicode_string_view = footstone::stringview::unicode_string_view;
  static bool SaveFile(const unicode_string_view& file_name,
                       const std::string& content,
                       std::ios::openmode mode = std::ios::out |
                                                 std::ios::binary |
                                                 std::ios::trunc);
  static int RmFullPath(const unicode_string_view& dir_full_path);
  static int CreateDir(const unicode_string_view& dir_path, mode_t mode);
  static int CheckDir(const unicode_string_view& dir_path, int mode);
  static uint64_t GetFileModifyTime(const unicode_string_view& file_path);

  template <typename CharType>
  static bool ReadFile(const unicode_string_view& file_path,
                       std::basic_string<CharType>& bytes,
                       bool is_auto_fill) {
    auto file_path_str = footstone::StringViewUtils::ConvertEncoding(file_path,
                                                                     unicode_string_view::Encoding::Utf8).utf8_value();
    std::ifstream file(reinterpret_cast<const char*>(file_path_str.c_str()));
    if (!file.fail()) {
      file.ignore(std::numeric_limits<std::streamsize>::max());
      std::streamsize size = file.gcount();
      file.clear();
      file.seekg(0, std::ios_base::beg);
      size_t data_size;
      if (!footstone::check::numeric_cast<std::streamsize, size_t>(size + (is_auto_fill ? 1:0), data_size)) {
        file.close();
        return false;
      }
      bytes.resize(data_size);
      auto read_size =
          file.read(reinterpret_cast<char *>(&bytes[0]), size).gcount();
      if (size != read_size) {
        FOOTSTONE_DLOG(WARNING) << "ReadFile file_path = " << file_path << ", size = " << size
                                << ", read_size = " << read_size;
      }
      if (is_auto_fill) {
        bytes.back() = '\0';
      }
      file.close();
      FOOTSTONE_DLOG(INFO) << "ReadFile succ, file_path = " << file_path
                           << ", size = " << size
                           << ", read_size = " << read_size;
      return true;
    }
    FOOTSTONE_DLOG(INFO) << "ReadFile fail, file_path = " << file_path;
    return false;
  }
};

} // namespace base
} // namespace driver
} // namespace hippy
