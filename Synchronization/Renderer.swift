//
//  Renderer.swift
//  Synchronization
//
//  Created by 焦国辉 on 2022/2/20.
//

import Foundation
import Metal
import simd
import MetalKit

let maxFramesInFlight = 3

let numTriangles = 50

class Renderer: NSObject {
    var semaghore: DispatchSemaphore
    var vertexBuffers: [MTLBuffer] = []
    var currentBufferIndex = 0
    var device: MTLDevice
    var commandQueue: MTLCommandQueue
    var pipelineState: MTLRenderPipelineState
    var viewportSize: vector_uint2
    var triangles: [Triangle] = []
    let allVertexCount: Int = 3 * numTriangles
    var wavePosition: Float = 0
    
    init?(with view: MTKView) {
        device = view.device!
        semaghore = DispatchSemaphore(value: maxFramesInFlight)
        guard let library = device.makeDefaultLibrary() else{return nil}
        let vf = library.makeFunction(name: "vertexShader")
        let ff = library.makeFunction(name: "fragmentShader")
        
        let psd = MTLRenderPipelineDescriptor()
        psd.sampleCount = view.sampleCount
        psd.vertexFunction = vf
        psd.fragmentFunction = ff
        psd.colorAttachments[0].pixelFormat = view.colorPixelFormat
        psd.vertexBuffers[0].mutability = .immutable
        
        guard let ps = try? device.makeRenderPipelineState(descriptor: psd) else {return nil}
        self.pipelineState = ps
        guard let cq = device.makeCommandQueue() else {return nil}
        self.commandQueue = cq
        
        viewportSize = vector_uint2(x: 0, y: 0)
        super.init()
        
        self.generateTriangles()
        
        let bufferSize = allVertexCount * MemoryLayout<Vertex>.size
        
        var index = 0
        while(index < maxFramesInFlight) {
            let buffer = device.makeBuffer(length: bufferSize, options: .storageModeShared)!
            vertexBuffers.append(buffer)
            index += 1
        }
    }
    
    private func generateTriangles() {
        let colors = [
            vector_float4(1.0, 0.0, 0.0, 1.0),  // Red
            vector_float4(0.0, 1.0, 0.0, 1.0),  // Green
            vector_float4(0.0, 0.0, 1.0, 1.0),  // Blue
            vector_float4(1.0, 0.0, 1.0, 1.0),  // Magenta
            vector_float4(0.0, 1.0, 1.0, 1.0),  // Cyan
            vector_float4(1.0, 1.0, 0.0, 1.0),  //Yellow
        ]
        
        let numColors = colors.count
        
        let hSpacing: Float = 16
        
        self.triangles = []
        var index = 0
        while(index < numTriangles) {
            let x = (Float(index) - Float(numTriangles)/2.0) * hSpacing
//            let point = ((Float)index - (Float)numTriangles/2.0) * hSpacing
            let position = vector_float2(x, 0)
            let color = colors[index % numColors]
            let triangle = Triangle(position, color)
            
            self.triangles.append(triangle)
            index += 1
        }
    }
    
    private func updateState() {
        let magnitue: Float = 128.0
        let speed: Float = 0.05
        wavePosition += speed
        
        let vertices = Triangle.vertices()
        let currentVerticesPointer = vertexBuffers[currentBufferIndex].contents().bindMemory(to: Vertex.self, capacity: allVertexCount)

        
        var indexT = 0
        while(indexT < numTriangles) {
            var position = self.triangles[indexT].position
            position.y = (sin(position.x/magnitue + wavePosition) * magnitue)
            self.triangles[indexT].position = position
            
            var indexV = 0
            while(indexV < 3) {
                let currentVertex = indexV + indexT * 3
                let vertex = Vertex(vertices[indexV].position + triangles[indexT].position, triangles[indexT].color)
                currentVerticesPointer.advanced(by: currentVertex).pointee = vertex
                indexV += 1
            }
            
            indexT += 1
        }
    }
    
}


extension Renderer: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        self.generateTriangles()
        viewportSize = vector_uint2(x: UInt32(size.width), y: UInt32(size.height))
        
    }
    
    func draw(in view: MTKView) {
        semaghore.wait()
        currentBufferIndex = (currentBufferIndex + 1) % maxFramesInFlight
        self.updateState()
        
        guard let commandBuffer = commandQueue.makeCommandBuffer() else{ return }
        guard let rpd = view.currentRenderPassDescriptor else {return}
        guard let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: rpd) else {return}
        encoder.setRenderPipelineState(pipelineState)
        encoder.setVertexBuffer(vertexBuffers[currentBufferIndex], offset: 0, index: 0)
        encoder.setVertexBytes(&viewportSize, length: MemoryLayout.size(ofValue: viewportSize), index: 1)
        encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: allVertexCount)
        encoder.endEncoding()
        commandBuffer.present(view.currentDrawable!)
        
        
        commandBuffer.addCompletedHandler {[unowned self] buffer in
            self.semaghore.signal()
        }
        
        commandBuffer.commit()
    }
    
    
}
