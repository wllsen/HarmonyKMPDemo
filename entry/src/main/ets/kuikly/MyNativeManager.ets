import { KuiklyNativeManager } from '@kuikly-open/render';

export class MyNativeManager extends KuiklyNativeManager {
  protected loadNative(): number {
    // 当前工程还没有独立业务 so，这里先返回 0。
    // 如果后续接入业务 KMP 产物（例如 libentry.so），在这里执行初始化逻辑即可。
    return 0;
  }
}

