//
//  MatrixUtil.swift
//  MetalCN
//
//  Created by 焦国辉 on 2022/2/22.
//

import Foundation
import simd

struct MVPMatrix {
    var matrix: matrix_float4x4
}

extension matrix_float4x4 {
    init(translationMatrix position: vector_float3) {
        let X = vector_float4(1, 0, 0, 0)
        let Y = vector_float4(0, 1, 0, 0)
        let Z = vector_float4(0, 0, 1, 0)
        let W = vector_float4(position.x, position.y, position.z, 1)
        self.init(columns:(X, Y, Z, W))
    }

    init(scalingMatrix scale: Float) {
        let X = vector_float4(scale, 0, 0, 0)
        let Y = vector_float4(0, scale, 0, 0)
        let Z = vector_float4(0, 0, scale, 0)
        let W = vector_float4(0, 0, 0, 1)
        self.init(columns:(X, Y, Z, W))
    }

    init(rotationMatrix angle: Float, axis: vector_float3) {
        var X = vector_float4(0, 0, 0, 0)
        X.x = axis.x * axis.x + (1 - axis.x * axis.x) * cos(angle)
        X.y = axis.x * axis.y * (1 - cos(angle)) - axis.z * sin(angle)
        X.z = axis.x * axis.z * (1 - cos(angle)) + axis.y * sin(angle)
        X.w = 0.0
        var Y = vector_float4(0, 0, 0, 0)
        Y.x = axis.x * axis.y * (1 - cos(angle)) + axis.z * sin(angle)
        Y.y = axis.y * axis.y + (1 - axis.y * axis.y) * cos(angle)
        Y.z = axis.y * axis.z * (1 - cos(angle)) - axis.x * sin(angle)
        Y.w = 0.0
        var Z = vector_float4(0, 0, 0, 0)
        Z.x = axis.x * axis.z * (1 - cos(angle)) - axis.y * sin(angle)
        Z.y = axis.y * axis.z * (1 - cos(angle)) + axis.x * sin(angle)
        Z.z = axis.z * axis.z + (1 - axis.z * axis.z) * cos(angle)
        Z.w = 0.0
        let W = vector_float4(0, 0, 0, 1)
        self.init(columns:(X, Y, Z, W))
    }

    init (projectionMatrix near: Float, far: Float, aspect: Float, fovy: Float) {
        let scaleY = 1 / tan(fovy * 0.5)
        let scaleX = scaleY / aspect
        let scaleZ = -(far + near) / (far - near)
        let scaleW = -2 * far * near / (far - near)
        let X = vector_float4(scaleX, 0, 0, 0)
        let Y = vector_float4(0, scaleY, 0, 0)
        let Z = vector_float4(0, 0, scaleZ, -1)
        let W = vector_float4(0, 0, scaleW, 0)
        self.init(columns:(X, Y, Z, W))
    }
}
