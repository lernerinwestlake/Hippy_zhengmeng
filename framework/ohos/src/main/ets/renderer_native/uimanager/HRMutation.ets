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
import { HippyMap } from '../../support/common/HippyTypes'

export enum HRMutationType {
  CREATE = 1,
  UPDATE = 2,
  MOVE = 3,
  MOVE2 = 4,
  DELETE = 5,
  UPDATE_LAYOUT = 6,
  UPDATE_EVENT_LISTENER = 7,
}

export class HRCreateMutation {
  type: HRMutationType
  viewName: string | null = null
  tag: number | null = null
  parentTag: number | null = null
  index: number | null = null
  props: HippyMap | null = null

  constructor() {
    this.type = HRMutationType.CREATE
  }
}

export class HRUpdateMutation {
  type: HRMutationType
  viewName: string | null = null
  tag: number | null = null
  parentTag: number | null = null
  index: number | null = null
  props: HippyMap | null = null

  constructor() {
    this.type = HRMutationType.UPDATE
  }
}

export class HRMoveMutation {
  type: HRMutationType
  tag: number | null = null
  parentTag: number | null = null
  index: number | null = null

  constructor() {
    this.type = HRMutationType.MOVE
  }
}

export class HRMove2Mutation {
  type: HRMutationType
  tag: number | null = null
  toParentTag: number | null = null
  fromParentTag: number | null = null
  index: number | null = null

  constructor() {
    this.type = HRMutationType.MOVE2
  }
}

export class HRDeleteMutation {
  type: HRMutationType
  tag: number | null = null

  constructor() {
    this.type = HRMutationType.DELETE
  }
}

export class HRUpdateLayoutMutation {
  type: HRMutationType
  tag: number | null = null
  left: number | null = null
  top: number | null = null
  width: number | null = null
  height: number | null = null
  constructor() {
    this.type = HRMutationType.UPDATE_LAYOUT
  }
}

export class HRUpdateEventListenerMutation {
  type: HRMutationType
  tag: number | null = null
  props: HippyMap | null = null
  constructor() {
    this.type = HRMutationType.UPDATE_EVENT_LISTENER
  }
}

export type HRMutation = HRCreateMutation
  | HRUpdateMutation
  | HRMoveMutation
  | HRMove2Mutation
  | HRDeleteMutation
  | HRUpdateLayoutMutation
  | HRUpdateEventListenerMutation