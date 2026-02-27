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
import { IKuiklyViewDelegate, KRNativeRenderController } from './KRNativeRenderController';
import common from '@ohos.app.ability.common';
import { KuiklyNativeManager } from './native/KuiklyNativeManager';
import { ErrorReason } from './exception/KuiklyRenderExportExceptions';
import { KRNativeManager } from './manager/KRNativeManager';
import { NodeContent, Size } from '@kit.ArkUI';
import render from 'libkuikly.so';
import { KRRenderExecuteModeBase } from './context/KRRenderExecuteModeBase';
import { KRRenderNativeMode } from './context/KRRenderNativeMode';
import { KRRect } from './foundation/KRRect';

@Component
export struct KRNativeRenderAutoHeight {
  pageName: string = '';
  pageData: KRRecord = {};
  executeMode: KRRenderExecuteModeBase = KRRenderNativeMode.Native;
  contextCode: string = '';
  assetsDir: string = '';
  useOhSharedPreferences: boolean = false;
  onControllerReadyCallback: KRNativeRenderControllerReadyCallback | null = null;
  nativeManager: KuiklyNativeManager | null = null;
  delegate?: IKuiklyViewDelegate;
  pagerName?: string;
  pagerData?: KRRecord;
  pageParams?: KRRecord;
  onRenderException?: ((exception: Error, reason: ErrorReason) => void);
  imeMode = false;
  initialSize?: Size;
  minHeight: number = 1;
  width: string | number = '100%';

  @State private contentHeight: number = 1;
  private controller?: KRNativeRenderController;
  private nodeContent: Content = new NodeContent();
  private loaded = false;

  loadNativeLibIfNeeded(): void {
    if (!this.loaded && this.nativeManager != null) {
      this.nativeManager?.internalDoLoad();
      this.loaded = true;
    }
  }

  aboutToAppear(): void {
    this.contentHeight = this.minHeight > 0 ? this.minHeight : 1;
    this.delegate?.getCustomRenderViewCreatorRegisterMap().forEach((value, key) => {
      KRNativeManager.getInstance().registerViewCreator(key, value);
    });
    this.delegate?.getCustomRenderViewCreatorRegisterMapV2().forEach((value, key) => {
      KRNativeManager.getInstance().registerViewCreatorV2(key, value);
    });
    this.delegate?.getCustomRenderModuleCreatorRegisterMap().forEach((value, key) => {
      KRNativeManager.getInstance().registerModuleCreator(key, value);
    });

    this.controller = this.delegate ?? new KRNativeRenderController();
    this.controller!.enableAutoHeight((height: number) => {
      if (height <= 0) {
        return;
      }
      this.contentHeight = Math.max(height, this.minHeight);
    });
    if (this.delegate != null) {
      const callback = this.delegate?.getKuiklyRenderViewLifecycleCallback();
      if (callback != null) {
        this.controller.addKuiklyRenderViewLifecycleCallback(callback);
      }
    }
    this.controller!.init(
      this.getUIContext(),
      getContext(this) as common.UIAbilityContext,
      this.executeMode,
      this.pagerName ?? this.pageName,
      this.pagerData ?? this.pageParams ?? this.pageData,
      this.contextCode,
      this.imeMode,
      this.assetsDir,
      this.useOhSharedPreferences
    );

    if (this.onRenderException) {
      this.controller!.registerExceptionCallback((executeMode, stack) => {
        this.onRenderException?.(new Error(stack), ErrorReason.UNKNOWN);
      });
    }
    this.onControllerReadyCallback?.(this.controller!);
    render.createNativeRoot(this.nodeContent, this.controller!.instanceId);
    this.loadNativeLibIfNeeded();
    if (this.initialSize) {
      this.controller!.onViewSizeChanged(new KRRect(0, 0, this.initialSize.width, this.initialSize.height));
    }
  }

  aboutToDisappear(): void {
    this.controller?.onAboutToDisappear();
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      ContentSlot(this.nodeContent);
    }
    .hitTestBehavior(HitTestMode.None)
    .width(this.width)
    .height(this.contentHeight)
    .onAttach(() => {
      this.loadNativeLibIfNeeded();
      this.controller!.onAttach();
    })
    .onAreaChange((_: Area, newValue: Area) => {
      this.controller!.onAreaChange(newValue);
    })
    .onSizeChange((_: SizeOptions, newValue: SizeOptions) => {
      this.controller!.onSizeChange(newValue);
    });
  }
}
