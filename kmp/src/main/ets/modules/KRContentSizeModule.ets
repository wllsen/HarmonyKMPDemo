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

import { KRAny, KuiklyRenderCallback } from '../utils/KRDataTypes';
import { KuiklyRenderBaseModule } from './export';

interface KRContentSizeParams {
  width?: number;
  height?: number;
}

export class KRContentSizeModule extends KuiklyRenderBaseModule {
  static readonly MODULE_NAME = 'KRContentSizeModule';
  private static readonly METHOD_REPORT_SIZE = 'reportSize';

  syncMode(): boolean {
    return false;
  }

  call(method: string, params: KRAny, _callback: KuiklyRenderCallback | null): KRAny {
    if (method === KRContentSizeModule.METHOD_REPORT_SIZE) {
      this.reportSize(params);
    }
    return null;
  }

  private reportSize(params: KRAny): void {
    if (params == null) {
      return;
    }
    let data: KRContentSizeParams | null = null;
    if (typeof params === 'string') {
      try {
        data = JSON.parse(params) as KRContentSizeParams;
      } catch (_err) {
        return;
      }
    } else if (typeof params === 'object') {
      data = params as KRContentSizeParams;
    }
    if (data == null) {
      return;
    }
    this.controller?.onContentSizeChanged(
      Number(data.width ?? 0),
      Number(data.height ?? 0)
    );
  }
}
