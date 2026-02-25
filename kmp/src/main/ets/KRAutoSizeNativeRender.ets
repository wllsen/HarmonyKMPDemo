import { KRNativeRender } from './KRNativeRender';
import { IKuiklyViewDelegate, KRNativeRenderController } from './KRNativeRenderController';
import { KRNativeRenderControllerReadyCallback } from './manager/KRNativeInstance';
import { KRRecord } from './utils/KRDataTypes';
import { KuiklyNativeManager } from './native/KuiklyNativeManager';
import { ErrorReason } from './exception/KuiklyRenderExportExceptions';
import { KRRenderExecuteModeBase } from './context/KRRenderExecuteModeBase';
import { KRRenderNativeMode } from './context/KRRenderNativeMode';

@Component
export struct KRAutoSizeNativeRender {
  /** Kuikly 页面名（对应 Kotlin 侧 @Page 名称） */
  pageName: string = '';
  /** 透传给页面的数据 */
  pageData: KRRecord = {};
  executeMode: KRRenderExecuteModeBase = KRRenderNativeMode.Native;
  contextCode: string = '';
  assetsDir: string = '';
  useOhSharedPreferences: boolean = false;
  nativeManager: KuiklyNativeManager | null = null;
  delegate?: IKuiklyViewDelegate;
  pagerName?: string;
  pagerData?: KRRecord;
  pageParams?: KRRecord;
  onRenderException?: ((exception: Error, reason: ErrorReason) => void);
  onControllerReadyCallback: KRNativeRenderControllerReadyCallback | null = null;
  imeMode = false;
  /** 自动尺寸下限，避免初始 0 尺寸导致不可见 */
  minWidth: number = 1;
  minHeight: number = 1;
  /** 尺寸更新阈值，避免高频抖动触发重绘 */
  contentSizeEpsilon: number = 0.1;

  /** 当前内容宽高（由 native 内容尺寸回传驱动） */
  @State private contentWidth: number = 1;
  @State private contentHeight: number = 1;
  private controller: KRNativeRenderController | null = null;

  aboutToAppear(): void {
    this.contentWidth = Math.max(1, this.minWidth);
    this.contentHeight = Math.max(1, this.minHeight);
  }

  aboutToDisappear(): void {
    this.controller?.setAutoContentSizeChangedCallback(null);
    this.controller = null;
  }

  private onInnerControllerReady(controller: KRNativeRenderController): void {
    this.controller = controller;
    // 监听 native 回传的内容尺寸，并同步到组件宽高
    controller.setAutoContentSizeChangedCallback((width: number, height: number) => {
      const targetWidth = Math.max(this.minWidth, width);
      const targetHeight = Math.max(this.minHeight, height);
      if (Math.abs(targetWidth - this.contentWidth) >= this.contentSizeEpsilon) {
        this.contentWidth = targetWidth;
      }
      if (Math.abs(targetHeight - this.contentHeight) >= this.contentSizeEpsilon) {
        this.contentHeight = targetHeight;
      }
    });
    this.onControllerReadyCallback?.(controller);
  }

  build() {
    // 复用 KRNativeRender 核心能力，仅把外层尺寸策略改为“内容自适应”
    KRNativeRender({
      pageName: this.pageName,
      pageData: this.pageData,
      executeMode: this.executeMode,
      contextCode: this.contextCode,
      assetsDir: this.assetsDir,
      useOhSharedPreferences: this.useOhSharedPreferences,
      nativeManager: this.nativeManager,
      delegate: this.delegate,
      pagerName: this.pagerName,
      pagerData: this.pagerData,
      pageParams: this.pageParams,
      onRenderException: this.onRenderException,
      onControllerReadyCallback: (controller: KRNativeRenderController) => this.onInnerControllerReady(controller),
      imeMode: this.imeMode
    })
      // 外层尺寸由内容尺寸驱动，实现“宽高都自动”
      .width(this.contentWidth)
      .height(this.contentHeight);
  }
}
