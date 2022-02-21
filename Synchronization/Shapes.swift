//
//  Shapes.swift
//  MetalCN
//
//  Created by 焦国辉 on 2022/2/20.
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

struct Triangle {
    var position: vector_float2
    var color: vector_float4
    
    init(_ position: vector_float2, _ color: vector_float4) {
        self.position = position
        self.color = color
    }
    
    static func vertices() -> [Vertex] {
        let size: Float = 64
        let color = vector_float4(1,1,1,1)

        let verteices = [
            Vertex(vector_float2(-0.5 * size, -0.5 * size),color),
            Vertex(vector_float2(0, 0.5 * size),color),
            Vertex(vector_float2(0.5 * size, -0.5 * size),color)
        ]
        return verteices
    }
    
//    static func vertexCount() -> Int {
//        return 3
//    }
}
