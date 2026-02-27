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
import { IKuiklyViewDelegate } from './KRNativeRenderController';
import { KRAutoSizeNativeRender } from './KRAutoSizeNativeRender';

/**
 * @brief View粒度入口类（自动内容尺寸）
 */
@Component
export struct KRNativeAutoSize {
  /** 页面名字 */
  pageName: string = 'router';
  /** 透传给KR侧的页面数据 */
  pageParams: KRRecord = {};
  /** 执行模式 */
  executeMode: KRRenderExecuteModeBase = KRRenderNativeMode.Native;
  /** 执行上下文code，驱动渲染对应的代码。KRRenderExecuteMode.Native模式时: 传递 '' */
  contextCode: string = '';
  /** KRNative Controller回调, 可获取此Controller来调用 KRNative 暴露的方法 */
  onControllerReadyCallback: KRNativeRenderControllerReadyCallback | null = null;
  nativeManager: KuiklyNativeManager | null = null;
  delegate?: IKuiklyViewDelegate;

  /** 自动尺寸下限，避免初始尺寸为0 */
  minWidth: number = 1;
  minHeight: number = 1;
  /** fit模式下的最大尺寸约束，支持数值和百分比字符串 */
  fitWidth: number | string = 0;
  fitHeight: number | string = 0;

  build() {
    KRAutoSizeNativeRender({
      pageName: this.pageName,
      pageData: this.pageParams,
      executeMode: this.executeMode,
      contextCode: this.contextCode,
      onControllerReadyCallback: this.onControllerReadyCallback,
      nativeManager: this.nativeManager,
      delegate: this.delegate,
      minWidth: this.minWidth,
      minHeight: this.minHeight,
      fitWidth: this.fitWidth,
      fitHeight: this.fitHeight
    });
  }
}
