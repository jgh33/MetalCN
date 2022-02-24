//
//  ShapeType.swift
//  RenderPass
//
//  Created by 焦国辉 on 2022/2/23.
//

import Foundation
import simd
struct Vertex {
    var position: vector_float2
    var color: vector_float4
    
    init(_ position: vector_float2, _ color: vector_float4) {
        self.position = position
        self.color = color
    }
  
}

struct VertexT {
    var position: vector_float2
    var textureCoordinate: vector_float2
    
    init(_ position: vector_float2, _ textureCoordinate: vector_float2) {
        self.position = position
        self.textureCoordinate = textureCoordinate
    }
}

