//
//  ShapeType.swift
//  DepthStencilTest
//
//  Created by 焦国辉 on 2022/2/22.
//

import Foundation

import simd

struct Vertex {
    var position: vector_float3
    var textureCoordinate: vector_float2
    
    init(_ position: vector_float3, _ textureCoordinate: vector_float2) {
        self.position = position
        self.textureCoordinate = textureCoordinate
    }
}
