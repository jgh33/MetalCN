//
//  Renderer.swift
//  RenderPass
//
//  Created by 焦国辉 on 2022/2/23.
//

import Cocoa
import MetalKit
import simd

class Renderer: NSObject {
    
    var device: MTLDevice
    var commandQueue: MTLCommandQueue
    
    var renderTargetTexture: MTLTexture!
    var textureRenderPassDescriotor: MTLRenderPassDescriptor!
    var textureRenderPipeline: MTLRenderPipelineState!
    var drawableRenderPipeline: MTLRenderPipelineState!
    
    var aspectRatio: Float = 0

    let triVertices = [
        Vertex(vector_float2(0.5, -0.5), vector_float4(1, 0, 0, 1)),
        Vertex(vector_float2(-0.5, -0.5), vector_float4(0, 1, 0, 1)),
        Vertex(vector_float2(0, -0.5), vector_float4(0, 0, 1, 1)),
    ]
    
    let quadVertices = [
        VertexT(vector_float2(0.5, -0.5), vector_float2(1, 1)),
        VertexT(vector_float2(-0.5, -0.5), vector_float2(0, 1)),
        VertexT(vector_float2(-0.5, -0.5), vector_float2(0, 0)),
        VertexT(vector_float2(0.5, -0.5), vector_float2(1, 1)),
        VertexT(vector_float2(-0.5, 0.5), vector_float2(0, 0)),
        VertexT(vector_float2(0.5, 0.5), vector_float2(1, 0)),
    ]
    init?(with view: MTKView) {
        device = view.device!
        view.clearColor = MTLClearColor(red: 1, green: 0, blue: 0, alpha: 1)
        commandQueue = device.makeCommandQueue()!
        
        let td = MTLTextureDescriptor()
        td.textureType = .type2D
        td.width = 512
        td.height = 512
        td.pixelFormat = .bgra8Unorm
        td.usage = [.renderTarget, .shaderRead]
        
        renderTargetTexture = device.makeTexture(descriptor: td)
        
        let trpd = MTLRenderPassDescriptor()
        trpd.colorAttachments[0].texture = renderTargetTexture
        trpd.colorAttachments[0].loadAction = .clear
        trpd.colorAttachments[0].clearColor = MTLClearColor(red: 1, green: 1, blue: 1, alpha: 1)
        trpd.colorAttachments[0].storeAction = .store
        self.textureRenderPassDescriotor = trpd
        
        let library = device.makeDefaultLibrary()!
        
    let psd = MTLRenderPipelineDescriptor()
        psd.sampleCount = view.sampleCount
        psd.vertexFunction = library.makeFunction(name: "textureVertexShader")
        psd.fragmentFunction = library.makeFunction(name: "textureFragmentShader")
        psd.colorAttachments[0].pixelFormat = view.colorPixelFormat
        psd.vertexBuffers[0].mutability = .immutable
        
        drawableRenderPipeline = try! device.makeRenderPipelineState(descriptor: psd)


//        offscreen
        psd.sampleCount = 1
        psd.vertexFunction = library.makeFunction(name: "simpleVertexShader")
        psd.fragmentFunction = library.makeFunction(name: "simpleFragmentShader")
        psd.colorAttachments[0].pixelFormat = renderTargetTexture.pixelFormat
        textureRenderPipeline = try! device.makeRenderPipelineState(descriptor: psd)
        
        
        super.init()
        
        print(MemoryLayout<Vertex>.size)
        print(MemoryLayout<VertexT>.size)
    }
}

extension Renderer: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        aspectRatio = Float(size.height / size.width)
    }
    
    func draw(in view: MTKView) {
        let cb = commandQueue.makeCommandBuffer()!
        
        let encoder = cb.makeRenderCommandEncoder(descriptor: textureRenderPassDescriotor)!
        encoder.setRenderPipelineState(textureRenderPipeline)
        encoder.setVertexBytes(triVertices, length: MemoryLayout<Vertex>.size * 3, index: 0)
        encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
        encoder.endEncoding()
        
        
//        let drawpd = view.currentRenderPassDescriptor!
//
//        let encoderT = cb.makeRenderCommandEncoder(descriptor: drawpd)!
//        encoderT.setRenderPipelineState(drawableRenderPipeline)
//        encoderT.setVertexBytes(quadVertices, length: MemoryLayout<VertexT>.size * 6, index: 0)
//        encoderT.setVertexBytes(&aspectRatio, length: MemoryLayout<Float>.size, index: 1)
//        encoderT.setFragmentTexture(renderTargetTexture, index: 0)
//        encoderT.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)
//
//        encoderT.endEncoding()
        
        cb.present(view.currentDrawable!)
        
        cb.commit()
        
    }
    
    
}
