//
//  Adder.swift
//  MetalCompute
//
//  Created by 焦国辉 on 2022/2/19.
//

import Foundation
import Metal

let arrayLength = 1 << 24
let bufferSize = arrayLength * MemoryLayout<Float32>.size
class Adder {
    
    var device: MTLDevice
    var cps: MTLComputePipelineState
    var commandQueue: MTLCommandQueue
    var bufferA: MTLBuffer!
    var bufferB: MTLBuffer!
    var bufferC: MTLBuffer!
    init?(with device: MTLDevice) {
        self.device = device
        guard let library = device.makeDefaultLibrary() else {return nil}
        let af = library.makeFunction(name: "add_arrays")!
        guard let ps = try? device.makeComputePipelineState(function: af) else {return nil}
        self.cps = ps
        guard let queue = device.makeCommandQueue() else {return nil}
        self.commandQueue = queue
        
    }
    
    func prepareData() {
        bufferA = self.device.makeBuffer(length: bufferSize, options: .storageModeShared)
        bufferB = self.device.makeBuffer(length: bufferSize, options: .storageModeShared)
        bufferC = self.device.makeBuffer(length: bufferSize, options: .storageModeShared)
        
        self.generateRandomFloatData(for: bufferA)
        self.generateRandomFloatData(for: bufferB)
        print("准备完成")

    }
    
    func sendComputeCommand() {
        guard let commandBuffer = commandQueue.makeCommandBuffer() else {return }
        guard let encoder = commandBuffer.makeComputeCommandEncoder() else {return}
        
        encodeAddCommand(encoder: encoder)
        
        encoder.endEncoding()
        commandBuffer.commit()
//        commandBuffer.addCompletedHandler { [unowned self] _ in
//            print("计算完成")
//        }
        commandBuffer.waitUntilCompleted()
        print("计算完成")
    }
    
    func verifyResults() -> Bool {
        let pointer1 = bufferA.contents().bindMemory(to: Float32.self, capacity: arrayLength)
        let pointer2 = bufferB.contents().bindMemory(to: Float32.self, capacity: arrayLength)
        let pointer3 = bufferC.contents().bindMemory(to: Float32.self, capacity: arrayLength)

        var index = 0
        while(index < arrayLength) {
            let num1 = pointer1.advanced(by: index).pointee
            let num2 = pointer2.advanced(by: index).pointee
            let num3 = pointer3.advanced(by: index).pointee
            if num1 + num2 != num3 {
                print(num1, num2, num3, index)
                print("验证失败")

                return false
            }
            index += 1
        }
        print("验证完成")

        return true
    }
    
    
    
    private func generateRandomFloatData(for buffer: MTLBuffer) {
        let pointer = buffer.contents().bindMemory(to: Float32.self, capacity: arrayLength)
        
        var index = 0
        while(index < arrayLength) {
            pointer.advanced(by: index).pointee = Float32(arc4random_uniform(10000))
            index += 1
        }
    }
    
    private func encodeAddCommand(encoder: MTLComputeCommandEncoder) {
        encoder.setComputePipelineState(self.cps)
        encoder.setBuffer(bufferA, offset: 0, index: 0)
        encoder.setBuffer(bufferB, offset: 0, index: 1)
        encoder.setBuffer(bufferC, offset: 0, index: 2)
        
        
        let gridSize = MTLSize(width: arrayLength, height: 1, depth: 1)
        
        var threadGroupSize = cps.maxTotalThreadsPerThreadgroup
        
        if threadGroupSize > arrayLength {
            threadGroupSize = arrayLength
        }
        
        let size = MTLSize(width: threadGroupSize, height: 1, depth: 1)
        
        encoder.dispatchThreads(gridSize, threadsPerThreadgroup: size)
    }
}
