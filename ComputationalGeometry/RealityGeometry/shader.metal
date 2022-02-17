//
//  shader.metal
//  RealityGeometry
//
//  Created by 许海峰 on 2022/2/17.
//

#include <metal_stdlib>
using namespace metal;
#include <RealityKit/RealityKit.h>

[[visible]]
void normalSurface(realitykit::surface_parameters params)
{
    float4 n = params.uniforms().model_to_world() * float4(params.geometry().normal(), 0);
    float3 c = n.xyz*0.5+0.5;
    params.surface().set_base_color(half3(c));
    params.surface().set_roughness(1.0);
}
[[visible]]
void uvSurface(realitykit::surface_parameters params)
{
    float4 uv = params.uniforms().model_to_world() * float4(params.geometry().uv0(), 0, 0);
    half3 c = half3(uv.x, uv.y, 0);
    params.surface().set_base_color(c);
    params.surface().set_roughness(1.0);
}
