//
//  add.metal
//  MetalCompute
//
//  Created by 焦国辉 on 2022/2/19.
//

#include <metal_stdlib>
using namespace metal;


kernel void add_arrays(device const float* inA,
                       device const float* inB,
                       device float* result,
                       uint index [[thread_position_in_grid]])
{
    // the for-loop is replaced with a collection of threads, each of which
    // calls this function.
    result[index] = inA[index] + inB[index];
}
