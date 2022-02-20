//
//  Shaders.metal
//  MetalCN
//
//  Created by 焦国辉 on 2022/2/19.
//

#include <metal_stdlib>
#include <simd/simd.h>
using namespace metal;


struct RasterizerData {
    float4 position [[position]];
    float4 color;
};

struct AAPLVertex {
    vector_float2 position;
    vector_float4 color;
};

vertex RasterizerData vertexShader(uint vertexID [[vertex_id]], constant AAPLVertex *vertices [[buffer(0)]], constant vector_uint2 *viewportSizePointer [[buffer(1)]])
{
    RasterizerData out;
    float2 pixelSpacePosition = vertices[vertexID].position.xy;
    // Get the viewport size and cast to float.
    vector_float2 viewportSize = vector_float2(*viewportSizePointer);
    

    // To convert from positions in pixel space to positions in clip-space,
    //  divide the pixel coordinates by half the size of the viewport.
    out.position = vector_float4(0.0, 0.0, 0.0, 1.0);
    out.position.xy = pixelSpacePosition / (viewportSize / 2.0);

    // Pass the input color directly to the rasterizer.
    out.color = vertices[vertexID].color;

    return out;
}

fragment float4 fragmentShader(RasterizerData in [[stage_in]])
{
    // Return the interpolated color.
    return in.color;
}
