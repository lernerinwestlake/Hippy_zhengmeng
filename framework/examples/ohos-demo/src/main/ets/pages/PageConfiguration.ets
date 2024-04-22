/*
 * Tencent is pleased to support the open source community by making
 * Hippy available.
 *
 * Copyright (C) 2022 THL A29 Limited, a Tencent company.
 * All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import { router } from '@kit.ArkUI'
import { DriverSetting } from './DriverSetting'
import { RendererSetting } from './RendererSetting'

export enum DriverMode {
  JS_REACT,
  JS_VUE_2,
  JS_VUE_3,
  VL
}

export enum RenderMode {
  NATIVE,
  TDF_CORE,
  FLUTTER
}

const DEFAULT_DEBUG_SERVER_HOST:string = 'localhost:38989'

export class InitParams {
  driver:DriverMode = DriverMode.JS_REACT
  render:RenderMode = RenderMode.NATIVE
  isDebugMode:boolean = false
  isSnapShotMode:boolean = false
  debugServerHost:string = DEFAULT_DEBUG_SERVER_HOST
}

@Entry
@Component
struct PageConfiguration {
  @State driver:Resource = $r('app.string.driver_js_react')
  private driverSettingDlg:CustomDialogController = {} as CustomDialogController
  @Provide driverMode:DriverMode = DriverMode.JS_REACT

  private rendererSettingDlg:CustomDialogController = {} as CustomDialogController
  @Provide renderMode:RenderMode = RenderMode.NATIVE

  @State snapShotRadio:boolean = false
  @State debugRadio:boolean = false

  private debugServerHost:string = DEFAULT_DEBUG_SERVER_HOST

  onDriverSettingDlgCancel() {
    switch (this.driverMode) {
      case DriverMode.JS_REACT:
        this.driver =  $r('app.string.driver_js_react')
        break;
      case DriverMode.JS_VUE_2:
        this.driver =  $r('app.string.driver_js_vue2')
        break;
      case DriverMode.JS_VUE_3:
        this.driver =  $r('app.string.driver_js_vue3')
        break;
      case DriverMode.VL:
        this.driver =  $r('app.string.driver_js_vl')
        break;
    }
  }

  build() {
    Column() {
      Row() {
        RelativeContainer() {
          Row() {
            Image($r('app.media.back_2x'))
              .width(9)
              .height(17)
              .margin({ left: 10})
          }
          .width(55)
          .height(54)
          .onClick(() => {
            router.back()
          })
          .id('btn_back')
          .justifyContent(FlexAlign.Center)

          Text("Page Configuration")
            .fontColor(Color.Black)
            .fontWeight(500)
            .fontSize(17)
            .id('title')
            .alignRules({ middle: { anchor: "__container__", align: HorizontalAlign.Center},
              center: { anchor: "__container__", align: VerticalAlign.Center}})
        }
      }
      .height(54)
      .backgroundColor(Color.White)
      .width('100%')

      Scroll() {
        Column() {
          Column() {
            Text('General')
              .fontColor('#1E304A')
              .fontWeight(500)
              .fontSize(16)

            //Driver
            Row() {
              Image($r('app.media.page_config_driver_2x'))
                .width(24)
                .height(24)
                .margin({ left: 16 })
              Text('Driver')
                .margin({ left: 10 })
                .fontColor('#1E304A')
                .fontWeight(500)
                .fontSize(14)

              Blank()

              Row() {
                Text(this.driver)
                  .margin({ right: 10 })
                Image($r('app.media.page_config_forward_4x'))
                  .width(6)
                  .height(9)
              }
              .onClick(()=>{
                this.driverSettingDlg = new CustomDialogController({
                  builder:DriverSetting(),
                  autoCancel:true,
                  alignment:DialogAlignment.Bottom,
                  customStyle:true,
                  openAnimation:{duration:200},
                  closeAnimation:{duration:200, onFinish:()=>{
                    this.onDriverSettingDlgCancel()
                  }}
                })

                this.driverSettingDlg.open()
              })
            }
            .width('100%')
            .height(58)
            .margin({ top: 12 })
            .padding({ right: 24 })
            .backgroundColor(Color.White)

            //Render
            Row() {
              Image($r('app.media.page_config_driver_2x'))
                .width(24)
                .height(24)
                .margin({ left: 16 })
              Text('Renderer')
                .margin({ left: 10 })
                .fontColor('#1E304A')
                .fontWeight(500)
                .fontSize(14)

              Blank()

              Row() {
                Text('Native')
                  .margin({ right: 10 })
                Image($r('app.media.page_config_forward_4x'))
                  .width(6)
                  .height(9)
              }
              .onClick(()=>{
                this.rendererSettingDlg = new CustomDialogController({
                  builder:RendererSetting(),
                  autoCancel:true,
                  alignment:DialogAlignment.Bottom,
                  customStyle:true,
                  openAnimation:{duration:200},
                  closeAnimation:{duration:200, onFinish:()=>{
                    //this.onDriverSettingDlgCancel()
                  }}
                })

                this.rendererSettingDlg.open()
              })
            }
            .width('100%')
            .height(58)
            .margin({ top: 12 })
            .padding({ right: 24 })
            .backgroundColor(Color.White)

            //Node snapshot
            Row() {
              Image($r('app.media.page_config_debug_2x'))
                .width(24)
                .height(24)
                .margin({ left: 16 })
              Text('Node snapshot')
                .margin({ left: 10 })
                .fontColor('#1E304A')
                .fontWeight(500)
                .fontSize(14)

              Blank()

              Image(this.snapShotRadio ? $r('app.media.page_config_debug_on_2x') : $r('app.media.page_config_debug_off_2x') )
                .width(44)
                .height(22)
                .onClick(()=>{
                  this.snapShotRadio = !this.snapShotRadio
                })
            }
            .width('100%')
            .height(58)
            .margin({ top: 12 })
            .padding({ right: 24 })
            .backgroundColor(Color.White)

            //debug mode
            Row() {
              Image($r('app.media.page_config_debug_2x'))
                .width(24)
                .height(24)
                .margin({ left: 16 })
              Text('Debug Mode')
                .margin({ left: 10 })
                .fontColor('#1E304A')
                .fontWeight(500)
                .fontSize(14)

              Blank()

              Image(this.debugRadio ? $r('app.media.page_config_debug_on_2x') : $r('app.media.page_config_debug_off_2x') )
                .width(44)
                .height(22)
                .onClick(()=>{
                  this.debugRadio = !this.debugRadio
                })
            }
            .width('100%')
            .height(58)
            .margin({ top: 12 })
            .padding({ right: 24 })
            .backgroundColor(Color.White)

            if (this.debugRadio) {
              //debug server host
              Row() {
                TextInput({ text: DEFAULT_DEBUG_SERVER_HOST })
                  .margin({ top: 13, right: 16, left: 16, bottom: 13 })
                  .padding({ left: 12, top: 0, bottom: 0 })
                  .borderRadius(0)
                  .backgroundColor('#F6F8FB')
                  .fontColor('#7B889C')
                  .fontSize(14)
                  .onChange((value:string)=>{
                    this.debugServerHost = value
                  })
              }
              .width('100%')
              .height(58)
              .margin({ top: 1 })
              //.padding({top:13, right:16, left:16, bottom:13})
              .backgroundColor(Color.White)
            }
          }
          .alignItems(HorizontalAlign.Start)

          Image($r('app.media.page_config_create_2x'))
            .width(179)
            .height(44)
            .margin({top:34})
            .onClick(()=>{
              let params = new InitParams()
              params.driver = this.driverMode
              params.render = this.renderMode
              params.isDebugMode = this.debugRadio
              params.isSnapShotMode = this.snapShotRadio
              params.debugServerHost = this.debugServerHost

              router.replaceUrl({
                url: 'pages/ExampleHippyPage',
                params:params
              })
            })
        }
        .width('100%')
      }
      .width('100%')
      .padding({left:16, right:16, top:20})
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.home_background'))
    //.expandSafeArea()
  }
}