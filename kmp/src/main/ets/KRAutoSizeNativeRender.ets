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
  /** fit 模式下的外部宽高约束，支持 number 或百分比字符串（如 '50%'） */
  fitWidth: number | string = 0;
  fitHeight: number | string = 0;
  /** 尺寸更新阈值，避免高频抖动触发重绘 */
  contentSizeEpsilon: number = 0.1;

  /** 当前内容宽高（由 native 内容尺寸回传驱动） */
  @State private contentWidth: number = 1;
  @State private contentHeight: number = 1;
  /** 当 fit 使用百分比时，由外层容器回填的实际宽高上限 */
  @State private resolvedFitWidth: number = 0;
  @State private resolvedFitHeight: number = 0;
  private controller: KRNativeRenderController | null = null;

  private isPercentFit(value: number | string): boolean {
    return typeof value === 'string' && value.trim().endsWith('%');
  }

  private getFitWidthLimit(): number {
    if (typeof this.fitWidth === 'number') {
      return this.fitWidth;
    }
    return this.isPercentFit(this.fitWidth) ? this.resolvedFitWidth : 0;
  }

  private getFitHeightLimit(): number {
    if (typeof this.fitHeight === 'number') {
      return this.fitHeight;
    }
    return this.isPercentFit(this.fitHeight) ? this.resolvedFitHeight : 0;
  }

  private clampToFitSize(targetSize: number, fitLimit: number): number {
    if (fitLimit > 0) {
      return Math.min(targetSize, fitLimit);
    }
    return targetSize;
  }

  private computeTargetWidth(contentWidth: number): number {
    const base = Math.max(this.minWidth, contentWidth);
    return this.clampToFitSize(base, this.getFitWidthLimit());
  }

  private computeTargetHeight(contentHeight: number): number {
    const base = Math.max(this.minHeight, contentHeight);
    return this.clampToFitSize(base, this.getFitHeightLimit());
  }

  private onWrapperSizeChanged(newValue: SizeOptions): void {
    if (this.isPercentFit(this.fitWidth) && typeof newValue.width === 'number') {
      this.resolvedFitWidth = newValue.width;
    }
    if (this.isPercentFit(this.fitHeight) && typeof newValue.height === 'number') {
      this.resolvedFitHeight = newValue.height;
    }
  }

  @Builder
  private renderInner(): void {
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
      // 外层尺寸由内容尺寸驱动，实现“宽高都自动 / fit 约束”
      .width(this.contentWidth)
      .height(this.contentHeight);
  }

  aboutToAppear(): void {
    this.contentWidth = this.computeTargetWidth(1);
    this.contentHeight = this.computeTargetHeight(1);
  }

  aboutToDisappear(): void {
    this.controller?.setAutoContentSizeChangedCallback(null);
    this.controller = null;
  }

  private onInnerControllerReady(controller: KRNativeRenderController): void {
    this.controller = controller;
    // 监听 native 回传的内容尺寸，并同步到组件宽高
    controller.setAutoContentSizeChangedCallback((width: number, height: number) => {
      const targetWidth = this.computeTargetWidth(width);
      const targetHeight = this.computeTargetHeight(height);
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
    // 如果 fit 传了百分比，先由外层容器承接百分比约束，再把实际尺寸回填为 fit 上限
    if (this.isPercentFit(this.fitWidth) && this.isPercentFit(this.fitHeight)) {
      Stack() {
        this.renderInner();
      }
      .width(this.fitWidth as string)
      .height(this.fitHeight as string)
      .onSizeChange((_: SizeOptions, newValue: SizeOptions) => this.onWrapperSizeChanged(newValue));
    } else if (this.isPercentFit(this.fitWidth)) {
      Stack() {
        this.renderInner();
      }
      .width(this.fitWidth as string)
      .onSizeChange((_: SizeOptions, newValue: SizeOptions) => this.onWrapperSizeChanged(newValue));
    } else if (this.isPercentFit(this.fitHeight)) {
      Stack() {
        this.renderInner();
      }
      .height(this.fitHeight as string)
      .onSizeChange((_: SizeOptions, newValue: SizeOptions) => this.onWrapperSizeChanged(newValue));
    } else {
      this.renderInner();
    }
  }
}
