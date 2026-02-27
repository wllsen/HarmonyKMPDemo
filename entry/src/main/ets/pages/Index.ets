import { KRRecord, KRRenderNativeMode, KuiklyAutoSize } from '@kuikly-open/render';
import { MyNativeManager } from '../kuikly/MyNativeManager';
import { KuiklyViewDelegate } from '../kuikly/KuiklyViewDelegate';

@Entry
@Component
struct Index {
  private readonly nativeManager: MyNativeManager = new MyNativeManager();
  private readonly kuiklyDelegate: KuiklyViewDelegate = new KuiklyViewDelegate();

  @State pageName: string = 'TestPage';
  @State pageData: KRRecord = {};

  build() {
    Column() {
      KuiklyAutoSize({
        pageName: this.pageName,
        pageData: this.pageData,
        executeMode: KRRenderNativeMode.Native,
        delegate: this.kuiklyDelegate,
        nativeManager: this.nativeManager
      })
    }
    .width('100%')
    .height('100%')
  }
}
