import { hilog } from '@kit.PerformanceAnalysisKit';
import { router } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { IKRLogAdapter, IKRRouterAdapter, KRRecord, KuiklyRenderAdapterManager } from '@kuikly-open/render';

const DOMAIN = 0x0000;
const TAG = 'Kuikly';

class HarmonyLogAdapter implements IKRLogAdapter {
  d(tag: string, msg: string): void {
    hilog.debug(DOMAIN, TAG, '[%{public}s] %{public}s', tag, msg);
  }

  i(tag: string, msg: string): void {
    hilog.info(DOMAIN, TAG, '[%{public}s] %{public}s', tag, msg);
  }

  e(tag: string, msg: string): void {
    hilog.error(DOMAIN, TAG, '[%{public}s] %{public}s', tag, msg);
  }
}

class HarmonyRouterAdapter implements IKRRouterAdapter {
  openPage(_context: common.UIAbilityContext, pageName: string, pageData: KRRecord): void {
    router.pushUrl({
      url: pageName,
      params: pageData
    });
  }

  closePage(_context: common.UIAbilityContext): void {
    router.back();
  }
}

export class KuiklyAdapterManager {
  static init(): void {
    KuiklyRenderAdapterManager.krLogAdapter = new HarmonyLogAdapter();
    KuiklyRenderAdapterManager.krRouterAdapter = new HarmonyRouterAdapter();
  }
}

