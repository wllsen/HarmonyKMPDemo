import { KRAny, KRRecord, KuiklyRenderCallback } from '../utils/KRDataTypes';
import { KuiklyRenderBaseModule } from './export';

export class KRAutoSizeModule extends KuiklyRenderBaseModule {
  static readonly MODULE_NAME = 'KRAutoSizeModule';
  /** Native 侧回调 ArkTS 的方法名 */
  private static readonly METHOD_NOTIFY_CONTENT_SIZE_CHANGED = 'notifyContentSizeChanged';

  syncMode(): boolean {
    return false;
  }

  call(method: string, params: KRAny, callback: KuiklyRenderCallback | null): KRAny {
    switch (method) {
      case KRAutoSizeModule.METHOD_NOTIFY_CONTENT_SIZE_CHANGED: {
        if (typeof params === 'string') {
          // 接收 native 回传的根内容尺寸，并透传给 controller
          const data: KRRecord = JSON.parse(params);
          const width = Number(data['width'] ?? 0);
          const height = Number(data['height'] ?? 0);
          this.controller?.onAutoContentSizeChanged(width, height);
        }
        break;
      }
      default:
        break;
    }
    return null;
  }
}
