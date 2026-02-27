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

import { KRRecord } from './utils/KRDataTypes';
import { KRNativeRenderControllerReadyCallback } from './manager/KRNativeInstance';
import { KuiklyNativeManager } from './native/KuiklyNativeManager';
import { KRRenderNativeMode } from './context/KRRenderNativeMode';
import { KRRenderExecuteModeBase } from './context/KRRenderExecuteModeBase';
import { KRNativeRenderAutoHeight } from './KRNativeRenderAutoHeight';

@Component
export struct KRNativeAutoHeight {
  pageName: string = 'router';
  pageParams: KRRecord = {};
  executeMode: KRRenderExecuteModeBase = KRRenderNativeMode.Native;
  contextCode: string = '';
  onControllerReadyCallback: KRNativeRenderControllerReadyCallback | null = null;
  nativeManager: KuiklyNativeManager | null = null;
  minHeight: number = 1;
  width: string | number = '100%';

  build() {
    KRNativeRenderAutoHeight({
      pageName: this.pageName,
      pageData: this.pageParams,
      executeMode: this.executeMode,
      contextCode: this.contextCode,
      onControllerReadyCallback: this.onControllerReadyCallback,
      nativeManager: this.nativeManager,
      minHeight: this.minHeight,
      width: this.width
    });
  }
}
