//
//  ObjectModel.swift
//  DesignScape
//
//  Created by Minh Huynh on 2/28/24.
//

import ARKit
import RoomPlan

// An Object Model to display in AR space
struct ObjectModel: Equatable {
    var dimensions: simd_float3
    var transform: simd_float4x4
    var category: CapturedRoom.Object.Category

    init(dimensions: simd_float3, transform: simd_float4x4, category: CapturedRoom.Object.Category) {
        self.dimensions = dimensions
        self.transform = transform
        self.category = category
    }
}
