//
//  Renderer.metal
//  Synchronization
//
//  Created by 焦国辉 on 2022/2/20.
//

#include <metal_stdlib>
using namespace metal;


struct RasterizerData
{
    float4 position [[position]];
    float4 color;

};

struct AAPLVertex {
    vector_float2 position;
    vector_float4 color;
};

// Vertex shader.
vertex RasterizerData
vertexShader(const uint vertexID [[ vertex_id ]],
             const device AAPLVertex *vertices [[ buffer(0) ]],
             constant vector_uint2 *viewportSizePointer  [[ buffer(1) ]])
{
    RasterizerData out;

    float2 pixelSpacePosition = vertices[vertexID].position.xy;

    // Get the viewport size and cast to float.
    vector_float2 viewportSize = vector_float2(*viewportSizePointer);
    out.position = vector_float4(0.0, 0.0, 0.0, 1.0);
    out.position.xy = pixelSpacePosition / (viewportSize / 2.0);

    out.color = vertices[vertexID].color;

    return out;
}

// Fragment shader.
fragment float4 fragmentShader(RasterizerData in [[stage_in]])
{
    // Return the color you just set in the vertex shader.
    return in.color;
}

