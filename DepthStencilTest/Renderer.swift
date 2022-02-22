//
//  Renderer.swift
//  DepthStencilTest
//
//  Created by 焦国辉 on 2022/2/22.
//

import Cocoa
import MetalKit

class Renderer: NSObject {
    var device: MTLDevice
    var pipelineState: MTLRenderPipelineState
    var commandQueue: MTLCommandQueue
    var texture: MTLTexture!
    var vertices: MTLBuffer
    var numVertices: Int!
    var viewportSize = vector_uint2(0, 0)
    
    
    init?(with view: MTKView) {
        self.device = view.device!
        let imageURL = Bundle.main.urlForImageResource("Image.tga")!
        
        let cubeVertices = [
            Vertex(vector_float3(-0.5, -0.5, -0.5), vector_float2(0, 0)),
            Vertex(vector_float3(0.5, -0.5, -0.5), vector_float2(1, 0)),
            Vertex(vector_float3(0.5, 0.5, -0.5), vector_float2(1, 1)),
            Vertex(vector_float3(0.5, 0.5, -0.5), vector_float2(1, 1)),
            Vertex(vector_float3(-0.5, 0.5, -0.5), vector_float2(0, 1)),
            Vertex(vector_float3(-0.5, -0.5, -0.5), vector_float2(0, 0)),
            
            Vertex(vector_float3(-0.5, -0.5, 0.5), vector_float2(0, 0)),
            Vertex(vector_float3(0.5, -0.5, 0.5), vector_float2(1, 0)),
            Vertex(vector_float3(0.5, 0.5, 0.5), vector_float2(1, 1)),
            Vertex(vector_float3(0.5, 0.5, 0.5), vector_float2(1, 1)),
            Vertex(vector_float3(-0.5, 0.5, 0.5), vector_float2(0, 1)),
            Vertex(vector_float3(-0.5, -0.5, 0.5), vector_float2(0, 0)),

            Vertex(vector_float3(-0.5, 0.5, 0.5), vector_float2(1, 0)),
            Vertex(vector_float3(-0.5, 0.5, -0.5), vector_float2(1, 1)),
            Vertex(vector_float3(-0.5, -0.5, -0.5), vector_float2(0, 1)),
            Vertex(vector_float3(-0.5, -0.5, -0.5), vector_float2(0, 1)),
            Vertex(vector_float3(-0.5, -0.5, 0.5), vector_float2(0, 0)),
            Vertex(vector_float3(-0.5, 0.5, 0.5), vector_float2(1, 0)),
            
            Vertex(vector_float3(0.5, 0.5, 0.5), vector_float2(1, 0)),
            Vertex(vector_float3(0.5, 0.5, -0.5), vector_float2(1, 1)),
            Vertex(vector_float3(0.5, -0.5, -0.5), vector_float2(0, 1)),
            Vertex(vector_float3(0.5, -0.5, -0.5), vector_float2(0, 1)),
            Vertex(vector_float3(0.5, -0.5, 0.5), vector_float2(0, 0)),
            Vertex(vector_float3(0.5, 0.5, 0.5), vector_float2(1, 0)),

            Vertex(vector_float3(-0.5, -0.5, -0.5), vector_float2(0, 1)),
            Vertex(vector_float3(0.5, -0.5, -0.5), vector_float2(1, 1)),
            Vertex(vector_float3(0.5, -0.5, 0.5), vector_float2(1, 0)),
            Vertex(vector_float3(0.5, -0.5, 0.5), vector_float2(1, 0)),
            Vertex(vector_float3(-0.5, -0.5, 0.5), vector_float2(0, 0)),
            Vertex(vector_float3(-0.5, -0.5, -0.5), vector_float2(0, 1)),

            Vertex(vector_float3(-0.5, 0.5, -0.5), vector_float2(0, 1)),
            Vertex(vector_float3(0.5, 0.5, -0.5), vector_float2(1, 1)),
            Vertex(vector_float3(0.5, 0.5, 0.5), vector_float2(1, 0)),
            Vertex(vector_float3(0.5, 0.5, 0.5), vector_float2(1, 0)),
            Vertex(vector_float3(-0.5, 0.5, 0.5), vector_float2(0, 0)),
            Vertex(vector_float3(-0.5, 0.5, -0.5), vector_float2(0, 1)),
        ]
        
        vertices = device.makeBuffer(bytes: cubeVertices, length: MemoryLayout<Vertex>.size * 36, options: .storageModeShared)!
        numVertices = cubeVertices.count
        
        guard let library = device.makeDefaultLibrary() else {return nil}
        let vf = library.makeFunction(name: "vertexShader")
        let ff = library.makeFunction(name: "samplingShader")
        
        let rpd = MTLRenderPipelineDescriptor()
        rpd.vertexFunction = vf
        rpd.fragmentFunction = ff
        rpd.colorAttachments[0].pixelFormat = view.colorPixelFormat
        
        
        guard let ps = try? device.makeRenderPipelineState(descriptor: rpd) else {return nil}
        self.pipelineState = ps
        
        guard let cq = device.makeCommandQueue() else {return nil}
        self.commandQueue  = cq
        
        super.init()
        
        guard let tx = self.loadTexture(url: imageURL) else {return nil}
        self.texture = tx
        
    }
    
    private func loadTexture(url: URL) -> MTLTexture? {
        guard let image = AAPLImage(tgaFileAtLocation: url) else {return nil}
        let textureD = MTLTextureDescriptor()
        textureD.pixelFormat = .bgra8Unorm
        textureD.width = Int(image.width)
        textureD.height = Int(image.height)
        
        guard let texture = device.makeTexture(descriptor: textureD) else {return nil}
        let bytesPerRow = 4 * image.width
        let region = MTLRegion(origin: MTLOriginMake(0, 0, 0), size: MTLSize(width: Int(image.width), height: Int(image.height), depth: 1))
        let bytes = [UInt8](image.data)
        texture.replace(region: region, mipmapLevel: 0, withBytes: bytes, bytesPerRow: Int(bytesPerRow))
        
        return texture

    }
    
}

extension Renderer: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        viewportSize = vector_uint2(UInt32(size.width), UInt32(size.height))
    }
    
    func draw(in view: MTKView) {
        guard let commandBuffer = commandQueue.makeCommandBuffer() else{ return }
        guard let rpd = view.currentRenderPassDescriptor else {return}
        guard let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: rpd) else {return}
        encoder.setRenderPipelineState(pipelineState)
        encoder.setViewport(MTLViewport(originX: 0, originY: 0, width: Double(viewportSize.x), height: Double(viewportSize.y), znear: -1, zfar: 1))
        encoder.setVertexBuffer(vertices, offset: 0, index: 0)
        encoder.setVertexBytes(&viewportSize, length: MemoryLayout.size(ofValue: viewportSize), index: 1)
        encoder.setFragmentTexture(texture, index: 0)
        encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: numVertices)
        encoder.endEncoding()
        commandBuffer.present(view.currentDrawable!)
        commandBuffer.commit()
    }
    
    
}
