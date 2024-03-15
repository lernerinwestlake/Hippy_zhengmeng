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
import {
  HippyAny,
  HippyMap, HippyRenderCallback, HippyValue } from '../../support/common/HippyTypes'
import { LogUtils } from '../../support/utils/LogUtils'
import HippyRenderBaseView from '../components/base/HippyRenderBaseView'
import { HRRenderViewCreator } from '../components/HippyRenderRegisterMap'
import { HippyRenderView } from '../HippyRenderView'
import { NativeRenderContext } from '../NativeRenderContext'
import { HRRect } from '../utils/HRTypes'
import { HRCreateMutation,
  HRDeleteMutation,
  HRMutation, HRMutationType,
  HRUpdateEventListenerMutation,
  HRUpdateLayoutMutation,
  HRUpdateMutation } from './HRMutation'

export class HRViewManager {
  private readonly TAG = "HRViewManager"
  private ctx: NativeRenderContext
  private rootTag: number
  private rootRenderView: HippyRenderView | null = null
  private viewRegistry: Map<number, HippyRenderBaseView> = new Map()
  private viewCreatorRegisterMap: Map<string, HRRenderViewCreator> | null = null
  private mutations: HRMutation[] = []

  constructor(rootView: HippyRenderView) {
    this.ctx = rootView.ctx
    this.rootTag = rootView.ctx.getRootId()
    this.rootRenderView = rootView
    this.viewRegistry.set(this.rootTag, rootView)
  }

  getRootTag(): number {
    return this.rootTag
  }

  addMutations(m: HRMutation): void {
    this.mutations.push(m)
  }

  applyMutations(): void {
    for(let m of this.mutations) {
      this.applyMutation(m)
    }
    this.mutations.splice(0, this.mutations.length)
  }

  private applyMutation(mutation: HRMutation) {
    if (mutation.type === HRMutationType.CREATE) {
      let m = mutation as HRCreateMutation
      this.createRenderView(m.tag as number, m.viewName as string)
      this.insertSubRenderView(m.parentTag as number, m.tag as number, m.index as number)
      this.updateProps(m.tag as number, m.props as HippyMap)
    } else if (mutation.type === HRMutationType.UPDATE) {
      let m = mutation as HRUpdateMutation
      this.updateProps(m.tag as number, m.props as HippyMap)
    } else if (mutation.type === HRMutationType.MOVE) {
      // TODO(hot):
    } else if (mutation.type === HRMutationType.MOVE2) {
      // TODO(hot):
    } else if (mutation.type === HRMutationType.DELETE) {
      let m = mutation as HRDeleteMutation
      this.removeRenderView(m.tag as number)
    } else if (mutation.type === HRMutationType.UPDATE_LAYOUT) {
      let m = mutation as HRUpdateLayoutMutation
      this.setRenderViewFrame(m.tag as number, new HRRect(m.left as number, m.top as number, m.width as number, m.height as number))
    } else if (mutation.type === HRMutationType.UPDATE_EVENT_LISTENER) {
      let m = mutation as HRUpdateEventListenerMutation
      this.updateProps(m.tag as number, m.props as HippyMap)
    }
  }

  private createRenderView(tag: number, viewName: string): void {
    let renderView = this.createRenderViewFromCreator(viewName)
    if (renderView) {
      renderView.tag = tag
      renderView.viewType = viewName
      this.viewRegistry.set(tag, renderView)
    } else {
      LogUtils.d(this.TAG, "createRenderView: failed:  " + viewName)
    }
  }

  private removeRenderView(tag: number): void {
    let renderView = this.viewRegistry.get(tag)
    if (renderView) {
      renderView.removeFromParentView()
      this.removeFromRegistry(renderView)
    }
  }

  private removeFromRegistry(renderView: HippyRenderBaseView): void {
    for (let i = 0; i < renderView.children.length; i++) {
      const subView = renderView.children[i]
      this.removeFromRegistry(subView)
    }
    this.viewRegistry.delete(renderView.tag)
  }

  private insertSubRenderView(parentTag: number, childTag: number, index: number): void {
    let parentView = this.viewRegistry.get(parentTag)
    let childView = this.viewRegistry.get(childTag)
    if (parentView && childView) {
      parentView.addSubRenderView(childView, index)
    } else {
      LogUtils.d(this.TAG, "insertSubRenderView parentTag:" +
        parentTag + ", child:" + childTag)
    }
  }

  private updateProps(tag: number, props: HippyMap) {
    let renderView = this.viewRegistry.get(tag)
    if (renderView) {
      let theView = renderView as HippyRenderBaseView
      if (props.size > 0) {
        props.forEach((value: HippyValue, key: string) => {
          if (key && value) {
            theView.setProp(key, value)
          }
        })
      }
    }
  }

  private setRenderViewFrame(tag: number, frame: HRRect): void {
    let renderView = this.viewRegistry.get(tag)
    if (renderView) {
      renderView.setRenderViewFrame(frame)
    }
  }

  callViewMethod(tag: number, method: string, params: Array<HippyAny>, callback: HippyRenderCallback | null): void {
    let renderView = this.viewRegistry.get(tag)
    if (renderView) {
      renderView.call(method, params, callback)
    }
  }

  willDestroy(): void {

  }

  onDestroy(): void {

  }

  private createRenderViewFromCreator(viewName: string): HippyRenderBaseView | null {
    if (this.viewCreatorRegisterMap == null && this.rootRenderView) {
      this.viewCreatorRegisterMap = this.rootRenderView.getRenderViewCreatorRegisterMap()
    }
    if (this.viewCreatorRegisterMap) {
      let creator = this.viewCreatorRegisterMap.get(viewName)
      if (creator) {
        return creator(this.ctx)
      }
    }
    return null
  }

}