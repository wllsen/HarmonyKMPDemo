/*
 * Tencent is pleased to support the open source community by making KuiklyUI
 * available.
 * Copyright (C) 2025 Tencent. All rights reserved.
 * Licensed under the License of KuiklyUI;
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * https://github.com/Tencent-TDS/KuiklyUI/blob/main/LICENSE
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include "libohos_render/expand/modules/content_size/KRContentSizeModule.h"

#include "libohos_render/manager/KRArkTSManager.h"
#include "libohos_render/scheduler/KRContextScheduler.h"
#include "libohos_render/utils/KRStringUtil.h"
#include "thirdparty/cJSON/cJSON.h"

namespace kuikly {
namespace module {
constexpr char kMethodReportSize[] = "reportSize";
constexpr char kKeyWidth[] = "width";
constexpr char kKeyHeight[] = "height";

const char KRContentSizeModule::MODULE_NAME[] = "KRContentSizeModule";

static bool ParseSize(const KRAnyValue &params, double &width, double &height) {
    if (params == nullptr) {
        return false;
    }
    auto json = params->toString();
    if (json.empty()) {
        return false;
    }
    auto obj = cJSON_Parse(json.c_str());
    if (obj == nullptr) {
        return false;
    }
    auto width_item = cJSON_GetObjectItem(obj, kKeyWidth);
    auto height_item = cJSON_GetObjectItem(obj, kKeyHeight);
    bool valid = cJSON_IsNumber(height_item);
    if (cJSON_IsNumber(width_item)) {
        width = width_item->valuedouble;
    }
    if (valid) {
        height = height_item->valuedouble;
    }
    cJSON_Delete(obj);
    return valid;
}

KRAnyValue KRContentSizeModule::CallMethod(bool sync, const std::string &method, KRAnyValue params,
                                           const KRRenderCallback &callback) {
    (void)callback;
    if (!kuikly::util::isEqual(method, kMethodReportSize)) {
        return KREmptyValue();
    }
    double width = 0;
    double height = 0;
    if (!ParseSize(params, width, height) || height <= 0) {
        return KREmptyValue();
    }
    auto instance_id = GetInstanceId();
    KRContextScheduler::ScheduleTaskOnMainThread(sync, [instance_id, width, height] {
        KRArkTSManager::GetInstance().CallArkTSMethod(
            instance_id, KRNativeCallArkTSMethod::ContentSizeChanged, KRRenderValue::Make(width),
            KRRenderValue::Make(height), nullptr, nullptr, nullptr, nullptr);
    });
    return KREmptyValue();
}
}  // namespace module
}  // namespace kuikly
