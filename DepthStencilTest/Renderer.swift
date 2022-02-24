//
//  Renderer.swift
//  DepthStencilTest
//
//  Created by 焦国辉 on 2022/2/22.
//

import Cocoa
import MetalKit
import simd

class Renderer: NSObject {
    var device: MTLDevice
    var pipelineState: MTLRenderPipelineState
    var commandQueue: MTLCommandQueue
    var texture: MTLTexture!
    var viewportSize = vector_uint2(0, 0)
    var depthState: MTLDepthStencilState
//    var numVertices: Int
    var rotation: Float = 0
    
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
        Vertex(vector_float3(-0.5, 0.5, -0.5), vector_float2(0, 1))
    ]
    
    init?(with view: MTKView) {
        self.device = view.device!
        view.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 1)
        view.depthStencilPixelFormat = .depth32Float
        view.clearDepth = 1


        guard let library = device.makeDefaultLibrary() else {return nil}
        let vf = library.makeFunction(name: "vertexShader")
        let ff = library.makeFunction(name: "samplingShader")
        
        let rpd = MTLRenderPipelineDescriptor()
        rpd.vertexFunction = vf
        rpd.fragmentFunction = ff
        rpd.colorAttachments[0].pixelFormat = view.colorPixelFormat
        rpd.depthAttachmentPixelFormat = view.depthStencilPixelFormat
        
        
        guard let ps = try? device.makeRenderPipelineState(descriptor: rpd) else {return nil}
        self.pipelineState = ps
        
        
        let dsd = MTLDepthStencilDescriptor()
        dsd.depthCompareFunction = .lessEqual
        dsd.isDepthWriteEnabled = true
        guard let ds = device.makeDepthStencilState(descriptor: dsd) else {return nil}
        self.depthState = ds
        
        
        guard let cq = device.makeCommandQueue() else {return nil}
        self.commandQueue  = cq
        
        super.init()
        
        
        let imageURL = Bundle.main.urlForImageResource("Image.tga")!
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
        
        let vertices = device.makeBuffer(bytes: cubeVertices, length: MemoryLayout<Vertex>.stride * 36, options: .storageModeShared)!
        let numVertices = cubeVertices.count
        let mvpMatrixBuffer = device.makeBuffer(length: MemoryLayout<matrix_float4x4>.size, options: .storageModeShared)!
        
        
        let cameraPosition = vector_float3(0, 0, -3)
        rotation += 0.01
        let rotatedx = matrix_float4x4(rotationMatrix: rotation, axis: vector_float3(1, 0, 0))
        let rotatedy = matrix_float4x4(rotationMatrix: 0, axis: vector_float3(0, 1, 0))
        let modelMatrix = matrix_multiply(rotatedx, rotatedy)
        let viewMatrix = matrix_float4x4(translationMatrix: cameraPosition)
        let projMatrix = matrix_float4x4(projectionMatrix: 0.1, far: 100, aspect: 1, fovy: 1)
        let mvpMatrix = matrix_multiply(projMatrix, matrix_multiply(viewMatrix, modelMatrix))
        let mvpPointer = mvpMatrixBuffer.contents()
        var mvp = MVPMatrix(matrix: mvpMatrix)
        memcpy(mvpPointer, &mvp, MemoryLayout<MVPMatrix>.size)
        
        guard let commandBuffer = commandQueue.makeCommandBuffer() else{ return }
        guard let rpd = view.currentRenderPassDescriptor else {return}
        
        let textureD = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .depth32Float, width: Int(view.frame.width), height: Int(view.frame.height), mipmapped: false)
        textureD.storageMode = .private
        textureD.usage = .renderTarget
        let depthTexture = device.makeTexture(descriptor: textureD)
        rpd.depthAttachment.texture = depthTexture
        guard let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: rpd) else {return}
        encoder.setRenderPipelineState(pipelineState)
        encoder.setDepthStencilState(depthState)
        encoder.setVertexBuffer(vertices, offset: 0, index: 0)
        encoder.setVertexBuffer(mvpMatrixBuffer, offset: 0, index: 1)
        encoder.setFragmentTexture(texture, index: 0)
        encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: numVertices)
        encoder.endEncoding()
        commandBuffer.present(view.currentDrawable!)
        commandBuffer.commit()
    }
}
