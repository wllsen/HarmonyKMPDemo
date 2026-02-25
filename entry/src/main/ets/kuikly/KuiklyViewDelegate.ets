import { IKuiklyViewDelegate, KRRenderModuleExportCreator, KRRenderViewExportCreator } from '@kuikly-open/render';

export class KuiklyViewDelegate extends IKuiklyViewDelegate {
  getCustomRenderViewCreatorRegisterMap(): Map<string, KRRenderViewExportCreator> {
    return new Map<string, KRRenderViewExportCreator>();
  }

  getCustomRenderModuleCreatorRegisterMap(): Map<string, KRRenderModuleExportCreator> {
    return new Map<string, KRRenderModuleExportCreator>();
  }
}

