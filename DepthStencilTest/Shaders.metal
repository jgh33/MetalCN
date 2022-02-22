//
//  Shaders.metal
//  DepthStencilTest
//
//  Created by 焦国辉 on 2022/2/22.
//

#include <metal_stdlib>
#include <simd/simd.h>

using namespace metal;

// Include header shared between this Metal shader code and C code executing Metal API commands

struct RasterizerData
{
    float4 position [[position]];
    float2 textureCoordinate;
};

struct AAPLVertex {
    vector_float3 position;
    vector_float2 textureCoordinate;
};

// Vertex Function
vertex RasterizerData
vertexShader(uint vertexID [[ vertex_id ]],
             constant AAPLVertex *vertexArray [[ buffer(0) ]],
             constant vector_uint2 *viewportSizePointer  [[ buffer(1) ]])

{

    RasterizerData out;

    float3 pixelSpacePosition = vertexArray[vertexID].position.xyz;

    // Get the viewport size and cast to float.
    float2 viewportSize = float2(*viewportSizePointer);

    out.position = vector_float4(0.0, 0.0, 0.0, 1.0);
    out.position.xy = 500 * pixelSpacePosition.xy / (viewportSize / 2.0);
    out.position.z = pixelSpacePosition.z * 500;

    out.textureCoordinate = vertexArray[vertexID].textureCoordinate;

    return out;
}

// Fragment function
fragment float4
samplingShader(RasterizerData in [[stage_in]],
               texture2d<half> colorTexture [[ texture(0) ]])
{
    constexpr sampler textureSampler (mag_filter::linear,
                                      min_filter::linear);

    // Sample the texture to obtain a color
    const half4 colorSample = colorTexture.sample(textureSampler, in.textureCoordinate);

    // return the color of the texture
    return float4(colorSample);
}



